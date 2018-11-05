import Foundation

protocol InfinityLoadingEventHandler: class {
    func refresh()
    func loadMore()
}

protocol InfinityLoadingBehavior {
    func loadPageProgress(show: Bool)
}

extension InfinityLoadingEventHandler {
    func refresh() {}

    func loadMore() {}
}
