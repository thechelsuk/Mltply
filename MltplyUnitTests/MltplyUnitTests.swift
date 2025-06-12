import Foundation
import XCTest

@testable import Mltply

final class MltplyUnitTests: XCTestCase {

    // MARK: - MathOperationSettings Tests

    func testMathOperationSettingsInitialization() {
        let settings = MathOperationSettings()
        XCTAssertTrue(settings.additionEnabled)
        XCTAssertTrue(settings.subtractionEnabled)
        XCTAssertTrue(settings.multiplicationEnabled)
        XCTAssertTrue(settings.divisionEnabled)
        XCTAssertTrue(settings.hasAtLeastOneEnabled)
    }

    func testMathOperationSettingsHasAtLeastOneEnabled() {
        var settings = MathOperationSettings(
            additionEnabled: false,
            subtractionEnabled: false,
            multiplicationEnabled: false,
            divisionEnabled: false
        )
        XCTAssertFalse(settings.hasAtLeastOneEnabled)

        settings.additionEnabled = true
        XCTAssertTrue(settings.hasAtLeastOneEnabled)

        settings.additionEnabled = false
        settings.multiplicationEnabled = true
        XCTAssertTrue(settings.hasAtLeastOneEnabled)
    }

    // MARK: - AppColorScheme Tests

    func testAppColorSchemeDisplayNames() {
        XCTAssertEqual(AppColorScheme.system.displayName, "System")
        XCTAssertEqual(AppColorScheme.light.displayName, "Light")
        XCTAssertEqual(AppColorScheme.dark.displayName, "Dark")
    }

    func testAppColorSchemeColorScheme() {
        XCTAssertNil(AppColorScheme.system.colorScheme)
        XCTAssertEqual(AppColorScheme.light.colorScheme, .light)
        XCTAssertEqual(AppColorScheme.dark.colorScheme, .dark)
    }

    // MARK: - QuestionMode Tests

    func testQuestionModeDisplayNames() {
        XCTAssertEqual(QuestionMode.random.displayName, "Random")
        XCTAssertEqual(QuestionMode.sequential.displayName, "Ascending")
    }

    func testQuestionModeIconNames() {
        XCTAssertEqual(QuestionMode.random.iconName, "shuffle")
        XCTAssertEqual(QuestionMode.sequential.iconName, "arrow.up.arrow.down")
    }

    // MARK: - PracticeSettings Tests

    func testPracticeSettingsInitialization() {
        let settings = PracticeSettings()
        XCTAssertEqual(settings.selectedNumbers, Set(1...12))
        XCTAssertEqual(settings.currentNumberIndex, 0)
        XCTAssertEqual(settings.currentMultiplier, 1)
        XCTAssertEqual(settings.currentNumber, 1)
        XCTAssertTrue(settings.hasSelectedNumbers)
    }

    func testPracticeSettingsNextQuestion() {
        var settings = PracticeSettings()
        settings.selectedNumbers = Set([2, 5]) // Only 2 and 5

        // Start with 2 × 1
        XCTAssertEqual(settings.currentNumber, 2)
        XCTAssertEqual(settings.currentMultiplier, 1)

        // Should progress through multipliers first
        settings.nextQuestion()
        XCTAssertEqual(settings.currentNumber, 2)
        XCTAssertEqual(settings.currentMultiplier, 2)

        // Jump to 2 × 12
        for _ in 3...12 {
            settings.nextQuestion()
        }
        XCTAssertEqual(settings.currentNumber, 2)
        XCTAssertEqual(settings.currentMultiplier, 12)

        // Should move to next number and reset multiplier
        settings.nextQuestion()
        XCTAssertEqual(settings.currentNumber, 5)
        XCTAssertEqual(settings.currentMultiplier, 1)

        // Should cycle back to first number
        for _ in 2...12 {
            settings.nextQuestion()
        }
        settings.nextQuestion()
        XCTAssertEqual(settings.currentNumber, 2)
        XCTAssertEqual(settings.currentMultiplier, 1)
    }

    func testPracticeSettingsToggleNumber() {
        var settings = PracticeSettings()

        // Remove a number
        settings.toggleNumber(5)
        XCTAssertFalse(settings.selectedNumbers.contains(5))
        XCTAssertEqual(settings.currentMultiplier, 1) // Should reset
        XCTAssertEqual(settings.currentNumberIndex, 0)

        // Add it back
        settings.toggleNumber(5)
        XCTAssertTrue(settings.selectedNumbers.contains(5))

        // Remove all numbers
        for i in 1...12 {
            settings.toggleNumber(i)
        }
        XCTAssertTrue(settings.selectedNumbers.isEmpty)
        XCTAssertFalse(settings.hasSelectedNumbers)
    }

