import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func disableButtons()
    func enableButtons()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func doNotHighLightImageBorder()
}
