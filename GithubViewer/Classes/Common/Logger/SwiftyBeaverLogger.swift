import SwiftyBeaver
import UIKit

class SwiftyBeaverLogger: LoggerType {
    fileprivate let loggerInstance = SwiftyBeaver.self

    init() {
        let console = ConsoleDestination()
        let file = FileDestination()
        loggerInstance.addDestination(console)
        loggerInstance.addDestination(file)
    }

    func log(_ level: LogLevel, tag: LogTag, className: String, _ message: String) {
        switch level {
        case .debug:
            self.loggerInstance
                .debug("------- \n [\(tag.rawValue)][\(className)] \n -> \(message) \n")
        case .error:
            self.loggerInstance
                .error("------- \n [\(tag.rawValue)][\(className)] \n -> \(message) \n")
        case .info:
            self.loggerInstance
                .info("------- \n [\(tag.rawValue)][\(className)] \n -> \(message) \n")
        case .warning:
            self.loggerInstance
                .warning("------- \n [\(tag.rawValue)][\(className)] \n -> \(message) \n)")
        default:
            self.loggerInstance
                .verbose("------- \n [\(tag.rawValue)][\(className)] \n -> \(message) \n")
        }
    }
}