    func testPracticeSettingsEdgeCaseEmptySelection() {
        var settings = PracticeSettings()
        settings.selectedNumbers = Set<Int>()

        // Should return 1 as fallback when no numbers selected
        XCTAssertEqual(settings.currentNumber, 1)
        XCTAssertFalse(settings.hasSelectedNumbers)
    }

    // MARK: - Mathematical Logic Tests

    func testAdditionLogic() {
        let a = 15
        let b = 25
        let result = a + b
        XCTAssertEqual(result, 40)

        // Test edge cases
        XCTAssertEqual(0 + 0, 0)
        XCTAssertEqual(1 + 0, 1)
        XCTAssertEqual(100 + 200, 300)
    }

    func testSubtractionLogic() {
        let a = 25
        let b = 15
        let result = a - b
        XCTAssertEqual(result, 10)

        // Test edge cases
        XCTAssertEqual(0 - 0, 0)
        XCTAssertEqual(10 - 10, 0)
        XCTAssertEqual(100 - 50, 50)

        // Ensure positive results for typical use case
        let larger = max(20, 8)
        let smaller = min(20, 8)
        XCTAssertGreaterThanOrEqual(larger - smaller, 0)
    }

    func testMultiplicationLogic() {
        let a = 7
        let b = 8
        let result = a * b
        XCTAssertEqual(result, 56)

        // Test times tables
        XCTAssertEqual(1 * 12, 12)
        XCTAssertEqual(12 * 12, 144)
        XCTAssertEqual(5 * 6, 30)

        // Test edge cases
        XCTAssertEqual(0 * 100, 0)
        XCTAssertEqual(1 * 999, 999)
    }

    func testDivisionLogic() {
        let dividend = 56
        let divisor = 7
        let result = dividend / divisor
        XCTAssertEqual(result, 8)

        // Test clean divisions (no remainder)
        XCTAssertEqual(144 / 12, 12)
        XCTAssertEqual(100 / 10, 10)
        XCTAssertEqual(48 / 6, 8)

        // Test that we're creating problems with no remainder
        for i in 1...12 {
            for j in 1...12 {
                let testDividend = i * j
                let testResult = testDividend / j
                XCTAssertEqual(testResult, i, "Division should result in whole numbers")
                XCTAssertEqual(testDividend % j, 0, "Should have no remainder")
            }
        }
    }

    // MARK: - Range and Boundary Tests

    func testNumberRanges() {
        let validRange = 1...12

        // Test all numbers in range are valid
        for i in validRange {
            XCTAssertGreaterThanOrEqual(i, 1)
            XCTAssertLessThanOrEqual(i, 12)
        }

        // Test set operations
        let testSet = Set(validRange)
        XCTAssertEqual(testSet.count, 12)
        XCTAssertTrue(testSet.contains(1))
        XCTAssertTrue(testSet.contains(12))
        XCTAssertFalse(testSet.contains(0))
        XCTAssertFalse(testSet.contains(13))
    }

    func testTimerLogic() {
        var timeRemaining = 120 // 2 minutes

        // Test time formatting logic
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        XCTAssertEqual(timeString, "02:00")

        // Test countdown
        timeRemaining -= 1
        let newMinutes = timeRemaining / 60
        let newSeconds = timeRemaining % 60
        let newTimeString = String(format: "%02d:%02d", newMinutes, newSeconds)
        XCTAssertEqual(newTimeString, "01:59")

        // Test edge cases
        timeRemaining = 60 // 1 minute
        let edgeMinutes = timeRemaining / 60
        let edgeSeconds = timeRemaining % 60
        let edgeTimeString = String(format: "%02d:%02d", edgeMinutes, edgeSeconds)
        XCTAssertEqual(edgeTimeString, "01:00")

        timeRemaining = 5 // 5 seconds
        let finalMinutes = timeRemaining / 60
        let finalSeconds = timeRemaining % 60
        let finalTimeString = String(format: "%02d:%02d", finalMinutes, finalSeconds)
        XCTAssertEqual(finalTimeString, "00:05")
    }

    // MARK: - Question Generation Logic Tests

