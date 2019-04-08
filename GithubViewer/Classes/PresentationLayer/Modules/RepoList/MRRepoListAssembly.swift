import UIKit
import DITranquillity

final class RepoListPart: DIPart {
    static func load(container: DIContainer) {
        container.register1(RepoListPresenter.init)
            .as(RepoListEventHandler.self)
            .lifetime(.objectGraph)
    }
}

final class RepoListAssembly {
    class func createModule() -> RepoListViewController {
        let module = RepoListViewController()
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: RepoListRouter(view: module))
        return module
    }
}
