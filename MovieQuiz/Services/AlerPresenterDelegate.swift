import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func present(_ viewControllerToPresent: UIViewController)
}

extension AlertPresenterDelegate {
    func present(_ viewControllerToPresent: UIViewController){print("AlerpresenterDElegate")}
}
