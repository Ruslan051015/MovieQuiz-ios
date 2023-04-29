import Foundation

protocol MovieQuizPresenterProtocol {
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
    func didRecieveNextQuestion(question: QuizQuestion?)
    func noButtonClicked()
    func yesButtonClicked()
    func didAnswer(isCorrectAnswer: Bool)
    func isLastQuestion() -> Bool
    func restartGame()
    func switchToNextQuestion()
    func convert(model: QuizQuestion)-> QuizStepViewModel
    func loadDataFromQuestionFactory()
    func createAlertMessage() -> String
}

