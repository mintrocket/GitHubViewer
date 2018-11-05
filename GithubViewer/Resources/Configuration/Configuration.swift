import UIKit

public enum AppMode: String {
    case debug
    case adhoc
    case release
}

public struct Configuration {
    public var appMode: AppMode?

    private static let configFilename = "AppConfiguration"
    private static let infoConfigKey = "AppConfig"

    var configs: NSDictionary?

    init() {
        let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: Configuration.infoConfigKey)!
        let path = Bundle.main.path(forResource: Configuration.configFilename, ofType: "plist")!
        configs = NSDictionary(contentsOfFile: path)?.object(forKey: currentConfiguration) as? NSDictionary
        self.appMode = AppMode(rawValue: (currentConfiguration as? String)?.lowercased() ?? "none")
    }

    public func string(_ key: String) -> String {
        let value = self.configs?[key] as? String
        return value ?? ""
    }

    public func integer(_ key: String) -> Int {
        let value = self.configs?[key] as? Int
        return value ?? 0
    }
}

extension Configuration: ApiUrlHolder {
    public func apiUrl() -> String {
        return self.string("ApiUrl")
    }
}
