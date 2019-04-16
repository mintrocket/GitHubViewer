import UIKit

public protocol Loader {
    func start()
    func stop()
}

public final class MRLoaderManager: NSObject {
    public typealias LoaderView = UIView & Loader
    private static var shared: MRLoaderManager!
    private var type: LoaderView.Type
    private var globalHolder: ActivityGlobalHolder = .init()
    private var viewHolder: ActivityViewHolder = .init()
    
    private class func getWindow() -> UIWindow? {
        return UIApplication.shared.windows.filter { $0.windowLevel < UIWindow.Level.alert }.last
    }
    
    private init<T>(type: T.Type) where T: LoaderView {
        self.type = type
        super.init()
    }
    
    private func createView() -> (view: UIView, loader: Loader, activity: ActivityDisposable) {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let custom = self.type.init()
        custom.frame = view.bounds
        custom.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(custom)
        self.constraints(view: custom)
        
        let bag = ActivityBag { [weak self] in
            self?.updateFrame(for: view)
        }
        
        return (view, custom, bag)
    }
    
    public static func configure<T>(with type: T.Type) where T: LoaderView {
        MRLoaderManager.shared = MRLoaderManager(type: type)
    }
    
    public static func isLoading() -> Bool {
        return !self.shared.globalHolder.isEmpty() || !self.shared.viewHolder.isEmpty()
    }
    
    private func updateFrame(for view: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            view.frame = UIScreen.main.bounds
            let point = view.convert(CGPoint.zero, from: MRLoaderManager.getWindow())
            view.frame.origin.y = point.y
        }
    }
    
    // MARK: - Transition
    
    public class func show(with controller: UIViewController? = nil, animated: Bool = true) -> ActivityDisposable {
        let (view, loader, bag) = MRLoaderManager.shared.createView()
        var target: UIView?
        
        var resultBag: ActivityDisposable = bag
        if let targetView = controller?.view {
            if self.shared.viewHolder.isEmpty(view: targetView) {
                target = targetView
            }
            resultBag = self.shared.viewHolder.append(item: bag, for: targetView)
        } else {
            if self.shared.globalHolder.isEmpty() {
                target = self.getWindow()
            }
            resultBag = self.shared.globalHolder.append(bag)
        }
        
        view.alpha = 0
        target?.addSubview(view)
        
        if animated {
            UIView.animate(withDuration: 0.2) {
                view.alpha = 1
            }
        }
        MRLoaderManager.shared.updateFrame(for: view)
        
        resultBag.onDisposed {
            MRLoaderManager.hide(view: view, loader: loader)
        }
        loader.start()
        return bag
    }
    
    private class func hide(view: UIView, loader: Loader, delay: TimeInterval = 0, animated: Bool = true) {
        loader.stop()
        if animated {
            UIView.animate(withDuration: 0.4,
                           delay: delay,
                           animations: { view.alpha = 0 },
                           completion: { _ in view.removeFromSuperview() })
        } else {
            view.removeFromSuperview()
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

private class WeakRef<T: AnyObject>: Hashable {
    static func == (lhs: WeakRef<T>, rhs: WeakRef<T>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    private(set) weak var value: T?
    init(value: T?) {
        self.value = value
    }
    
    func hash(into hasher: inout Hasher) {
        if let value = self.value as? AnyHashable {
            hasher.combine(value)
        } else {
            hasher.combine(0)
        }
    }
}

public protocol ActivityDisposable: class {
    var uuid: UUID { get }
    func onDisposed(_ action: @escaping () -> Void)
}

public extension Array where Element == ActivityDisposable {
    mutating func append(_ item: ActivityDisposable?) {
        if let value = item {
            self.append(value)
        }
    }
    
    mutating func remove(_ item: ActivityDisposable?) {
        if let item = item {
            self.removeAll(where: { item.uuid == $0.uuid })
        }
    }
}

public final class ActivityBag: Hashable, ActivityDisposable {
    public private(set) var uuid: UUID = UUID()
    private var disposeHandlers: [() -> Void] = []
    private var rotateHandler: (() -> Void)?
    
    init() {}
    
    fileprivate init(rotated: (() -> Void)?) {
        self.rotateHandler = rotated
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.rotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    @objc private func rotated() {
        self.rotateHandler?()
    }
    
    public func onDisposed(_ action: @escaping () -> Void) {
        self.disposeHandlers.append(action)
    }
    
    public static func == (lhs: ActivityBag, rhs: ActivityBag) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.uuid)
    }
    
    deinit {
        let handlers = self.disposeHandlers
        DispatchQueue.main.async {
            handlers.forEach { $0() }
        }
        NotificationCenter.default.removeObserver(self)
    }
}

private final class ActivityGlobalHolder {
    private(set) var uuid: UUID = UUID()
    private weak var activity: ActivityDisposable?
    private var disposeHandler: (() -> Void)?
    
    func isEmpty() -> Bool {
        return self.activity == nil
    }
    
    func append(_ item: ActivityDisposable) -> ActivityDisposable {
        if let activity = self.activity {
            return activity
        }
        self.activity = item
        return item
    }
    
    func onDisposed(_ action: @escaping () -> Void) {
        if self.disposeHandler == nil {
            self.disposeHandler = action
        }
    }
}

private final class ActivityViewHolder {
    private(set) var uuid: UUID = UUID()
    private var references: [WeakRef<UIView>: WeakRef<AnyObject>] = [:]
    private var disposeHandler: (() -> Void)?
    
    private func update() {
        self.references = self.references
            .filter({ (_, value) -> Bool in
                value.value != nil
            })
    }
    
    func isEmpty(view: UIView) -> Bool {
        self.update()
        let key = WeakRef(value: view)
        return self.references[key] == nil
    }
    
    func isEmpty() -> Bool {
        self.update()
        return self.references.isEmpty
    }
    
    func append(item: ActivityDisposable, for view: UIView) -> ActivityDisposable {
        let key = WeakRef(value: view)
        self.update()
        if let activity = self.references[key]?.value as? ActivityDisposable {
            return activity
        }
        
        self.references[key] = WeakRef(value: item)
        return item
    }
}
