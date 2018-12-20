import Foundation

public final class Owner: Decodable {
    let id: Int
    let name: String?
    let avatar: URL?

    public init(from decoder: Decoder) throws {
        self.id = decoder["id", default: 0]
        self.name = decoder["login"]
        self.avatar = decoder["avatar_url"] <- URLConverter()
    }
}
