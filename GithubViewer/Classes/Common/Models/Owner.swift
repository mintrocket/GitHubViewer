import Foundation

public final class Owner: Decodable {
    let id: Int
    let name: String?
    let avatar: URL?

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: String.self)
        self.id = values["id", default: 0]
        self.name = values["login"]
        self.avatar = values["avatar_url"] <- URLConverter()
    }
}
