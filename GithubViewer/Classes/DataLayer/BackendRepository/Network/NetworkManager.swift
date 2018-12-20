import Alamofire
import Foundation
import RxSwift

open class NetworkManager: Loggable {
    public typealias MultiPartData = (item: Data, fileName: String, mimeType: String)
    public typealias NetworkResponse = (Data, Int, HTTPURLResponse?, URLRequest?)

    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    private static let requestTimeout: Double = 30
    private var task: URLSessionTask?
    private var manager: SessionManager!

    public enum Method: String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }

    init(adapter: RequestAdapter?, retrier: RequestRetrier?) {
        self.manager = SessionManager(configuration: self.configuration())
        self.manager.adapter = adapter
        self.manager.retrier = retrier
    }

    fileprivate func configuration() -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = NetworkManager.requestTimeout
        configuration.timeoutIntervalForRequest = NetworkManager.requestTimeout
        return configuration
    }

    func request(url: URL,
                 method: Method,
                 params: [String: Any]? = nil,
                 headers: [String: String]? = nil) -> Single<NetworkResponse> {
        return Single.deferred({ [unowned self] () -> Single<NetworkResponse> in
            let request = self.createRequest(url: url,
                                             method: method,
                                             params: params,
                                             headers: headers)

            return Single.create(subscribe: { [unowned self] (observer) -> Disposable in
                let request = self.manager.request(request)
                self.log(.debug, "Request: \(request)")
                self.task = request.task
                request.response(completionHandler: { response in
                    if let error = response.error {
                        observer(.error(AppError.network(error: error)))
                    } else if response.response != nil {
                        observer(.success((response.data!,
                                           response.response!.statusCode,
                                           response.response,
                                           response.request)))
                    } else {
                        observer(.error(AppError.responseError(code: MRKitErrorCode.unknownNetworkError)))
                    }
                })
                return Disposables.create()
            }).retry(1)
        })
    }

    func upload(data: [String: MultiPartData],
                url: URL,
                method: Method,
                params: [String: Any]? = nil,
                headers: [String: String]? = nil) -> Single<NetworkResponse> {
        return Single.deferred({ [unowned self] () -> Single<NetworkResponse> in
            let request = self.createRequest(url: url,
                                             method: method,
                                             params: params,
                                             headers: headers)

            return Single.create(subscribe: { [unowned self] (observer) -> Disposable in

                let multiPartAction: (MultipartFormData) -> Void = {
                    multipartFormData in
                    for (key, value) in data {
                        multipartFormData.append(value.item, withName: key, fileName: value.fileName, mimeType: value.mimeType)
                    }
                    if params != nil {
                        for (key, value) in params! {
                            multipartFormData.append("\(value)".data(using: .utf8)!, withName: key)
                        }
                    }
                }

                let encodingCompletion: (SessionManager.MultipartFormDataEncodingResult) -> Void = {
                    result in
                    switch result {
                    case let .success(request, _, _):
                        self.log(.debug, "Request: \(request)")
                        self.task = request.task
                        request.response(completionHandler: { response in
                            if let error = response.error {
                                observer(.error(AppError.network(error: error)))
                            } else if response.response != nil {
                                observer(.success((response.data!,
                                                   response.response!.statusCode,
                                                   response.response,
                                                   response.request)))
                            } else {
                                observer(.error(AppError.responseError(code: MRKitErrorCode.unknownNetworkError)))
                            }
                        })
                    case let .failure(error):
                        self.log(.error, "Request: \(error)")
                        observer(.error(error))
                    }
                }

                self.manager.upload(multipartFormData: multiPartAction,
                                    with: request,
                                    encodingCompletion: encodingCompletion)
                return Disposables.create()
            })
        })
    }

    func addJSONContentType(request: inout URLRequest) {
        if request.allHTTPHeaderFields == nil {
            request.allHTTPHeaderFields = [:]
        }
        request.allHTTPHeaderFields!["Content-type"] = "application/json"
    }

    func createRequest(url: URL,
                       method: Method,
                       params: [String: Any]?,
                       headers: [String: String]?) -> URLRequest {
        var requestURL: URL = url
        if let values = params {
            let parameterString = values.stringFromHttpParameters()
            if method == .GET {
                requestURL = URL(string: "\(url)?\(parameterString)")!
            }
        }

        var request = URLRequest(url: requestURL,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: NetworkManager.requestTimeout)

        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue

        if method != .GET && params != nil {
            do {
                let bodyData = try JSONSerialization.data(withJSONObject: params!, options: [])
                request.httpBody = bodyData
                #if DEBUG
                self.log(.debug, "BODY:\n\(String(data: bodyData, encoding: .utf8) ?? "NONE")")
                #endif

                self.addJSONContentType(request: &request)
            } catch {
                self.log(.error, "Body data serialisazion error: \(error)")
            }
        }
        return request
    }

    func cancel() {
        self.task?.cancel()
    }
}
