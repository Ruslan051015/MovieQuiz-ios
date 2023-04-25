import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    private var movies: [MostPopularMovie] = []
    
    /*private let questions: [QuizQuestion] = [QuizQuestion(
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
     */
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Не удалость загрузить изображение")
            }
            //Не обязательная часть задания про разный рейтинг в вопросе
            let ratingArray = [8.1, 8.3, 8.5, 8.7]
            let randomRating = ratingArray.randomElement() ?? 8.2
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем \(randomRating)?"
            let correctAnswer = rating > Float(randomRating)
            
            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didRecieveNextQuestion(question: question)
            }
        }
    }
}
