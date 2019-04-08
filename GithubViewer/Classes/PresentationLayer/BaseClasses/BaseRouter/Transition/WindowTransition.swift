import UIKit

public protocol WindowTransition {
    var animator: Animator { get }

    func prepareForDissmiss(_ window: UIWindow)
    func animateDissmiss(_ window: UIWindow)

    func prepareForShow(_ window: UIWindow)
    func animateShow(_ window: UIWindow)
}

public enum Animator {
    case normal(duration: TimeInterval, curve: UIView.AnimationCurve)
    case spring(duration: TimeInterval, dumping: CGFloat, velocity: CGFloat, curve: UIView.AnimationCurve)

    var duration: TimeInterval {
        switch self {
        case let .normal(duration, _), let .spring(duration, _, _, _):
            return duration
        }
    }

    func run(animation: @escaping ActionFunc, completion: ActionFunc? = nil) {
        switch self {
        case let .normal(duration, curve):
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: self.getOptions(from: curve),
                           animations: animation,
                           completion: { _ in completion?() })
        case let .spring(duration, dumping, velocity, curve):
            UIView.animate(withDuration: duration,
                           delay: 0,
                           usingSpringWithDamping: dumping,
                           initialSpringVelocity: velocity,
                           options: self.getOptions(from: curve),
                           animations: animation,
                           completion: { _ in completion?() })
        }
    }

    private func getOptions(from curve: UIView.AnimationCurve) -> UIView.AnimationOptions {
        switch curve {
        case .linear:
            return .curveLinear
        case .easeIn:
            return .curveEaseIn
        case .easeOut:
            return .curveEaseOut
        case .easeInOut:
            return .curveEaseInOut
        @unknown default:
            fatalError()
        }
    }
}

public struct FadeWindowTransition: WindowTransition {
    public var animator: Animator {
        return .normal(duration: 0.5, curve: .easeInOut)
    }

    public func prepareForDissmiss(_ window: UIWindow) {}

    public func animateDissmiss(_ window: UIWindow) {
        window.alpha = 0
    }

    public func prepareForShow(_ window: UIWindow) {
        window.alpha = 0
    }

    public func animateShow(_ window: UIWindow) {
        window.alpha = 1
    }
}

public struct PushWindowTransition: WindowTransition {
    public var animator: Animator {
        return .spring(duration: 0.5, dumping: 1, velocity: 0, curve: .easeInOut)
    }

    public func prepareForDissmiss(_ window: UIWindow) {}

    public func animateDissmiss(_ window: UIWindow) {
        window.transform = .init(translationX: -window.bounds.width * 0.3,
                                 y: 0)
    }

    public func prepareForShow(_ window: UIWindow) {
        window.transform = .init(translationX: window.bounds.width,
                                 y: 0)
    }

    public func animateShow(_ window: UIWindow) {
        window.transform = .identity
    }
}

public struct FallWindowTransition: WindowTransition {
    public var animator: Animator {
        return .spring(duration: 0.5, dumping: 0.7, velocity: 0, curve: .easeInOut)
    }

    public func prepareForDissmiss(_ window: UIWindow) {}

    public func animateDissmiss(_ window: UIWindow) {
        window.transform = .init(translationX: 0, y: -window.bounds.height)
    }

    public func prepareForShow(_ window: UIWindow) {
        window.transform = .init(translationX: 0, y: -window.bounds.height)
    }

    public func animateShow(_ window: UIWindow) {
        window.transform = .identity
    }
}
