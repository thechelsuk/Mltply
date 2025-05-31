// BotMessages.swift
// Centralized configuration for all bot text messages in Mltply

import Foundation

struct BotMessages {
    static let welcome = "Hi! I'm Axl your friendly robot. Let's get ready to play!"
    static let chooseTimer = "First, choose your timer:"
    static let timerSet = { (minutes: Int) in
        "Timer set to \(minutes) minute\(minutes == 1 ? "" : "s")!"
    }
    static let chooseDifficulty = "Choose your difficulty:"
    static let difficultySet = { (difficulty: String) in
        "Difficulty set to \(difficulty.capitalized)!"
    }
    static let readyToBegin = "Ready to begin?"
    static let letsGo = "Let's go!"
    static let firstQuestion = "Let's go! Here's your first question:"
    static let playAgain = "Would you like to play again?"
    static let correct = "Correct!"
    static let incorrect = "Oops, this is incorrect. Try again!"
    // Add more as needed
}
