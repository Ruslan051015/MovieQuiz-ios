import Foundation
import UIKit

class AlertPresenter: AlertPresenterProtocol {
   private  weak var delegate: AlertPresenterDelegate?
    init(delegate:AlertPresenterDelegate?) {
        self.delegate = delegate
    }
    func show(model: AlertModel) {
        // Создает алерт(предупреждение)
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        // Создаем кнопку с действиями
        let action = UIAlertAction(title: model.buttonText, style: .default) 
    // Добавляем кнопку в алерт
        alert.addAction(action)
    // Показываем алерт
        delegate?.present(alert)
    }
}
