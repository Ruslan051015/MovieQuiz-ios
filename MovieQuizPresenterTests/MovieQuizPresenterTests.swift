
import XCTest
@testable import MovieQuiz



final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        <#code#>
    }
    
    func showLoadingIndicator() {
        <#code#>
    }
    
    func hideLoadingIndicator() {
        <#code#>
    }
    
    func disableButtons() {
        <#code#>
    }
    
    func enableButtons() {
        <#code#>
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        <#code#>
    }
    
    func doNotHighLightImageBorder() {
        <#code#>
    }
}

final class MovieQuizPresenterTest: XCTestCase {
    func testPresenterConvertModel() throws {
        //Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        //When
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        //Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
