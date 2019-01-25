import Foundation

public final class Owner: Decodable {
    var id: Int = 0
    var name: String?
    var avatar: URL?

    public init(from decoder: Decoder) throws {
        try decoder.apply { (values) in
            id <- values["id"]
            name <- values["login"]
            avatar <- (values["avatar_url"] <- URLConverter())
        }
    }
}
