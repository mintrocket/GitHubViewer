import UIKit

// MARK: - Contracts

protocol RepoDetailViewBehavior: WaitingBehavior {
    func set(title: String)
    func set(url: URL)
}

protocol RepoDetailEventHandler: ViewControllerEventHandler {
    func moduleDidCreated(_ repo: Repo)
    func share()
}
