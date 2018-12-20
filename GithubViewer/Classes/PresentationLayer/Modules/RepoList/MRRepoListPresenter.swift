import UIKit

// MARK: - Presenter

final class RepoListPresenter {

    weak var view: RepoListViewBehavior!
    var router: RepoListRouter

    private let repoService: RepoService

    private var lastMessageId: Int?
    private lazy var paging: IdPaging = IdPaging { [weak self] in
        return self?.lastMessageId
    }

    private lazy var paginator: Paginator = Paginator<Repo, IdPaging>(paging) { [unowned self] id in
        return self.repoService.fetchRepos(since: id)
    }

    init(view: RepoListViewBehavior,
         router: RepoListRouter,
         repoService: RepoService) {
        self.view = view
        self.router = router
        self.repoService = repoService
    }
}

extension RepoListPresenter: RepoListEventHandler {
    func didLoad() {
        self.setupPaginator()
        self.refresh()
    }

    func refresh() {
        self.paginator.refresh()
    }

    func loadMore() {
        self.paginator.loadNewPage()
    }

    func select(value: Repo) {
        self.router.openDetail(repo: value)
    }

    //MARK: - Private

    private func setupPaginator() {
        let refreshAction: Action<Bool> = { [weak view] show in
            if show {
                view?.showLoading(fullscreen: false)
            } else {
                view?.hideLoading()
            }
        }

        self.paginator.handler
            .showData { [weak self] value in
                switch value.data {
                case let .first(items):
                    self?.loadMore()
                    self?.view.set(items: items)
                case let .next(items):
                    self?.view.set(more: items)
                }
            }
            .showErrorMessage { [weak view, weak router] error in
                view?.hideLoading()
                router?.show(error: error)
            }
            .showEmptyError { [weak view, weak router] value in
                view?.hideLoading()
                if let error = value.error {
                    router?.show(error: error)
                }
            }
            .showRefreshProgress(refreshAction)
            .showEmptyProgress(refreshAction)
    }
}
