import Foundation
import UIKit

final class MovieQuizPresenter {
    // MARK: - Свойства
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    weak var viewController: MovieQuizViewController?
    
    
    // MARK: - Действия
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
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
