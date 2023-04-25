import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Свойства
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    let questionsAmount: Int = 10
    private var alertPresenter: AlertPresenterProtocol?
    private let statisticService: StatisticService!
    private var currentQuestionIndex: Int = 0
    private weak var viewController: MovieQuizViewController?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        alertPresenter = AlertPresenter(delegate: viewController)
        viewController.showLoadingIndicator()
    }
    // MARK: - QuestionFactoryDelegate
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        showNetworkError(message: message)
    }
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
        
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    // Реализация функции показа результата после ответа на вопрос
    func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            //Убираем подсветку ответа после выбора варианта
            viewController?.doNotHighLightImageBorder()
        }
        viewController?.disableButtons()
    }
    // Реализация функции показа следующего вопроса или результата
    func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers,
                                    total: questionsAmount)
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: createAlertMessage(),
                buttonText: "Сыграть еще раз!") { [weak self] in
                    guard let self = self else { return }
                    self.restartGame()
                }
            alertPresenter?.show(model: viewModel)
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
    
    // Cоздаем функции показа ошибки с алертом
    func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        let errorModel = AlertModel(
            title: "Ошибка",
            message: "Не удалось загрузить данные",
            buttonText: "Поробовать еще раз!") { [weak self] in
                guard let self = self else { return }
                restartGame()
            }
        alertPresenter?.show(model: errorModel)
    }
    
    // Выносим логику изменения свойств в функции
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
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
