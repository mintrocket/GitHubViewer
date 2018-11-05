import UIKit

public class MRLoaderView: LoadableView, Loader {
    @IBOutlet var indicator: SpringIndicator!

    private var initialFrame: CGRect!

    public func start() {
        self.indicator.start()
    }

    public func stop() {
        self.indicator.stop()
    }
}
