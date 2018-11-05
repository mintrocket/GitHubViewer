import IGListKit
import UIKit

// MARK: - Contracts

protocol RepoListViewBehavior: WaitingBehavior {
    func set(items: [ListDiffable])
    func set(more items: [ListDiffable])
}

protocol RepoListEventHandler: ViewControllerEventHandler, InfinityLoadingEventHandler {
    func select(value: Repo)
}
