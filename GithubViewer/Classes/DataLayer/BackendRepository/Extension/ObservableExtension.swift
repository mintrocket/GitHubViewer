import Foundation
import RxSwift

//public extension PrimitiveSequenceType where Self.TraitType == RxSwift.SingleTrait, Self.ElementType == ResponseData {
//    public func map<T: Decodable>(_ type: T.Type) -> Single<T> {
//        return self.map { try $0.mapObject(type) }
//    }
//}

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
