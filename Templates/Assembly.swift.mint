import UIKit

final class {{ name }}Assembly {
    class func createModule(parent: Router? = nil) -> {{ name }}ViewController {
        let module = {{ name }}ViewController() 
        let router = {{ name }}Router(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
        return module
    }
}

// MARK: - Route

protocol {{ name }}Route {}

extension {{ name }}Route where Self: RouterProtocol {}
