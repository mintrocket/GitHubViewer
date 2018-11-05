import UIKit

protocol ShareRoute {
    func openShare(url: URL)
}

extension ShareRoute where Self: RouterProtocol {
    func openShare(url: URL) {
        let module = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        ModalRouter(target: module, parent: self.controller).move()
    }
}
