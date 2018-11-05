import IGListKit
import UIKit

// MARK: - View Controller

final class RepoListViewController: InfinityCollectionViewController {

    var handler: RepoListEventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addRefreshControl()
        self.handler.didLoad()
    }

    override func setupStrings() {
        super.setupStrings()
        self.navigationItem.title = Constants.Strings.github
    }

    override func refresh() {
        super.refresh()
        self.handler.refresh()
    }

    override func loadMore() {
        super.loadMore()
        self.handler.loadMore()
    }

    override func showLoading(fullscreen: Bool) {
        if fullscreen {
            super.showLoading(fullscreen: fullscreen)
        } else {
            self.startRefreshing()
        }
    }

    // MARK: - Adapter creators

    override func adapterCreators() -> [AdapterCreator] {
        return [
            RepoCellAdapterCreator(.init(select: { [weak self] item in
                self?.handler.select(value: item)
            }))
        ]
    }
}

extension RepoListViewController: RepoListViewBehavior {
    func set(items: [ListDiffable]) {
        self.items = items
        self.update()
    }

    func set(more items: [ListDiffable]) {
        self.items.append(contentsOf: items)
        self.update()
    }
}
