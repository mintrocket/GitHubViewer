import Foundation
import Kingfisher

extension UIImageView {
    public func setImage(from url: URL?,
                         placeholder: UIImage? = nil,
                         processor: ImageProcessor? = nil,
                         completionHandler: CompletionHandler? = nil) {
        var options: KingfisherOptionsInfo = [.transition(.fade(0.2))]
        if let item = processor {
            options.append(.processor(item))
        }
        self.kf.setImage(with: url,
                         placeholder: placeholder,
                         options: options,
                         completionHandler: completionHandler)
    }
}
