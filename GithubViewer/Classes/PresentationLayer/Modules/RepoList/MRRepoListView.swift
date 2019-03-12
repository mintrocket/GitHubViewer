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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.reload()
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
    func pageLoading(show: Bool) {
        if show {
            self.startRefreshing()
        } else {
            self.stopRefreshing()
        }
    }
    
    func set(items: [ListDiffable]) {
        self.items = items
        self.update()
    }

    func set(more items: [ListDiffable]) {
        self.items.append(contentsOf: items)
        self.update()
    }
}
