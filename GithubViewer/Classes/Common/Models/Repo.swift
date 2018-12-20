import Foundation

public final class Repo: NSObject, Codable {
    let id: Int
    let name: String
    let desc: String?
    let owner: Owner?
    let url: URL?

    public init(from decoder: Decoder) throws {
        self.id = decoder["id", default: 0]
        self.name = decoder["name", default: ""]
        self.owner = decoder["owner"]
        self.desc = decoder["description"]
        self.url = decoder["html_url"] <- URLConverter()
    }
    
    public func encode(to encoder: Encoder) throws {
        encoder.apply {
            $0["name"] = self.name
        }
    }
}
