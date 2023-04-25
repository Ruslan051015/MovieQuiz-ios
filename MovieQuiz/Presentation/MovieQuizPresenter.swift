import Foundation
import UIKit

final class MovieQuizPresenter {
    // MARK: - Свойства
    private var currentQuestionIndex: Int = 0
    let questionsAmount: Int = 10
    
    // MARK: - Методы
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // Реализация метода конвертирования
    func convert(model: QuizQuestion)-> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(), //Распаковываем картинку
            question: model.text, // Берем текст вопроса
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}
