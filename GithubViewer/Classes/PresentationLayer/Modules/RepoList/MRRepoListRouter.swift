import UIKit

// MARK: - Router
protocol RepoListRoutable: BaseRouter, RepoDetailRoute {}

final class RepoListRouter: BaseRouter, RepoListRoutable {}
