import UIKit

final class MovieQuizViewController: UIViewController {
// MARK: - Свойства
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private let questionFactory: questionFactoryProtocol = QuestionFactory() 
    private var currentQuestion: QuizQuestion?
    

// MARK: - Аутлеты
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
        imageView.layer.cornerRadius = 20
    }
// MARK: - Действия
        @IBAction private func noButtonClicked(_ sender: Any) {
            guard let currentQuestion = currentQuestion else { return }
            let givenAnswer = false
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
        @IBAction private func yesButtonClicked(_ sender: Any) {
            guard let currentQuestion = currentQuestion else { return }
            let givenAnswer = true
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
// MARK: - Other funcs: Прописываем реализацию метода показа первого экрана
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
   }
// Прописываем реализацию метода показа результата квиза
    private func show(quiz result: QuizResultsViewModel) {
// Создает алерт(предупреждение)
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
// Создаем кнопку с действиями
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
// Сбрасываем счетчик правильных ответов на 0
            self.correctAnswers = 0
// Заново показываем первый вопрос
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
        }
// Добавляем кнопку в алерт
        alert.addAction(action)
// Показываем алерт
        self.present(alert, animated: true, completion: nil)
    }
// Реализация функции конвертирования
    private func convert(model: QuizQuestion)-> QuizStepViewModel {
       return QuizStepViewModel(
        image: UIImage(named: model.image) ?? UIImage(), //Распаковываем картинку
        question: model.text, // Берем текст вопроса
        questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
// Реализация функции показа результата после ответа на вопрос
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResult()
//Убираем подсветку ответа после выбора варианта
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
// Реализация функции показа следующего вопроса или результата
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = "Ваш резульат \(correctAnswers) из 10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд закончен",
                text: text,
                buttonText: "Сыграть еще раз!")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                show(quiz: viewModel)
            }
        }
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
}
