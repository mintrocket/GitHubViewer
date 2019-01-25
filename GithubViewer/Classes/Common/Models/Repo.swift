import Foundation

public final class Repo: NSObject, Codable {
    var id: Int = 0
    var name: String = ""
    var desc: String?
    var owner: Owner?
    var url: URL?

    public init(from decoder: Decoder) throws {
        super.init()
        try decoder.apply { (values) in
            id <- values["id"]
            name <- values["name"]
            desc <- values["description"]
            owner <- values["owner"]
            url <- (values["html_url"] <- URLConverter())
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        encoder.apply {
            $0["id"] = self.id
            $0["name"] = self.name
        }
    }
}
