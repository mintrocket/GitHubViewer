import DITranquillity
import Foundation
import RxSwift
import UIKit

open class MainAppCoordinator: Loggable {
    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    public static var shared: MainAppCoordinator!

    open var configuration: DependenciesConfiguration
    open var container: DIContainer

    private let router: AppRouter

    init(configuration: DependenciesConfiguration) {
        self.configuration = configuration
        self.configuration.setup()
        self.container = self.configuration.configuredContainer()
        self.router = AppRouter()

        self.log(.debug, "Dependencies are configured")
    }

    func start() {
        MainTheme.shared.apply()
        self.log(.debug, "App coordinator started")
        self.openMainModule()
    }

    // MARK: - Modules routing

    private func openMainModule() {
        self.router.openDefaultScene()
    }
}
