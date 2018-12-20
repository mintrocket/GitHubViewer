import UIKit

protocol RouterProtocol: class {
    associatedtype ViewController: UIViewController
    var controller: ViewController! { get }
}

class BaseRouter<U>: RouterProtocol, ErrorHandlingRoute where U: UIViewController {
    typealias ViewController = U
    weak var controller: ViewController!

    init(view: ViewController) {
        self.controller = view
    }
}
