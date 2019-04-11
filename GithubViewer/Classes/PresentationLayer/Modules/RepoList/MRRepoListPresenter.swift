import UIKit
import DITranquillity

final class RepoListPart: DIPart {
    static func load(container: DIContainer) {
        container.register1(RepoListPresenter.init)
            .as(RepoListEventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter
final class RepoListPresenter {

    private weak var view: RepoListViewBehavior!
    private var router: RepoListRoutable!

    private let repoService: RepoService

    private var lastMessageId: Int?
    private lazy var paging: IdPaging = IdPaging { [weak self] in
        return self?.lastMessageId
    }

    private lazy var paginator: Paginator = Paginator<Repo, IdPaging>(paging) { [unowned self] id in
        return self.repoService.fetchRepos(since: id)
    }

    init(repoService: RepoService) {
        self.repoService = repoService
    }
}

extension RepoListPresenter: RouterCommandResponder {
    func respond(command: RouteCommand) -> Bool {
        if command is TestCommand {
            print("TEST COMMAND EXECUTED")
        }
        return false
    }
}

extension RepoListPresenter: RepoListEventHandler {
    func bind(view: RepoListViewBehavior, router: RepoListRoutable) {
        self.view = view
        self.router = router
        self.router.responder = self
    }
    
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
             view?.pageLoading(show: show)
        }
        
        var activity: ActivityDisposable?
        _ = activity
        let emptyLoadAction: Action<Bool> = { [weak view] show in
            if show {
                activity = view?.showLoading(fullscreen: false)
            } else {
                activity = nil
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
                view?.pageLoading(show: false)
                router?.show(error: error)
            }
            .showEmptyError { [weak router] value in
                activity = nil
                if let error = value.error {
                    router?.show(error: error)
                }
            }
            .showRefreshProgress(refreshAction)
            .showEmptyProgress(emptyLoadAction)
    }
}
