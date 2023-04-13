import Foundation
import UIKit

final class AlertPresenter: AlertPresenterProtocol {
   private  weak var delegate: UIViewController?
    init(delegate:UIViewController?) {
        self.delegate = delegate
    }
    func show(model: AlertModel) {
        // Создает алерт(предупреждение)
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        // Создаем кнопку с действиями
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: { _ in
            model.completion?()
        })
    // Добавляем кнопку в алерт
        alert.addAction(action)
    // Показываем алерт
        delegate?.present(alert, animated: true)
            }
}
