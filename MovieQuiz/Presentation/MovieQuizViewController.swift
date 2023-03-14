import UIKit

final class MovieQuizViewController: UIViewController {
// MARK: - Свойства
        private var currentQuestionIndex: Int = 0
        private var correctAnswers: Int = 0
//Вью модель для вопросов
            struct QuizQuestion {
                let image: String
                let text: String
                let correctAnswer: Bool
            }
//Вью модель для состояния "Вопрос задан"
                struct QuizStepViewModel {
                    let image: UIImage
                    let question: String
                    let questionNumber: String
                }
//Вью модель для состяния "Результат квиза"
                struct QuizResultsViewModel {
                    let title: String
                    let text: String
                    let buttonText: String
                }
// Выносим в константу вопрос с рейтингом
        static private let question = "Рейтинг этого фильма больше чем 6?"
//Cоздаем массив с моками
            private let questions: [QuizQuestion] = [QuizQuestion(
                                                        image: "The Godfather",
                                                        text: question,
                                                        correctAnswer: true),
                                                     QuizQuestion(
                                                        image: "The Dark Knight",
                                                        text: question,
                                                        correctAnswer: true),
                                                     QuizQuestion(
                                                        image: "Kill Bill",
                                                        text: question,
                                                        correctAnswer: true),
                                                     QuizQuestion(
                                                        image: "The Avengers",
                                                        text: question,
                                                        correctAnswer: true),
                                                     QuizQuestion(
                                                        image: "Deadpool",
                                                        text: question,
                                                        correctAnswer: true),
                                                     QuizQuestion(
                                                        image: "The Green Knight",
                                                        text: question,
                                                        correctAnswer: true),
                                                     QuizQuestion(
                                                        image: "Old",
                                                        text: question,
                                                        correctAnswer: false),
                                                     QuizQuestion(
                                                        image: "The Ice Age Adventures of Buck Wild",
                                                        text: question,
                                                        correctAnswer: false),
                                                     QuizQuestion(
                                                        image: "Tesla",
                                                        text: question,
                                                        correctAnswer: false),
                                                     QuizQuestion(
                                                        image: "Vivarium",
                                                        text: question,
                                                        correctAnswer: false)]
// MARK: - Аутлеты
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentQuestion = questions[currentQuestionIndex]
        imageView.layer.cornerRadius = 20
// Вызываем метод показа первого экрана, в аргумент закладываем первый вопрос массива
        show(quiz: convert(model: currentQuestion))
    }
// MARK: - Действия
        @IBAction private func noButtonClicked(_ sender: Any) {
            let currentQuestion = questions[currentQuestionIndex]
            let givenAnswer = false
            showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
        @IBAction private func yesButtonClicked(_ sender: Any) {
            let currentQuestion = questions[currentQuestionIndex]
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
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
// Сбрасываем счетчик правильных ответов на 0
            self.correctAnswers = 0
// Заново показываем первый вопрос
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
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
        questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
// Реализация функции показа результата после ответа на вопрос
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showNextQuestionOrResult()
//Убираем подсветку ответа после выбора варианта
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }
// Реализация функции показа следующего вопроса или результата
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш резульат \(correctAnswers) из 10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд закончен",
                text: text,
                buttonText: "Сыграть еще раз!")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }
}
