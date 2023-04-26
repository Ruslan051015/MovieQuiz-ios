import Foundation

protocol MovieQuizPresenterProtocol {
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func didRecieveNextQuestion(question: QuizQuestion?)
    func noButtonClicked()
    func yesButtonClicked()
    func didAnswer(isCorrectAnswer: Bool)
    func showNetworkError(message: String)
    func isLastQuestion() -> Bool
    func restartGame()
    func switchToNextQuestion()
    func convert(model: QuizQuestion)-> QuizStepViewModel
}

