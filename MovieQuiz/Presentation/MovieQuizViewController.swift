import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - Свойства
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticService?
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
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
        showLoadingIndicator()
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        presenter.viewController = self
    }
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    // MARK: - Действия
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
       
        
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    // MARK: - Other funcs: Прописываем реализацию метода показа первого экрана
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Реализация функции показа результата после ответа на вопрос
     func showAnswerResult(isCorrect: Bool) {
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
        if presenter.isLastQuestion() {
            statisticService?.store(correct: correctAnswers,
                                    total: presenter.questionsAmount)
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: createAlertMessage(),
                buttonText: "Сыграть еще раз!") { [weak self] in
                    guard let self = self else { return }
                    presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                }
            alertPresenter?.show(model: viewModel)
        } else {
            presenter.switchToNextQuestion()
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
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total)"
        + " (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let resultMessage = [currentGameResultLine, totalGamesCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
        return resultMessage
    }
    // Реализация функции показа индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    // Реализация функции скрытия индикатора загрузки
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    // Cоздаем функции показа ошибки с алертом
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let errorModel = AlertModel(
            title: "Ошибка",
            message: "Не удалось загрузить данные",
            buttonText: "Поробовать еще раз!") { [weak self] in
                guard let self = self else { return }
                presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.loadData() //requestNextQuestion()
            }
        alertPresenter?.show(model: errorModel)
    }
    // Реализация метода успешности загрузки данных с сервера
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    // Реализация метода ошибки загрузки данных с сервера
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
