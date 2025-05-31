//
//  MltplyTests.swift
//  MltplyTests
//
//  Created by Mat Benfield on 31/05/2025.
//

import Testing
import XCTest

final class MltplyUITests: XCTestCase {
    func testWelcomeMessageAppears() {
        let app = XCUIApplication()
        app.launch()
        // Check for welcome message
        let welcome = app.staticTexts["Welcome to Mltply!"]
        XCTAssertTrue(welcome.waitForExistence(timeout: 2), "Welcome message should appear")
    }

    func testSettingsButtonOpensSettings() {
        let app = XCUIApplication()
        app.launch()
        let settingsButton = app.buttons["gearshape"]
        XCTAssertTrue(settingsButton.exists, "Settings button should exist")
        settingsButton.tap()
        // Check for a known settings label
        let timerLabel = app.staticTexts["Timer Duration"]
        XCTAssertTrue(
            timerLabel.waitForExistence(timeout: 2), "Settings should show timer duration")
    }

    func testTimerStartsOnStart() {
        let app = XCUIApplication()
        app.launch()
        // Simulate user starting the quiz
        let textField = app.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 2))
        textField.tap()
        textField.typeText("Let's go!\n")
        // Timer should appear if not in continuous mode
        let timer = app.staticTexts.matching(NSPredicate(format: "label CONTAINS ':'")).firstMatch
        XCTAssertTrue(timer.waitForExistence(timeout: 2), "Timer should appear after starting quiz")
    }

    func testSendAnswerShowsNextQuestion() {
        let app = XCUIApplication()
        app.launch()
        // Start quiz
        let textField = app.textFields.firstMatch
        textField.tap()
        textField.typeText("Start\n")
        // Wait for first question
        let questionQuery = app.staticTexts.matching(NSPredicate(format: "label CONTAINS '?'"))
        let firstQuestion = questionQuery.element(boundBy: 0)
        XCTAssertTrue(firstQuestion.waitForExistence(timeout: 2))
        // Send an answer
        textField.tap()
        textField.typeText("42\n")
        // Wait for next question
        let nextQuestion = questionQuery.element(boundBy: 1)
        XCTAssertTrue(nextQuestion.waitForExistence(timeout: 2))
    }

    func testPlayAgainButtonResetsQuiz() {
        let app = XCUIApplication()
        app.launch()
        // Start quiz
        let textField = app.textFields.firstMatch
        textField.tap()
        textField.typeText("Start\n")
        // Simulate timer running out by waiting for play again button
        let playAgain = app.buttons["Play Again"]
        XCTAssertTrue(
            playAgain.waitForExistence(timeout: 10),
            "Play Again button should appear after quiz ends")
        playAgain.tap()
        // Welcome message should reappear
        let welcome = app.staticTexts["Welcome to Mltply!"]
        XCTAssertTrue(welcome.waitForExistence(timeout: 2))
    }
}
