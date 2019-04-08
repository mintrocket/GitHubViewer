import UIKit

final class RepoDetailAssembly {
    class func createModule(repo: Repo, parent: Router? = nil) -> RepoDetailViewController {
        let module: RepoDetailViewController = RepoDetailViewController()
        let router = RepoDetailRouter(view: module, parent: parent)
        module.handler = MainAppCoordinator.shared.container.resolve()
        module.handler.bind(view: module, router: router)
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
        let module = RepoDetailAssembly.createModule(repo: repo, parent: self)
        PushRouter(target: module, parent: self.controller).move()
    }
}
