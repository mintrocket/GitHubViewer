public struct RepositoriesRequest: BackendAPIRequest {
    typealias ResponseObject = [Repo]

    private(set) var endpoint: String = "/repositories"
    private(set) var method: NetworkManager.Method = .GET
    private(set) var parameters: [String: Any] = [:]

    init(since id: Int?) {
        if let value = id {
            self.parameters["since"] = value
        }
    }
}
