import IGListKit
import UIKit

// MARK: - Contracts

protocol RepoListViewBehavior: WaitingBehavior {
    func set(items: [ListDiffable])
    func set(more items: [ListDiffable])
    func pageLoading(show: Bool)
}

protocol RepoListEventHandler: ViewControllerEventHandler, InfinityLoadingEventHandler {
    func bind(view: RepoListViewBehavior, router: RepoListRoutable)
    func select(value: Repo)
}
