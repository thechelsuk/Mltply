// BotMessages.swift
// Centralized configuration for all bot text messages in Mltply

import Foundation

struct BotMessages {
    static let welcome = "Hi! I'm Axl your friendly robot. Let's get ready to play!"
    static let onboardingSettings =
        "Before you start, check out the settings to adjust them to your liking"
    static let onboardingReply = "Once ready, reply with any message to begin!"
    static let playAgain = "Would you like to play again?"
    static let correct = "Correct!"
    static let incorrect = "Oops, this is incorrect. Try again!"
    static let timerSet = { (minutes: Int) in
        "Timer set to \(minutes) minute\(minutes == 1 ? "" : "s")!"
    }
    static let readyToBegin = "Ready to begin?"
    static let chooseTimer = "First, choose your timer:"
    static let letsGo = "Let's go!"
    // Add more as needed
}
