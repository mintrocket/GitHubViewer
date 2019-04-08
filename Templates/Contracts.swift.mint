import UIKit

// MARK: - Contracts

protocol {{ name }}ViewBehavior: class {

}

protocol {{ name }}EventHandler: class {
    func bind(view: {{ name }}ViewBehavior, router: {{ name }}Routable)
}
