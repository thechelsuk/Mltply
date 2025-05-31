//
//  MltplyTests.swift
//  MltplyTests
//
//  Created by Mat Benfield on 31/05/2025.
//

import XCTest

final class MltplyUITests: XCTestCase {
    func testWelcomeMessageAppears() {
        let app = XCUIApplication()
        app.launch()
        // Check for welcome message using accessibility identifier for reliability
        let welcome = app.staticTexts["welcomeMessage"]
        XCTAssertTrue(welcome.waitForExistence(timeout: 5), "Welcome message should appear")
    }

    func testSettingsButtonOpensSettings() {
        let app = XCUIApplication()
        app.launch()
        let settingsButton = app.buttons["gearshape"]
        XCTAssertTrue(settingsButton.exists, "Settings button should exist")
        settingsButton.tap()
        // Check for a known settings label using accessibility identifier
        let timerLabel = app.staticTexts["timerDurationLabel"]
        XCTAssertTrue(
            timerLabel.waitForExistence(timeout: 5), "Settings should show timer duration")
    }

    func testTimerStartsOnStart() {
        let app = XCUIApplication()
        app.launch()
        // Simulate user starting the quiz
        let textField = app.textFields["userInputField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.typeText("Let's go!\n")
        // Timer should appear if not in continuous mode
        let timer = app.staticTexts["timerLabel"]
        XCTAssertTrue(timer.waitForExistence(timeout: 5), "Timer should appear after starting quiz")
    }

    func testSendAnswerShowsNextQuestion() {
        let app = XCUIApplication()
        app.launch()
        // Start quiz
        let textField = app.textFields["userInputField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.typeText("Start\n")
        // Wait for first question
        let questionQuery = app.staticTexts.matching(identifier: "questionLabel")
        let firstQuestion = questionQuery.element(boundBy: 0)
        XCTAssertTrue(firstQuestion.waitForExistence(timeout: 5))
        // Send an answer
        textField.tap()
        textField.typeText("42\n")
        // Wait for next question
        let nextQuestion = questionQuery.element(boundBy: 1)
        XCTAssertTrue(nextQuestion.waitForExistence(timeout: 5))
    }

    func testPlayAgainButtonResetsQuiz() {
        let app = XCUIApplication()
        app.launch()
        // Start quiz
        let textField = app.textFields["userInputField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.typeText("Start\n")
        // Simulate timer running out by waiting for play again button
        let playAgain = app.buttons["playAgainButton"]
        XCTAssertTrue(
            playAgain.waitForExistence(timeout: 15),
            "Play Again button should appear after quiz ends")
        playAgain.tap()
        // Welcome message should reappear
        let welcome = app.staticTexts["welcomeMessage"]
        XCTAssertTrue(welcome.waitForExistence(timeout: 5))
    }
}
