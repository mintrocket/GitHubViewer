import UIKit
import DITranquillity

final class RepoDetailPart: DIPart {
    static func load(container: DIContainer) {
        container.register(RepoDetailPresenter.init)
            .as(RepoDetailEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class RepoDetailPresenter {

    private weak var view: RepoDetailViewBehavior!
    private var router: RepoDetailRoutable!

    private var repo: Repo!
}

public final class TestCommand: RouteCommand {}

extension RepoDetailPresenter: RepoDetailEventHandler {
    func bind(view: RepoDetailViewBehavior, router: RepoDetailRoutable) {
        self.view = view
        self.router = router
    }
    
    func moduleDidCreated(_ repo: Repo) {
        self.repo = repo
    }

    func didLoad() {
        self.view.set(title: self.repo.name)
        if let url = self.repo?.url {
            self.view.set(url: url)
        }
        self.router.execute(TestCommand())
    }

    func share() {
        if let url = self.repo?.url {
            self.router.openShare(url: url)
        }
    }
}
