import IGListKit
import UIKit

final class RepoCellAdapterCreator: BaseInteractiveAdapterCreator<Repo, RepoCellAdapter> {}

struct RepoCellAdapterHandler {
    let select: Action<Repo>?
}

public final class RepoCellAdapter: ListSectionController, Interactable {
    typealias Handler = RepoCellAdapterHandler
    var handler: Handler?

    private var item: Repo!
    private var size: CGSize = .zero

    private static let template = RepoCell.loadFromNib(frame: UIScreen.main.bounds)!

    public override func sizeForItem(at index: Int) -> CGSize {
        return size
    }

    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        let cell = collectionContext?.dequeueReusableCell(withNibName: RepoCell.className(),
                                                          bundle: nil,
                                                          for: self,
                                                          at: index) as? RepoCell
        cell?.configure(self.item)
        return cell!
    }

    public override func didUpdate(to object: Any) {
        self.item = object as? Repo
        let width: CGFloat = collectionContext!.containerSize.width
        let height: CGFloat = self|.template
            .configure(item)
            .layout()
        self.size = CGSize(width: width, height: height)
    }

    public override func didSelectItem(at index: Int) {
        self.handler?.select?(self.item)
    }
}

