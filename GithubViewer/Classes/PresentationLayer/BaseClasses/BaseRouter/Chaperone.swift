import RxSwift
import UIKit

public protocol ChaperoneRouter {
    func move()
}

public protocol StatusBarChangeable: class {
    var statusBarStyle: UIStatusBarStyle { get set }
}

public final class ToastModalRouter: ChaperoneRouter {
    public struct Options {
        var transition: WindowTransition
        var frame: CGRect

        init(frame: CGRect = UIScreen.main.bounds,
             transition: WindowTransition = FadeWindowTransition()) {
            self.transition = transition
            self.frame = frame
        }
    }

    private static var bag: DisposeBag!

    let target: UIViewController
    let duration: TimeInterval
    let options: Options
    let completion: ActionFunc?

    init(target: UIViewController,
         duration: TimeInterval = 1,
         options: Options = Options(),
         completion: ActionFunc? = nil) {
        self.target = target
        self.duration = duration
        self.options = options
        self.completion = completion
    }

    public func move() {
        self.toast(self.target)
    }

    private func toast(_ controller: UIViewController) {
        let oldStyle = UIApplication.shared.statusBarStyle
        let windowLevel = UIWindow.Level.normal + CGFloat(UIApplication.shared.windows.count)
        var window: UIWindow! = UIWindow(frame: UIScreen.main.bounds)
        
        window.rootViewController = controller
        window.windowLevel = windowLevel
        window.makeKeyAndVisible()
        window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        window.frame = options.frame

        window.clipsToBounds = false
        window.isUserInteractionEnabled = false

        controller.view.isUserInteractionEnabled = false

        ToastModalRouter.bag = DisposeBag()
        let animationTime: TimeInterval = self.options.transition.animator.duration
        Observable<Int>.timer(self.duration + animationTime, scheduler: MainScheduler.instance)
            .subscribe(onNext: { _ in
                ToastModalRouter.bag = nil
            }, onDisposed: {
                window.frame = UIScreen.main.bounds
                (window.rootViewController as? StatusBarChangeable)?.statusBarStyle = oldStyle
                window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                window.frame = self.options.frame

                self.options.transition.prepareForDissmiss(window)
                self.options.transition.animator.run(animation: {
                    self.options.transition.animateDissmiss(window)
                }, completion: {
                    self.completion?()
                    window = nil
                })
            })
            .disposed(by: ToastModalRouter.bag)
        self.options.transition.prepareForShow(window)
        self.options.transition.animator.run(animation: {
            self.options.transition.animateShow(window)
        })
    }
}

public class ModalRouter: NSObject, ChaperoneRouter {
    fileprivate let target: UIViewController
    fileprivate let parent: UIViewController?
    fileprivate var windowLevel: UIWindow.Level = .normal

    init(target: UIViewController, parent: UIViewController?) {
        self.target = target
        self.parent = parent
    }

    public func set(level: UIWindow.Level) -> Self {
        self.windowLevel = level
        return self
    }

    public func move() {
        if let vc = parent {
            self.presentModal(self.target, from: vc)
        } else {
            self.presentModal(self.target)
        }
    }

    private func presentModal(_ controller: UIViewController, from parent: UIViewController) {
        parent.present(controller, animated: true, completion: {})
    }

    private func presentModal(_ controller: UIViewController) {
        let windowLevel = self.windowLevel + CGFloat(UIApplication.shared.windows.count)
        var window: UIWindow? = MRWindow.create(level: windowLevel)
        window?.rootViewController?.present(controller, animated: true, completion: {
            window = nil
        })
    }
}

public class PushRouter: ChaperoneRouter {
    let target: UIViewController
    let parent: UIViewController
    let drop: Drop

    public enum Drop {
        case none
        case last
        case all
        case custom(Int)
    }

    init(target: UIViewController, parent: UIViewController, drop: Drop = .none) {
        self.target = target
        self.parent = parent
        self.drop = drop
    }

    public func move() {
        if let nc = parent.navigationController {
            self.present(self.target, using: nc)
        }
    }

    private func present(_ controller: UIViewController, using ncontroller: UINavigationController) {
        if ncontroller.topViewController == controller {
            return
        }

        switch self.drop {
        case .last:
            let controllers = Array(ncontroller.viewControllers.dropLast()) + [controller]
            ncontroller.setViewControllers(controllers, animated: true)
        case .all:
            ncontroller.setViewControllers([controller], animated: true)
        case let .custom(count):
            let controllers = Array(ncontroller.viewControllers.dropLast(count)) + [controller]
            ncontroller.setViewControllers(controllers, animated: true)
        default:
            ncontroller.pushViewController(controller, animated: true)
        }
    }
}

