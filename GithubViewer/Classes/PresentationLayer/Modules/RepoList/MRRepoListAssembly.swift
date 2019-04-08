import UIKit

final class RepoListAssembly {
    class func createModule() -> RepoListViewController {
        let module = RepoListViewController()
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: RepoListRouter(view: module))
        return module
    }
}
