import Foundation

public class ResponseData<T: Decodable>: CustomDebugStringConvertible, Equatable {
    public let statusCode: Int
    public let data: T
    public let request: URLRequest?
    public let response: URLResponse?

    /// ResponseData initialisation
    /// - parameter statusCode: code of response
    /// - parameter data: processed response data
    /// - parameter request: URLRequest
    /// - parameter response: URLResponse
    public init(statusCode: Int, data: T, request: URLRequest? = nil, response: URLResponse? = nil) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
    }

    /// ResponseData initialisation
    /// - parameter networkResponse: NetworkService response
    /// - parameter data: processed response data
    public init(from networkResponse: NetworkManager.NetworkResponse, data: T) {
        self.statusCode = networkResponse.1
        self.data = data
        self.request = networkResponse.3
        self.response = networkResponse.2
    }

    /// A text description of the `Response`.
    public var description: String {
        return "Status Code: \(self.statusCode)"
    }

    /// A text description of the `Response`. Suitable for debugging.
    public var debugDescription: String {
        return self.description
    }

    public static func == (lhs: ResponseData, rhs: ResponseData) -> Bool {
        return lhs.statusCode == rhs.statusCode
            && lhs.response == rhs.response
    }
}
