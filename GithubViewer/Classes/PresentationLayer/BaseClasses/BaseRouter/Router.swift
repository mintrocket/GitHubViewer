import UIKit

protocol RouterProtocol: class {
    associatedtype ViewController: UIViewController
    var controller: ViewController! { get }
}

class BaseRouter<U>: RouterProtocol where U: UIViewController {
    typealias ViewController = U

    weak var controller: ViewController!
    var errorHandler: ErrorHandling?

    init(view: ViewController, errorHandler: ErrorHandling? = nil) {
        self.controller = view
        self.errorHandler = errorHandler
    }

    func handle(error: Error) {
        self.errorHandler?.handleError(error: error)
    }
}
