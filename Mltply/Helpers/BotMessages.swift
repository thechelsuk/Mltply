// BotMessages.swift
// Centralized configuration for all bot text messages in Mltply

import Foundation

struct BotMessages {
    static let welcome = "Hi! I'm Buddy your friendly robot. I love maths and It I'm keen to learn, so let's get ready to play!"
    static let onboardingSettings =
        "Before you start, check out the settings to adjust them to your liking. You can find them in the top right corner and you can choose some numbers, operations, and a timer to make the game more fun!"
    static let onboardingReply = "Once ready, reply with any message to begin!"
    static let playAgain = "Would you like to play again?"
    static let correct = "Correct!"
    static let incorrect = "Oops, this is incorrect!"
    static let timerSet = { (minutes: Int) in
        "Timer set to \(minutes) minute\(minutes == 1 ? "" : "s")!"
    }
    static let readyToBegin = "Ready to begin?"
    static let chooseTimer = "First, choose your timer:"
    static let letsGo = "OK, great, Let's go!"
    static let newRound = "Starting a new round!"
    // Add more as needed
}
