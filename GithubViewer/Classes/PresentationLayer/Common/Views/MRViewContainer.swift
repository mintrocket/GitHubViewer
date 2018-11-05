import UIKit

public protocol Loader {
    func start()
    func stop()
}

public class MRViewContainer: NSObject {
    public typealias LoaderView = UIView & Loader
    private static var shared: MRViewContainer!

    private var view: UIView!
    private var loader: LoaderView!
    private weak var target: UIViewController?
    private weak var loaderView: UIView?

    private var loading: Bool = false

    private class func getWindow() -> UIWindow? {
        return UIApplication.shared.windows.filter { $0.windowLevel < UIWindow.Level.alert }.last
    }

    public class func isLoading() -> Bool {
        return MRViewContainer.shared.loading
    }

    public class func getLoaderView() -> UIView? {
        return self.shared.loaderView
    }

    private init<T>(type: T.Type) where T: LoaderView {
        super.init()
        self.view = UIView(frame: UIScreen.main.bounds)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.rotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        let custom = type.init()
        custom.frame = view.bounds
        custom.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(custom)
        self.loader = custom
        self.constraints(view: custom)
        self.loaderView = custom
    }

    @objc private func rotated() {
        self.updateFrame()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public static func configure<T>(with type: T.Type) where T: LoaderView {
        MRViewContainer.shared = MRViewContainer(type: type)
    }

    private func updateFrame() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) { [unowned self] in
            self.view.frame = UIScreen.main.bounds
            let point = self.view.convert(CGPoint.zero, from: MRViewContainer.getWindow())
            self.view.frame.origin.y = point.y
        }
    }

    // MARK: - Transition

    open class func show(with target: UIViewController? = nil, animated: Bool = true) {
        if let view = MRViewContainer.shared.view {
            MRViewContainer.shared.loader.start()
            MRViewContainer.shared.loading = true
            MRViewContainer.shared.target = target
            let target = target?.view ?? self.getWindow()

            view.alpha = 0
            if view.superview != nil {
                view.removeFromSuperview()
            }

            target?.addSubview(view)

            if animated {
                UIView.animate(withDuration: 0.2) {
                    view.alpha = 1
                }
            } else {
                view.alpha = 1
            }
            MRViewContainer.shared.updateFrame()
        }
    }

    open class func hide(delay: TimeInterval = 0, animated: Bool = true, completed: (() -> Void)? = nil) {
        if let view = MRViewContainer.shared.view {
            MRViewContainer.shared.loader.stop()
            MRViewContainer.shared.loading = false
            if animated {
                UIView.animate(withDuration: 0.4,
                               delay: delay,
                               animations: {
                                   view.alpha = 0
                               },
                               completion: { _ in
                                   view.removeFromSuperview()
                                   completed?()
                })
            } else {
                view.removeFromSuperview()
                completed?()
            }
        }
    }

    fileprivate func constraints(view: UIView) {
        let views = ["view": view]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                 options: [],
                                                                 metrics: nil,
                                                                 views: views)
        NSLayoutConstraint.activate(horizontalConstraints + verticalConstraints)
    }
}
