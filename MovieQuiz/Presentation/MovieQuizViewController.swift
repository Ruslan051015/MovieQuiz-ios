import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Свойства
    private var presenter: MovieQuizPresenter!
    var alertPresenter: AlertPresenterProtocol?
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
        
        showLoadingIndicator()
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        presenter = MovieQuizPresenter(viewController: self)
    }
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        presenter.didRecieveNextQuestion(question: question)
    }
    // MARK: - Действия
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    // MARK: - Other funcs: Прописываем реализацию метода показа первого экрана
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // Реализация функции показа результата после ответа на вопрос
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResult()
            //Убираем подсветку ответа после выбора варианта
            self.imageView.layer.borderColor = UIColor.clear.cgColor
        }
        disableButtons()
    }
    
    // Реализация функции показа индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    // Реализация функции скрытия индикатора загрузки
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    // Cоздаем функции показа ошибки с алертом
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let errorModel = AlertModel(
            title: "Ошибка",
            message: "Не удалось загрузить данные",
            buttonText: "Поробовать еще раз!") { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            }
        alertPresenter?.show(model: errorModel)
    }
    
    // Методы включения и выключения кнопок
    func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
}
