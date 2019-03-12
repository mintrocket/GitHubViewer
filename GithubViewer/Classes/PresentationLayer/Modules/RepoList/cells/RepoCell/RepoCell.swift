import UIKit

public final class RepoCell: RippleViewCell {
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var ownerNameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var repoNameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    @discardableResult
    func configure(_ item: Repo) -> RepoCell {
        self.avatarView.setImage(from: item.owner?.avatar)
        self.ownerNameLabel.text = item.owner?.name
        self.numberLabel.text = "\(item.id)"
        self.repoNameLabel.text = item.name
        self.descriptionLabel.text = item.desc
        self.setNeedsLayout()
        return self
    }

    @discardableResult
    func layout() -> CGFloat {
        self.descriptionLabel.pin.horizontally(26)
            .top(80).sizeToFit(.width)
        return self.descriptionLabel.frame.maxY + 30
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layout()
    }
}
