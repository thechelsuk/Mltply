import XCTest
@testable import Mltply

final class MltplyUnitTests: XCTestCase {
    func testMathQuestionEasyAddition() {
        // Test that easy questions generate valid addition or subtraction
        let view = ContentViewTestProxy()
        for _ in 0..<10 {
            let question = view.generateMathQuestion(for: .easy)
            if question.question.contains("+") {
                let parts = question.question.components(separatedBy: CharacterSet(charactersIn: "+? "))
                let numbers = parts.compactMap { Int($0) }
                XCTAssertEqual(numbers.count, 2)
                XCTAssertEqual(question.answer, numbers[0] + numbers[1])
            } else if question.question.contains("-") {
                let parts = question.question.components(separatedBy: CharacterSet(charactersIn: "-? "))
                let numbers = parts.compactMap { Int($0) }
                XCTAssertEqual(numbers.count, 2)
                XCTAssertEqual(question.answer, numbers[0] - numbers[1])
            }
        }
    }

    func testMathQuestionMediumIncludesMultiplicationAndDivision() {
        let view = ContentViewTestProxy()
        var foundMultiplication = false
        var foundDivision = false
        for _ in 0..<20 {
            let question = view.generateMathQuestion(for: .medium)
            if question.question.contains("×") { foundMultiplication = true }
            if question.question.contains("÷") { foundDivision = true }
        }
        XCTAssertTrue(foundMultiplication, "Should generate multiplication questions")
        XCTAssertTrue(foundDivision, "Should generate division questions")
    }

    func testBotMessagesCorrectness() {
        XCTAssertEqual(BotMessages.welcome, "Hi! I'm Axl your friendly robot. Let's get ready to play!")
        XCTAssertEqual(BotMessages.chooseTimer, "First, choose your timer:")
        XCTAssertEqual(BotMessages.timerSet(1), "Timer set to 1 minute!")
        XCTAssertEqual(BotMessages.timerSet(3), "Timer set to 3 minutes!")
        XCTAssertEqual(BotMessages.difficultySet("easy"), "Difficulty set to Easy!")
    }

    func testAppColorSchemeDisplayNames() {
        XCTAssertEqual(AppColorScheme.system.displayName, "System")
        XCTAssertEqual(AppColorScheme.light.displayName, "Light")
        XCTAssertEqual(AppColorScheme.dark.displayName, "Dark")
    }
}

// MARK: - Helpers for Testing
private struct ContentViewTestProxy {
    func generateMathQuestion(for difficulty: Difficulty) -> MathQuestion {
        switch difficulty {
        case .easy:
            let type = Int.random(in: 0..<2)
            if type == 0 {
                let a = Int.random(in: 1...20)
                let b = Int.random(in: 1...20)
                return MathQuestion(question: "What is \(a) + \(b)?", answer: a + b)
            } else {
                let a = Int.random(in: 1...20)
                let b = Int.random(in: 1...a)
                return MathQuestion(question: "What is \(a) - \(b)?", answer: a - b)
            }
        case .medium:
            let type = Int.random(in: 0..<4)
            switch type {
            case 0:
                let a = Int.random(in: 1...50)
                let b = Int.random(in: 1...50)
                return MathQuestion(question: "What is \(a) + \(b)?", answer: a + b)
            case 1:
                let a = Int.random(in: 1...50)
                let b = Int.random(in: 1...a)
                return MathQuestion(question: "What is \(a) - \(b)?", answer: a - b)
            case 2:
                let a = Int.random(in: 1...10)
                let b = Int.random(in: 1...10)
                return MathQuestion(question: "What is \(a) × \(b)?", answer: a * b)
            default:
                let b = Int.random(in: 1...10)
                let answer = Int.random(in: 1...10)
                let a = b * answer
                return MathQuestion(question: "What is \(a) ÷ \(b)?", answer: answer)
            }
        case .hard:
            let type = Int.random(in: 0..<4)
            switch type {
            case 0:
                let a = Int.random(in: 1...100)
                let b = Int.random(in: 1...100)
                return MathQuestion(question: "What is \(a) + \(b)?", answer: a + b)
            case 1:
                let a = Int.random(in: 1...100)
                let b = Int.random(in: 1...a)
                return MathQuestion(question: "What is \(a) - \(b)?", answer: a - b)
            case 2:
                let a = Int.random(in: 1...12)
                let b = Int.random(in: 1...12)
                return MathQuestion(question: "What is \(a) × \(b)?", answer: a * b)
            default:
                let b = Int.random(in: 1...12)
                let answer = Int.random(in: 1...12)
                let a = b * answer
                return MathQuestion(question: "What is \(a) ÷ \(b)?", answer: answer)
            }
        }
    }
}
