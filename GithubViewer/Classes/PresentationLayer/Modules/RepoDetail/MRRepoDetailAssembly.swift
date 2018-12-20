import UIKit
import DITranquillity

final class RepoDetailPart: DIPart {
    static func load(container: DIContainer) {
        container.register1(RepoDetailRouter.init)
            .lifetime(.objectGraph)

        container.register(RepoDetailPresenter.init)
            .as(RepoDetailEventHandler.self)
            .lifetime(.objectGraph)

        container.register {
                RepoDetailViewController()
            }
            .as(RepoDetailViewBehavior.self)
            .injection(cycle: true, { $0.handler = $1 })
            .lifetime(.objectGraph)
    }
}

final class RepoDetailAssembly {
    class func createModule(repo: Repo) -> RepoDetailViewController {
        let module: RepoDetailViewController = MainAppCoordinator.shared.container.resolve()
        module.handler.moduleDidCreated(repo)
        return module
    }
}

// MARK: - Route

protocol RepoDetailRoute {
    func openDetail(repo: Repo)
}

extension RepoDetailRoute where Self: RouterProtocol {
    func openDetail(repo: Repo) {
        let module = RepoDetailAssembly.createModule(repo: repo)
        PushRouter(target: module, parent: self.controller).move()
    }
}
