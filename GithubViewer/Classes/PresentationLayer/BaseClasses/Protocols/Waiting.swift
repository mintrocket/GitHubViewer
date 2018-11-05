import UIKit

public protocol WaitingBehavior: class {
    func showLoading(fullscreen: Bool)
    func hideLoading()
}

extension WaitingBehavior where Self: UIViewController {
    func isLoading() -> Bool {
        return MRViewContainer.isLoading()
    }

    public func showLoading(fullscreen: Bool) {
        var target: UIViewController?
        if !fullscreen {
            target = self
        }
        MRViewContainer.show(with: target)
    }

    public func hideLoading() {
        MRViewContainer.hide()
    }
}
