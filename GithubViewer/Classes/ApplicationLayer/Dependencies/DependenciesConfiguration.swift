import DITranquillity
import Kingfisher
import UIKit

public protocol DependenciesConfiguration: class {
    func setup()
    func configuredContainer() -> DIContainer
}

open class DependenciesConfigurationBase: DependenciesConfiguration, Loggable {
    private var options: [UIApplication.LaunchOptionsKey: Any]?

    init(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.options = launchOptions
    }

    // MARK: - Configure

    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    public func configuredContainer() -> DIContainer {
        let container = DIContainer()
        container.append(framework: AppFramework.self)
        if !container.validate() {
            fatalError()
        }
        return container
    }

    // MARK: - Setup

    public func setup() {
        self.setupLoader()
        self.setupModulesDependencies()
    }

    public func setupModulesDependencies() {
        // logger
        let logger = Logger()
        let swiftyLogger = SimpleLogger()
        logger.setupLogger(swiftyLogger)
        Logger.setSharedInstance(logger)
    }

    func setupLoader() {
        MRLoaderManager.configure(with: MRLoaderView.self)
    }
}
