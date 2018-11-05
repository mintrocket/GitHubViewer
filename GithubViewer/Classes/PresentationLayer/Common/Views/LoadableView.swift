import Foundation
import UIKit

public protocol NibLoadableProtocol: NSObjectProtocol {
    var nibContainerView: UIView { get }

    func loadNib() -> UIView?

    func setupNib()

    var nibName: String { get }
}

extension UIView {
    open var nibContainerView: UIView {
        return self
    }
}

extension NibLoadableProtocol {
    public var nibName: String {
        return String(describing: type(of: self))
    }

    public func loadNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
        return view
    }

    internal func setupView(_ view: UIView?, inContainer container: UIView) {
        if let view = view {
            container.backgroundColor = .clear
            container.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            let bindings = ["view": view]
            container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: bindings))
            container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: bindings))
        }
    }
}

open class LoadableView: UIView, NibLoadableProtocol {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }

    open func setupNib() {
        setupView(loadNib(), inContainer: nibContainerView)
    }
}

open class LoadableControl: UIControl, NibLoadableProtocol {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupNib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupNib()
    }

    open func setupNib() {
        setupView(loadNib(), inContainer: nibContainerView)
    }
}
