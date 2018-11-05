import Foundation

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

extension KeyedDecodingContainer {
    subscript<T>(key: Key, default defaultValue: @autoclosure () -> T) -> T where T: Decodable {
        get {
            if let value = try? self.decodeIfPresent(T.self, forKey: key), let result = value {
                return result
            }
            return defaultValue()
        }
    }

    subscript<T>(key: Key) -> T? where T: Decodable {
        get {
            if let value = try? self.decodeIfPresent(T.self, forKey: key) {
                return value
            }
            return nil
        }
    }
}

extension String: CodingKey {
    public var stringValue: String {
        return self
    }

    public var intValue: Int? {
        return nil
    }

    public init?(intValue: Int) {
        return nil
    }

    public init?(stringValue: String) {
        self = stringValue
    }
}

public protocol DecodingContext {
}

extension CodingUserInfoKey {
    public static let decodingContext: CodingUserInfoKey = CodingUserInfoKey(rawValue: "decodingContext")!
}

extension Decoder {
    public var decodingContext: DecodingContext? {
        return userInfo[.decodingContext] as? DecodingContext
    }
}

extension JSONDecoder {
    convenience init(context: DecodingContext) {
        self.init()
        self.userInfo[.decodingContext] = context
    }
}
