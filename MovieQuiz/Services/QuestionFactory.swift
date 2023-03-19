//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Руслан Халилулин on 17.03.2023.
//

import Foundation
class QuestionFactory: questionFactoryProtocol {
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
//Создадим метод запроса следующего вопроса
    func requestNextQuestion() -> QuizQuestion? {
        guard let index = (0..<questions.count).randomElement() else {
            return nil
        }
        return questions[safe: index]
    }
}
