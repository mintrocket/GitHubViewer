import Foundation

public protocol Converter {
    associatedtype FromValue
    associatedtype ToValue

    func convert(from item: FromValue) -> ToValue
}

infix operator <-
public func <- <V, C: Converter>(value: V, converter: C) -> C.ToValue where V == C.FromValue {
    return converter.convert(from: value)
}
