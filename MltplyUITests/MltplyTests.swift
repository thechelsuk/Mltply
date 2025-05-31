//
//  MltplyTests.swift
//  MltplyTests
//
//  Created by Mat Benfield on 31/05/2025.
//

import XCTest

final class MltplyUITests: XCTestCase {
    func waitForTypingToFinish(app: XCUIApplication, timeout: TimeInterval = 5) {
        let typingIndicator = app.otherElements["typingIndicator"]
        let predicate = NSPredicate(format: "exists == false")
        expectation(for: predicate, evaluatedWith: typingIndicator, handler: nil)
        waitForExpectations(timeout: timeout)
    }

    func testOnboardingMessagesAppear() {
        let app = XCUIApplication()
        app.launch()
        // Wait for onboarding sequence to finish
        waitForTypingToFinish(app: app, timeout: 10)
        let welcome = app.staticTexts["welcomeMessage"]
        XCTAssertTrue(welcome.waitForExistence(timeout: 2), "Welcome message should appear")
        let onboardingSettings = app.staticTexts[BotMessages.onboardingSettings]
        XCTAssertTrue(
            onboardingSettings.waitForExistence(timeout: 2),
            "Onboarding settings message should appear")
        let onboardingReply = app.staticTexts[BotMessages.onboardingReply]
        XCTAssertTrue(
            onboardingReply.waitForExistence(timeout: 2), "Onboarding reply message should appear")
    }
}
