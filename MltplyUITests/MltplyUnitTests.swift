import Foundation
import XCTest

@testable import Mltply

final class MltplyUnitTests: XCTestCase {
    func testMathQuestionAdditionAndSubtraction() {
        let view = ContentViewTestProxy()
        for _ in 0..<10 {
            let question = view.generateMathQuestion(
                operations: MathOperationSettings(
                    additionEnabled: true, subtractionEnabled: true, multiplicationEnabled: false,
                    divisionEnabled: false))
            if question.question.contains("+") {
                let parts = question.question.components(
                    separatedBy: CharacterSet(charactersIn: "+? "))
                let numbers = parts.compactMap { Int($0) }
                XCTAssertEqual(numbers.count, 2)
                XCTAssertEqual(question.answer, numbers[0] + numbers[1])
            } else if question.question.contains("-") {
                let parts = question.question.components(
                    separatedBy: CharacterSet(charactersIn: "-? "))
                let numbers = parts.compactMap { Int($0) }
                XCTAssertEqual(numbers.count, 2)
                XCTAssertEqual(question.answer, numbers[0] - numbers[1])
            }
        }
    }

    func testMathQuestionMultiplicationAndDivision() {
        let view = ContentViewTestProxy()
        var foundMultiplication = false
        var foundDivision = false
        for _ in 0..<20 {
            let question = view.generateMathQuestion(
                operations: MathOperationSettings(
                    additionEnabled: false, subtractionEnabled: false, multiplicationEnabled: true,
                    divisionEnabled: true))
            if question.question.contains("×") { foundMultiplication = true }
            if question.question.contains("÷") { foundDivision = true }
        }
        XCTAssertTrue(foundMultiplication, "Should generate multiplication questions")
        XCTAssertTrue(foundDivision, "Should generate division questions")
    }

    func testAppColorSchemeDisplayNames() {
        XCTAssertEqual(AppColorScheme.system.displayName, "System")
        XCTAssertEqual(AppColorScheme.light.displayName, "Light")
        XCTAssertEqual(AppColorScheme.dark.displayName, "Dark")
    }
}

private struct ContentViewTestProxy {
    func generateMathQuestion(operations: MathOperationSettings) -> MathQuestion {
        var enabledOps: [(String, (Int, Int) -> MathQuestion)] = []
        if operations.additionEnabled {
            enabledOps.append(
                ("+", { a, b in MathQuestion(question: "What is \(a) + \(b)?", answer: a + b) }))
        }
        if operations.subtractionEnabled {
            enabledOps.append(
                ("-", { a, b in MathQuestion(question: "What is \(a) - \(b)?", answer: a - b) }))
        }
        if operations.multiplicationEnabled {
            enabledOps.append(
                ("×", { a, b in MathQuestion(question: "What is \(a) × \(b)?", answer: a * b) }))
        }
        if operations.divisionEnabled {
            enabledOps.append(
                (
                    "÷",
                    { a, b in
                        let answer = Int.random(in: 1...12)
                        let divisor = Int.random(in: 1...12)
                        let dividend = answer * divisor
                        return MathQuestion(
                            question: "What is \(dividend) ÷ \(divisor)?", answer: answer)
                    }
                ))
        }
        guard !enabledOps.isEmpty else {
            let a = Int.random(in: 1...20)
            let b = Int.random(in: 1...20)
            return MathQuestion(question: "What is \(a) + \(b)?", answer: a + b)
        }
        let opIndex = Int.random(in: 0..<enabledOps.count)
        let (op, builder) = enabledOps[opIndex]
        switch op {
        case "+":
            let a = Int.random(in: 1...100)
            let b = Int.random(in: 1...100)
            return builder(a, b)
        case "-":
            let a = Int.random(in: 1...100)
            let b = Int.random(in: 1...a)
            return builder(a, b)
        case "×":
            let a = Int.random(in: 1...12)
            let b = Int.random(in: 1...12)
            return builder(a, b)
        case "÷":
            return builder(0, 0)
        default:
            let a = Int.random(in: 1...20)
            let b = Int.random(in: 1...20)
            return MathQuestion(question: "What is \(a) + \(b)?", answer: a + b)
        }
    }
}
