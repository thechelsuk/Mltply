import Foundation

struct QuestionRecord: Codable, Identifiable {
    let id: UUID
    let question: String
    let firstNumber: Int
    let secondNumber: Int
    let operation: MathOperation
    let correctAnswer: Int
    let userAnswer: Int
    let isCorrect: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), question: String, firstNumber: Int, secondNumber: Int, operation: MathOperation, correctAnswer: Int, userAnswer: Int, timestamp: Date = Date()) {
        self.id = id
        self.question = question
        self.firstNumber = firstNumber
        self.secondNumber = secondNumber
        self.operation = operation
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.isCorrect = correctAnswer == userAnswer
        self.timestamp = timestamp
    }
}

class QuestionHistory: ObservableObject {
    @Published var records: [QuestionRecord] = []
    
    private let historyKey = "MltplyQuestionHistory"
    
    init() {
        loadHistory()
    }
    
    func addRecord(question: String, firstNumber: Int, secondNumber: Int, operation: MathOperation, correctAnswer: Int, userAnswer: Int) {
        let record = QuestionRecord(
            question: question,
            firstNumber: firstNumber,
            secondNumber: secondNumber,
            operation: operation,
            correctAnswer: correctAnswer,
            userAnswer: userAnswer
        )
        records.append(record)
        saveHistory()
    }
    
    func clearHistory() {
        records.removeAll()
        saveHistory()
    }
    
    // Get current streak (consecutive correct from most recent)
    var currentStreak: Int {
        var streak = 0
        for record in records.reversed() {
            if record.isCorrect {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
    
    // Get longest ever streak
    var longestStreak: Int {
        var maxStreak = 0
        var currentStreak = 0
        
        for record in records {
            if record.isCorrect {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        return maxStreak
    }
    
    // Total correct answers
    var totalCorrect: Int {
        records.filter { $0.isCorrect }.count
    }
    
    // Check if user has completed all questions for a specific number and operation
    func hasCompletedNumber(_ number: Int, operation: MathOperation) -> Bool {
        let requiredQuestions = Set(1...12)
        let answeredQuestions = Set(
            records
                .filter { $0.isCorrect && $0.operation == operation }
                .filter { $0.firstNumber == number || $0.secondNumber == number }
                .compactMap { $0.firstNumber == number ? $0.secondNumber : $0.firstNumber }
        )
        return answeredQuestions.isSuperset(of: requiredQuestions)
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([QuestionRecord].self, from: data) {
            records = decoded
        }
    }
}
