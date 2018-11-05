import UIKit

public protocol ViewControllerEventHandler: class {
    func didLoad()
    func willDisappear()
    func willClose()
    func openMenu()
}

extension ViewControllerEventHandler {
    public func didLoad() {}

    public func willDisappear() {}

    public func willClose() {}

    public func openMenu() {}
}