    func testQuestionStringFormatting() {
        // Test addition question format
        let additionQuestion = "What is 5 + 3?"
        XCTAssertTrue(additionQuestion.hasPrefix("What is "))
        XCTAssertTrue(additionQuestion.hasSuffix("?"))
        XCTAssertTrue(additionQuestion.contains("+"))

        // Test multiplication question format
        let multiplicationQuestion = "What is 7 × 8?"
        XCTAssertTrue(multiplicationQuestion.hasPrefix("What is "))
        XCTAssertTrue(multiplicationQuestion.hasSuffix("?"))
        XCTAssertTrue(multiplicationQuestion.contains("×"))

        // Test subtraction question format
        let subtractionQuestion = "What is 15 - 7?"
        XCTAssertTrue(subtractionQuestion.hasPrefix("What is "))
        XCTAssertTrue(subtractionQuestion.hasSuffix("?"))
        XCTAssertTrue(subtractionQuestion.contains("-"))

        // Test division question format
        let divisionQuestion = "What is 56 ÷ 8?"
        XCTAssertTrue(divisionQuestion.hasPrefix("What is "))
        XCTAssertTrue(divisionQuestion.hasSuffix("?"))
        XCTAssertTrue(divisionQuestion.contains("÷"))
    }

    func testScoreCalculation() {
        var score = 0

        // Test adding correct answers
        score += 1
        XCTAssertEqual(score, 1)

        score += 1
        score += 1
        XCTAssertEqual(score, 3)

        // Test score reset
        score = 0
        XCTAssertEqual(score, 0)

        // Test multiple additions
        for _ in 1...10 {
            score += 1
        }
        XCTAssertEqual(score, 10)
    }

    // MARK: - Input Validation Tests

    func testAnswerValidation() {
        // Test valid integer inputs
        let validInputs = ["0", "5", "12", "100", "999"]

        for input in validInputs {
            let trimmedInput = input.trimmingCharacters(in: .whitespaces)
            if let number = Int(trimmedInput) {
                XCTAssertGreaterThanOrEqual(number, 0)
            } else {
                XCTFail("Should be able to parse \(input) as integer")
            }
        }

        // Test invalid inputs
        let invalidInputs = ["", "abc", "5.5", "12a", " ", "five"]

        for input in invalidInputs {
            let trimmedInput = input.trimmingCharacters(in: .whitespaces)
            let number = Int(trimmedInput)
            XCTAssertNil(number, "Should not be able to parse \(input) as integer")
        }

        // Test whitespace handling
        let inputWithSpaces = "  42  "
        let trimmed = inputWithSpaces.trimmingCharacters(in: .whitespaces)
        if let number = Int(trimmed) {
            XCTAssertEqual(number, 42)
        } else {
            XCTFail("Should handle whitespace correctly")
        }
    }

    // MARK: - Array and Collection Tests

    func testScoreArrayOperations() {
        var scores: [Int] = []

        // Test adding scores
        scores.append(5)
        scores.append(8)
        scores.append(3)
        scores.append(10)

        XCTAssertEqual(scores.count, 4)

        // Test sorting (highest first)
        let sortedScores = scores.sorted { $0 > $1 }
        XCTAssertEqual(sortedScores, [10, 8, 5, 3])

        // Test getting top scores
        let topThree = Array(sortedScores.prefix(3))
        XCTAssertEqual(topThree, [10, 8, 5])

        // Test personal best (highest score)
        let personalBest = sortedScores.first ?? 0
        XCTAssertEqual(personalBest, 10)

        // Test empty array
        scores.removeAll()
        XCTAssertTrue(scores.isEmpty)
        XCTAssertEqual(scores.first ?? 0, 0)
    }

    // MARK: - String Processing Tests

    func testMessageTextProcessing() {
        let messages = [
            "Hi! I'm Buddy your friendly robot.",
            "What is 5 + 3?",
            "Correct! Well done.",
            "Time's up!"
        ]

        for message in messages {
            XCTAssertFalse(message.isEmpty)
            XCTAssertGreaterThan(message.count, 0)
        }

        // Test question detection
        let questionMessage = "What is 7 × 8?"
        XCTAssertTrue(questionMessage.hasPrefix("What is "))
        XCTAssertTrue(questionMessage.hasSuffix("?"))

        // Test non-question message
        let statementMessage = "Great job!"
        XCTAssertFalse(statementMessage.hasPrefix("What is "))
        XCTAssertFalse(statementMessage.hasSuffix("?"))
    }
}
