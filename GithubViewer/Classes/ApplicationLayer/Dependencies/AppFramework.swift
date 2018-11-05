import Alamofire
import DITranquillity
import Foundation

public class AppFramework: DIFramework {
    public static func load(container: DIContainer) {
        container.append(part: OtherPart.self)
        container.append(part: RepositoriesPart.self)
        container.append(part: ServicesPart.self)
        container.append(part: ControllersPart.self)
    }
}

private class RepositoriesPart: DIPart {
    static let parts: [DIPart.Type] = [
        BackendRepositoryPart.self
    ]

    static func load(container: DIContainer) {
        for part in self.parts {
            container.append(part: part)
        }

        container.register1 {
            ClearableManagerImp(items: many($0))
        }
        .as(ClearableManager.self)
        .lifetime(.single)
    }
}

private class ServicesPart: DIPart {
    static let parts: [DIPart.Type] = [
        RepoServicePart.self
    ]

    static func load(container: DIContainer) {
        for part in self.parts {
            container.append(part: part)
        }
    }
}

// ONLY ANOTHER CONTROLLER PARTS
private class ControllersPart: DIPart {
    static let parts: [DIPart.Type] = [
        RepoListPart.self,
        RepoDetailPart.self
    ]

    static func load(container: DIContainer) {
        for part in self.parts {
            container.append(part: part)
        }
    }
}

private class OtherPart: DIPart {
    static func load(container: DIContainer) {
        container.register(AlertErrorHandler.init)
            .as(ErrorHandling.self)
            .lifetime(.single)

        container.register(SchedulerProviderImp.init)
            .as(SchedulerProvider.self)
            .lifetime(.single)


        // configuration
        container.register(Configuration.init)
            .as(ApiUrlHolder.self)
            .lifetime(.single)

        container.register1 {
            BackendConfiguration(holder: $0,
                                 converter: JsonResponseConverter(),
                                 interceptor: nil,
                                 retrier: nil)
            }
            .lifetime(.single)
    }
}