public final class ShowWindowRouter: ChaperoneRouter {
    let target: UIViewController
    let window: UIWindow
    let transition: WindowTransition

    init(target: UIViewController, window: UIWindow, transition: WindowTransition = FadeWindowTransition()) {
        self.target = target
        self.window = window
        self.transition = transition
    }

    public func move() {
        self.present(self.target, using: self.window)
    }

    private func present(_ controller: UIViewController, using window: UIWindow) {
        let windows = UIApplication.shared.windows.filter {
            $0 != window
        }
        for other in windows {
            self.transition.prepareForDissmiss(other)
            self.transition.animator
                .run(animation: {
                    self.transition.animateDissmiss(other)
                }, completion: {
                    other.isHidden = true
                    other.rootViewController?.dismiss(animated: false)
                })
        }
        if let old = window.rootViewController {
            old.dismiss(animated: false, completion: {
                old.view.removeFromSuperview()
            })
        }

        self.transition.prepareForShow(window)
        self.transition.animator.run(animation: {
            self.transition.animateShow(window)
        })

        window.rootViewController = controller
        window.makeKeyAndVisible()
    }
}

public class ShowChildRouter: ChaperoneRouter {
    let target: UIViewController
    let parent: UIViewController
    let container: UIView?

    init(target: UIViewController, parent: UIViewController, container: UIView? = nil) {
        self.target = target
        self.parent = parent
        self.container = container
    }

    public func move() {
        self.presentChild(self.target, from: self.parent, in: self.container)
    }

    private func presentChild(_ controller: UIViewController, from parent: UIViewController, in container: UIView?) {
        if let view = container ?? parent.view {
            let old = parent.children.first
            old?.view.removeFromSuperview()
            old?.removeFromParent()
            parent.addChild(controller)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(controller.view)
            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                controller.view.topAnchor.constraint(equalTo: view.topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            UIView.transition(with: view,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
        }
    }
}

public final class PresentRouter<T: UIPresentationController>: ModalRouter, UIViewControllerTransitioningDelegate {
    let presentation: T.Type
    let configure: ((T) -> Void)?

    init(target: UIViewController, from parent: UIViewController?, use presentation: T.Type, configure: ((T) -> Void)?) {
        self.presentation = presentation
        self.configure = configure
        super.init(target: target, parent: parent)
    }

    public override func move() {
        self.target.modalTransitionStyle = .crossDissolve
        self.target.modalPresentationStyle = .custom
        self.target.modalPresentationCapturesStatusBarAppearance = true
        self.target.transitioningDelegate = self
        super.move()
    }

    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        let value = presentation.init(presentedViewController: presented, presenting: presenting)
        self.configure?(value)
        return value
    }
}

// MARK: - Support classes

public final class MRWindow: UIWindow {
    class func create(level: UIWindow.Level? = nil,
                      frame: CGRect = UIScreen.main.bounds,
                      statusBarStyle: UIStatusBarStyle? = nil) -> UIWindow {
        let windowLavel = level ?? UIWindow.Level.alert + 1
        let alertWindow = MRWindow(frame: frame)
        let controller = MRViewController()
        let test = UIApplication.shared.windows.filter { $0.windowLevel < UIWindow.Level.alert && $0.isKeyWindow }.last
        let root = test?.rootViewController
        if let style = statusBarStyle {
            controller.style = style
        } else if let presented = root?.presentedViewController {
            if let style = (presented as? UINavigationController)?.viewControllers.last?.preferredStatusBarStyle {
                controller.style = style
            } else {
                controller.style = presented.preferredStatusBarStyle
            }
        } else if let style = (root as? UINavigationController)?.viewControllers.last?.preferredStatusBarStyle {
            controller.style = style
        } else if let style = root?.preferredStatusBarStyle {
            controller.style = style
        }

        alertWindow.rootViewController = controller
        alertWindow.windowLevel = windowLavel
        alertWindow.makeKeyAndVisible()
        return alertWindow
    }

    deinit {
        print("[D] MRWindow")
    }
}

private class MRViewController: UIViewController {
    var style: UIStatusBarStyle = .default
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
}
