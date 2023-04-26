import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - Свойства
    private var presenter: MovieQuizPresenterProtocol?
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
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Действия
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    // MARK: - Functions
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    func showResult() {
        guard let message = presenter?.createAlertMessage() else { return }
        
        let viewModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть еще раз!") { [weak self] in
                guard let self = self else { return }
                presenter?.restartGame()
            }
        let alert = AlertPresenter()
        alert.show(viewController: self, model: viewModel)
    }
    
    // Cоздаем функции показа ошибки с алертом
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let errorModel = AlertModel(
            title: "Ошибка",
            message: "Не удалось загрузить данные",
            buttonText: "Поробовать еще раз!") { [weak self] in
                guard let self = self else { return }
                presenter?.loadDataFromQuestionFactory()
            }
        let alert = AlertPresenter()
        alert.show(viewController: self, model: errorModel)
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
    
    // Методы включения и выключения кнопок
    func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    func enableButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    // Метод подсветки изображения при ответе
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    // Метод отключения подсветки после ответа
    func doNotHighLightImageBorder() {
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
}
