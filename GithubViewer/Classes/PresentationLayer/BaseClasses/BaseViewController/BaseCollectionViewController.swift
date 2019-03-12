import Foundation
import IGListKit

class BaseCollectionViewController: BaseViewController, ListAdapterDataSource {
    // MARK: - Outlets

    @IBOutlet var collectionView: UICollectionView!
    var items: [ListDiffable] = []

    // MARK: - Properties

    public private(set) var refreshControl: RefreshIndicator?

    var defaultBottomInset: CGFloat = 40

    public lazy var adapter: ListAdapter = {
        ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()

    public var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return self.adapter.scrollViewDelegate
        }
        set {
            self.adapter.scrollViewDelegate = newValue
        }
    }

    private lazy var manager: AdapterManager = { [unowned self] in
        AdapterManager(items: self.adapterCreators())
    }()

    // MARK: - Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        self.adapter.collectionView = self.collectionView
        self.collectionView.contentInset.bottom = self.defaultBottomInset
        self.adapter.dataSource = self
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateRefreshControlRect()
    }

    // MARK: - Refresh

    public func addRefreshControl(color: UIColor = MainTheme.shared.black) {
        if self.refreshControl != nil {
            return
        }
        self.collectionView.alwaysBounceVertical = true
        self.refreshControl = RefreshIndicator(style: .prominent)
        self.refreshControl?.indicator.lineColor = color
        self.collectionView.addSubview(self.refreshControl!)
        self.refreshControl?.addTarget(self,
                                       action: #selector(self.refresh),
                                       for: .valueChanged)
    }

    public func removeRefreshControl() {
        self.refreshControl?.removeFromSuperview()
        self.refreshControl = nil
    }

    public func updateRefreshControlRect() {
        self.refreshControl?.center.x = self.collectionView.bounds.width / 2
    }

    public func stopRefreshing() {
        self.refreshControl?.endRefreshing()
        self.collectionView.isUserInteractionEnabled = true
    }

    public func startRefreshing() {
        self.refreshControl?.startRefreshing()
    }

    public func isRefreshing() -> Bool {
        return self.refreshControl?.isRefreshing ?? false
    }

    @objc
    public func refresh() {
        self.collectionView.isUserInteractionEnabled = false
        // override me
    }

    // MARK: - Methods

    public func adapterCreators() -> [AdapterCreator] {
        fatalError("Override me")
    }

    public func updateContentBody(bottomInset: CGFloat? = nil,
                                  minOffset: CGFloat? = nil) {
        let beforeContentOffset = self.collectionView.contentOffset.y
        self.collectionView.contentInset.bottom = bottomInset ?? self.defaultBottomInset
        if let offset = minOffset {
            let value = min(offset, beforeContentOffset)
            self.collectionView.contentOffset = .init(x: self.collectionView.contentOffset.x,
                                                      y: value)
        }
    }

    public func update(animated: Bool = true,
                       completion: ListUpdaterCompletion? = nil) {
        self.adapter.performUpdates(animated: animated, completion: completion)
    }

    public func reload(completion: ListUpdaterCompletion? = nil) {
        self.adapter.reloadData(completion: completion)
    }

    // MARK: - IGListAdapterDataSource

    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return self.items
    }

    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return self.manager.adapter(from: object)
    }

    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

class InfinityCollectionViewController: BaseCollectionViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollViewDelegate = self
    }

    public func loadMore() {
        // override me
    }
}

// MARK: - UIScrollViewDelegate

extension InfinityCollectionViewController: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let distance = scrollView.contentSize.height - (targetContentOffset.pointee.y + scrollView.bounds.height)
        if distance < 200 {
            self.loadMore()
        }
    }
}
