import Alamofire
import Foundation

public protocol ApiUrlHolder {
    func apiUrl() -> String
}

/// Configuration of BackendService
final class BackendConfiguration {
    /// Url of API Server
    let baseURL: URL

    /// Default server response converter
    var converter: BackendResponseConverter

    /// It intercept all requests before execute
    /// Example, you can pass token here
    var interceptor: RequestAdapter?

    /// It intercept error for retry request
    var retrier: RequestRetrier?

    /// Initialisation of BackendConfiguration
    /// - parameter holder: API Server Url holder
    /// - parameter converter: Server response converter
    /// - parameter interceptor: It intercept all requests before execute
    /// - parameter retrier: It intercept error for retry request
    public init(holder: ApiUrlHolder,
                converter: BackendResponseConverter,
                interceptor: RequestAdapter? = nil,
                retrier: RequestRetrier? = nil) {
        if let url = try? holder.apiUrl().asURL() {
            self.baseURL = url
        } else {
            fatalError("URL REQUIRED")
        }
        self.converter = converter
        self.interceptor = interceptor
        self.retrier = retrier
    }
}
