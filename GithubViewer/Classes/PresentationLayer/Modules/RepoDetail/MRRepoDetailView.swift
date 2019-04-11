import UIKit
import WebKit

// MARK: - View Controller

final class RepoDetailViewController: BaseViewController {

    var handler: RepoDetailEventHandler!
    private var activityBag: ActivityDisposable?

    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self
        webView.alpha = 0
        self.view.addSubview(webView)
        return webView
    }()

    private lazy var shareButton: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .action,
                                   target: self,
                                   action: #selector(self.shareTapped))
        return item
    }()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.handler.didLoad()
        self.setupNavigationItems()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.webView.pin.all()
    }

    func setupNavigationItems() {
        self.navigationItem.setRightBarButtonItems([self.shareButton], animated: false)
    }

    // MARK: - Actions

    @objc func shareTapped() {
        if self.isLoading == false {
            self.handler.share()
        }
    }
}

extension RepoDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityBag = nil
        UIView.animate(withDuration: 0.3) {
            self.webView.alpha = 1
        }
    }
}

extension RepoDetailViewController: RepoDetailViewBehavior {
    func set(title: String) {
        self.navigationItem.title = title
    }
    
    func set(url: URL) {
        self.webView.load(URLRequest(url: url))
        self.activityBag = self.showLoading(fullscreen: false)
    }
}
