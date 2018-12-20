import UIKit

public struct Configuration {
    #if DEBUG
    static let server = "https://api.github.com"
    #else
    static let server = "https://api.github.com"
    #endif
}
