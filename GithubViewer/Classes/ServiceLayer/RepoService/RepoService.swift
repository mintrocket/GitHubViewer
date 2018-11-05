import DITranquillity
import Foundation
import RxCocoa
import RxSwift

class RepoServicePart: DIPart {
    static func load(container: DIContainer) {
        container.register(RepoServiceImp.init)
            .as(RepoService.self)
            .lifetime(.perRun(.weak))
    }
}

protocol RepoService {
    func fetchRepos(since id: Int?) -> Single<[Repo]>
}

final class RepoServiceImp: RepoService {
    let schedulers: SchedulerProvider
    let backendRepository: BackendRepository

    init(schedulers: SchedulerProvider,
         backendRepository: BackendRepository) {
        self.schedulers = schedulers
        self.backendRepository = backendRepository
    }

    func fetchRepos(since id: Int?) -> Single<[Repo]> {
        return Single.deferred { [unowned self] in
            let request = RepositoriesRequest(since: id)
            return self.backendRepository
                .request(request)
                .map { $0.data }
        }
            .subscribeOn(self.schedulers.background)
            .observeOn(self.schedulers.main)
    }
}
