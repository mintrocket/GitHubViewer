import Foundation

public typealias ActionFunc = () -> Void
public typealias Action<T> = (T) -> Void
public typealias ActionIO<I, O> = (I) -> (O)
public typealias Factory<O> = () -> (O)


struct Constants {
    struct Strings {
        static let error = "Ошибка"
        static let github = "GitHub"
    }
}
