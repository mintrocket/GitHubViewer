import Foundation

/// Protocol of convert NetworkResponse to pair (ResponseData?, Error?).
///
/// This protocol required for initialisation of BackendConfiguration
/// and response processing
///
/// For example see JsonResponseConverter
protocol BackendResponseConverter: class {
    /// Convert NetworkResponse to pair (ResponseData?, Error?)
    /// - parameter data: Response from NetworkService
    /// - returns: (ResponseData?, Error?)
    func convert<T: BackendAPIRequest>(_ type: T.Type,
                                       response data: NetworkManager.NetworkResponse) -> (T.ResponseObject?, Error?)
}

public class JsonResponseConverter: BackendResponseConverter, Loggable {
    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    func convert<T: BackendAPIRequest>(_ type: T.Type,
                                       response data: NetworkManager.NetworkResponse) -> (T.ResponseObject?, Error?) {
        if (data.0 as NSData).length == 0 {
            return (nil, AppError.responseError(code: MRKitErrorCode.emptyResponse))
        }

        let model = try? JSONDecoder().decode(T.ResponseObject.self, from: data.0)

        if let responseData = model {
            return (responseData, nil)
        } else if let error = try? JSONDecoder().decode(ApiError.self, from: data.0) {
            return (nil, AppError.api(error: error))
        } else {
            self.log(.error, "Error parsing request: \(data.3!)")
            let text = String(data: data.0, encoding: .utf8) ?? ""
            self.log(.error, text)
            return (nil, AppError.responseError(code: MRKitErrorCode.parsingError))
        }
    }
}
