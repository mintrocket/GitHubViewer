import Foundation

public final class Repo: NSObject, Decodable {
    let id: Int
    let name: String
    let desc: String?
    let owner: Owner?
    let url: URL?

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: String.self)
        self.id = values["id", default: 0]
        self.name = values["name", default: ""]
        self.owner = values["owner"]
        self.desc = values["description"]
        self.url = values["html_url"] <- URLConverter()
    }
}
