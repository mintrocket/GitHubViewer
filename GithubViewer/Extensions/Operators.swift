infix operator >>
public func >> <T>(value: Any?, toType: T.Type) -> T? {
    return value as? T
}

prefix operator ~
public prefix func ~ <T>(value: T) -> T.Type {
    return T.self
}
