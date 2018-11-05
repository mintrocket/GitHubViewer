import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let dependencyConfiguration = DependenciesConfigurationBase(launchOptions: launchOptions)
        let coordinator = MainAppCoordinator(configuration: dependencyConfiguration)
        MainAppCoordinator.shared = coordinator
        coordinator.start()
        return true
    }
}
