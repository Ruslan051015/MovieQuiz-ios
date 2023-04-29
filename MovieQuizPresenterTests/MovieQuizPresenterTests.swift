
import XCTest
@testable import MovieQuiz



final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func showResult() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func disableButtons() {
        
    }
    
    func enableButtons() {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func doNotHighLightImageBorder() {
        
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
