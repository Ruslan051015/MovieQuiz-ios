import Foundation
import UIKit

final class AlertPresenter {
    func show(viewController: UIViewController, model: AlertModel) {
        // Создает алерт(предупреждение)
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        // Создаем кнопку с действиями
        let action = UIAlertAction(title: model.buttonText, style: .default){ _ in
            model.completion?()
        }
        // Присваиваем accessibility Identifier
        alert.view.accessibilityIdentifier = "GameResults"
        // Добавляем кнопку в алерт
        alert.addAction(action)
        // Показываем алерт
        viewController.present(alert, animated: true)
    }
}
