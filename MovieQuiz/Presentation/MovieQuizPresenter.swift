import Foundation
import UIKit

final class MovieQuizPresenter {
    // MARK: - Свойства
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticService?
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    weak var viewController: MovieQuizViewController?
    
    
    // MARK: - Действия
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    func yesButtonClicked() {
        didAnswer(isYes: true)
        
    }
    // MARK: - Методы
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    // Реализация функции показа следующего вопроса или результата
     func showNextQuestionOrResult() {
         if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers,
                                    total: questionsAmount)
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: createAlertMessage(),
                buttonText: "Сыграть еще раз!") { [weak self] in
                    guard let self = self else { return }
                    self.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
             self.viewController?.alertPresenter?.show(model: viewModel)
        } else {
            self.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
        }
         self.viewController?.enableButtons()
    }
    // Реализация функции формирования сообщения
    private func createAlertMessage() -> String {
        guard let statisticService = statisticService,
              let bestGame = statisticService.bestGame else {
            assertionFailure("Нет сохраненных данных")
            return ""
        }
        let totalGamesCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let resultMessage = [currentGameResultLine, totalGamesCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        return resultMessage
    }
    // Выносим логику изменения свойств в функции
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
