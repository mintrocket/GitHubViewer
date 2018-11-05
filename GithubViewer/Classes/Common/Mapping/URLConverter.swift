import Foundation

public final class URLConverter: Converter {
    public typealias FromValue = String?
    public typealias ToValue = URL?

    public func convert(from item: String?) -> URL? {
        return item?.toURL()
    }
}
