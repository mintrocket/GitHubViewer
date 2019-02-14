import Foundation
import RxSwift

public extension ObservableType {
    public func asVoidSingle() -> Single<Void> {
        return asSingle().flatMap { _ in
            Single.just(())
        }
    }
}

public extension PrimitiveSequenceType where Self.TraitType == RxSwift.SingleTrait {
    public func asVoid() -> Single<Void> {
        return flatMap { _ in
            Single.just(())
        }
    }
}
