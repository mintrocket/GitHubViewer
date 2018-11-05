import UIKit

// MARK: - Presenter

final class RepoDetailPresenter {

    weak var view: RepoDetailViewBehavior!
    var router: RepoDetailRouter

    private var repo: Repo!

    init(view: RepoDetailViewBehavior,
         router: RepoDetailRouter) {
        self.view = view
        self.router = router
    }
}

extension RepoDetailPresenter: RepoDetailEventHandler {
    func moduleDidCreated(_ repo: Repo) {
        self.repo = repo
    }

    func didLoad() {
        self.view.set(title: self.repo.name)
        if let url = self.repo?.url {
            self.view.set(url: url)
        }
    }

    func share() {
        if let url = self.repo?.url {
            self.router.openShare(url: url)
        }
    }
}
