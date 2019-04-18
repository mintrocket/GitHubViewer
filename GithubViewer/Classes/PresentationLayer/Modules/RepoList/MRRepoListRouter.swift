import UIKit

// MARK: - Router
protocol RepoListRoutable: BaseRoutable, RepoDetailRoute {}

final class RepoListRouter: BaseRouter, RepoListRoutable {}
