import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func present(_ viewControllerToPresent: UIViewController)
}

