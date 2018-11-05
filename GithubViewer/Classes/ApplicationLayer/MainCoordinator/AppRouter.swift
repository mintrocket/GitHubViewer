import UIKit

public class AppRouter {
    private var window: UIWindow!

    init() {}

    private func createWindow() -> UIWindow {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.backgroundColor = .white
        return self.window
    }

    public func openDefaultScene() {
        let module = RepoListAssembly.createModule()
        let nc = BaseNavigationController(rootViewController: module)

        ShowWindowRouter(target: nc,
                         window: self.createWindow()).move()
    }
}
