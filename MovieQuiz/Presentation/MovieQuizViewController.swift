import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Свойства
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var questionFactory: questionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    
    // MARK: - Аутлеты
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        showLoadinfIndicator()
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
    }
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
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
    /* Прописываем реализацию метода показа результата квиза
    private func show(quiz result: AlertModel) {
        let alertModel = AlertModel(title: result.title,
                                    message: result.message,
                                    buttonText:result.buttonText,
                                    completion: result.completion)
        alertPresenter?.show(model: alertModel)
        }*/
    
    // Реализация функции конвертирования
    private func convert(model: QuizQuestion)-> QuizStepViewModel {
       return QuizStepViewModel(
        image: UIImage(data: model.image) ?? UIImage(), //Распаковываем картинку
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
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: createAlertMessage(),
                buttonText: "Сыграть еще раз!") { [weak self] in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            alertPresenter?.show(model: viewModel)
        } else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
            }
        noButton.isEnabled = true
        yesButton.isEnabled = true
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
    // Реализация функции показа индикатора загрузки
    private func showLoadinfIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    // Реализация функции скрытия индикатора загрузки
    private func hideLoadinfIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    // Cоздаем функции показа ошибки с алертом
    private func showNetworkError(message: String) {
        hideLoadinfIndicator()
        let errorModel = AlertModel(
            title: "Ошибка",
            message: "Не удалось загрузить данные",
            buttonText: "Поробовать еще раз!") { [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.loadData() //requestNextQuestion()
            }
        alertPresenter?.show(model: errorModel)
    }
    // Реализация метода успешности загрузки данных с сервера
    func didLoadDataFromServer() {
        hideLoadinfIndicator()
        questionFactory?.requestNextQuestion()
    }
    // Реализация метода ошибки загрузки данных с сервера
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
