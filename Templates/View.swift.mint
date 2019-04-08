import UIKit

// MARK: - View Controller

final class {{ name }}ViewController: BaseViewController {

    var handler: {{ name }}EventHandler!

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension {{ name }}ViewController: {{ name }}ViewBehavior {

}
