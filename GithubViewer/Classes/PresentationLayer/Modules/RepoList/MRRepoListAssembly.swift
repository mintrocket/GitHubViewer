import UIKit
import DITranquillity

final class RepoListPart: DIPart {
    static func load(container: DIContainer) {
        container.register(RepoListRouter.init)
            .lifetime(.objectGraph)

        container.register(RepoListPresenter.init)
            .as(RepoListEventHandler.self)
            .lifetime(.objectGraph)

        container.register {
                RepoListViewController()
            }
            .as(RepoListViewBehavior.self)
            .injection(cycle: true, { $0.handler = $1 })
            .lifetime(.objectGraph)
    }
}

final class RepoListAssembly {
    class func createModule() -> RepoListViewController {
        let module: RepoListViewController = MainAppCoordinator.shared.container.resolve() 
        return module
    }
}
