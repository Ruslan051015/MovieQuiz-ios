import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord? { get }
    
    func store( correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
//   MARK: - Private properties
    private let userDefaults = UserDefaults.standard
    private let dateProvider: () -> Date = { Date() }
//    MARK: - Properties
    var totalAccuracy: Double{
        Double(correct) / Double(total) * 100
    }
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
            }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
            }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
            }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    var bestGame: GameRecord? {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return nil
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить резульат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
//   MARK: - Keys for UserDefaults
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
//    MARK: - Store function
    func store(correct count: Int, total amount: Int) {
        self.correct += count
        self.total += amount
        self.gamesCount += 1
        
        let date = dateProvider()
        let currentBestGame = GameRecord(correct: count, total: amount, date: date)
        
        if let previousBestGame = bestGame {
            if currentBestGame >= previousBestGame {
                bestGame = currentBestGame
            }
        } else {
            bestGame = currentBestGame
        }
    }
    
}

