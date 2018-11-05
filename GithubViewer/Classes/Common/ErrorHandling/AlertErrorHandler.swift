import Foundation

final class AlertErrorHandler: ErrorHandling {
    func handleError(error: Error) {
        MRAppAlertController.alert(Constants.Strings.error,
                                   message: error.message)
    }
}
