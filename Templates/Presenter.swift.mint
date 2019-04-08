import UIKit
import DITranquillity

final class {{ name }}Part: DIPart {
    static func load(container: DIContainer) {
        container.register({{ name }}Presenter.init)
            .as({{ name }}EventHandler.self)
            .lifetime(.objectGraph)
    }
}

// MARK: - Presenter

final class {{ name }}Presenter {
    private weak var view: {{ name }}ViewBehavior!
    private var router: {{ name }}Router!
}

extension {{ name }}Presenter: {{ name }}EventHandler {
	func bind(view: {{ name }}ViewBehavior, router: {{ name }}Routable) {
        self.view = view
        self.router = router
    }
}
