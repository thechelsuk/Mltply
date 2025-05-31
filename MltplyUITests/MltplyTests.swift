//
//  MltplyTests.swift
//  MltplyTests
//
//  Created by Mat Benfield on 31/05/2025.
//

import XCTest

final class MltplyUITests: XCTestCase {
    func waitForTypingToFinish(app: XCUIApplication, timeout: TimeInterval = 5) {
        let typingIndicator = app.staticTexts["…"]
        let predicate = NSPredicate(format: "exists == false")
        expectation(for: predicate, evaluatedWith: typingIndicator, handler: nil)
        waitForExpectations(timeout: timeout)
    }

    func testWelcomeMessageAppears() {
        let app = XCUIApplication()
        app.launch()
        // Wait for onboarding sequence to finish
        waitForTypingToFinish(app: app, timeout: 10)
        let welcome = app.staticTexts["welcomeMessage"]
        XCTAssertTrue(welcome.waitForExistence(timeout: 2), "Welcome message should appear")
    }

    func testSettingsButtonOpensSettings() {
        let app = XCUIApplication()
        app.launch()
        let settingsButton = app.buttons["gearshape"]
        XCTAssertTrue(settingsButton.exists, "Settings button should exist")
        settingsButton.tap()
        let timerLabel = app.staticTexts["timerDurationLabel"]
        XCTAssertTrue(
            timerLabel.waitForExistence(timeout: 5), "Settings should show timer duration")
    }

    func testTimerStartsOnStart() {
        let app = XCUIApplication()
        app.launch()
        waitForTypingToFinish(app: app, timeout: 10)
        let textField = app.textFields["userInputField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.typeText("Let's go!\n")
        waitForTypingToFinish(app: app, timeout: 5)
        let timer = app.staticTexts["timerLabel"]
        XCTAssertTrue(timer.waitForExistence(timeout: 5), "Timer should appear after starting quiz")
    }

    func testSendAnswerShowsNextQuestion() {
        let app = XCUIApplication()
        app.launch()
        waitForTypingToFinish(app: app, timeout: 10)
        let textField = app.textFields["userInputField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.typeText("Start\n")
        waitForTypingToFinish(app: app, timeout: 5)
        // Wait for first question
        let questionQuery = app.staticTexts.matching(identifier: "questionLabel")
        let firstQuestion = questionQuery.element(boundBy: 0)
        XCTAssertTrue(firstQuestion.waitForExistence(timeout: 5))
        // Send an answer
        textField.tap()
        textField.typeText("42\n")
        waitForTypingToFinish(app: app, timeout: 5)
        let nextQuestion = questionQuery.element(boundBy: 1)
        XCTAssertTrue(nextQuestion.waitForExistence(timeout: 5))
    }

    func testPlayAgainButtonResetsQuiz() {
        let app = XCUIApplication()
        app.launch()
        waitForTypingToFinish(app: app, timeout: 10)
        let textField = app.textFields["userInputField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 5))
        textField.tap()
        textField.typeText("Start\n")
        // Simulate timer running out by waiting for play again button
        let playAgain = app.buttons["playAgainButton"]
        XCTAssertTrue(
            playAgain.waitForExistence(timeout: 20),
            "Play Again button should appear after quiz ends")
        playAgain.tap()
        waitForTypingToFinish(app: app, timeout: 10)
        let welcome = app.staticTexts["welcomeMessage"]
        XCTAssertTrue(welcome.waitForExistence(timeout: 2))
    }
}
