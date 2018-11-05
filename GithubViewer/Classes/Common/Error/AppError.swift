import Alamofire
import Foundation
import LocalAuthentication

public enum AppError: Error, CustomStringConvertible, CustomDebugStringConvertible {
    private static let errorDomain: String = "MRKitErrorDomain"

    case error(code: Int)
    case responseError(code: Int)
    case network(error: Error)
    case unexpectedError(message: String)
    case api(error: Error)
    case other(error: Error)

    public var code: Int {
        switch self {
        case let .error(code):
            return code
        case let .responseError(code):
            return code
        case let .network(error), let .other(error), let .api(error):
            return (error as NSError).code
        case .unexpectedError:
            return 0
        }
    }

    public var description: String {
        switch self {
        case let .error(code):
            return "Error with code: \(code)"
        case let .responseError(code):
            return "Response Error with code: \(code)"
        case let .network(error), let .other(error), let .api(error):
            return error.message
        case let .unexpectedError(message):
            return "Unexpected error with message: \(message)"
        }
    }

    public var debugDescription: String {
        switch self {
        case let .error(code):
            return "Error with code: \(code)"
        case let .responseError(code):
            return "Response error: \(code)"
        case let .network(error), let .other(error), let .api(error):
            return error.message
        case let .unexpectedError(message):
            return "Unexpected error with message: \(message)"
        }
    }

    public static func nsError(code: Int = -100, message: String) -> AppError {
        return .other(error: NSError(domain: AppError.errorDomain,
                                     code: code,
                                     userInfo: [NSLocalizedDescriptionKey: message]))
    }
}

extension Error {
    var message: String {
        var value = "\(self)"
        if let m = (self as NSError).userInfo[NSLocalizedDescriptionKey] as? String {
            value = m
        } else if let afError = self as? AFError {
            value = "Network \(afError.responseCode ?? -1)"
        }
        return value
    }
}
