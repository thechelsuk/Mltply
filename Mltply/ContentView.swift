//
//  ContentView.swift
//  Mltply
//
//  Created by Mat Benfield on 11/05/2025.
//

import AVFoundation
import Combine
import Foundation
import SwiftUI

#if canImport(UIKit)
    import UIKit  // For haptic feedback
#endif

struct ContentView: View {
    @State private var timeRemaining: Int = 120  // 2 minutes in seconds
    @State private var timerActive: Bool = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            text: BotMessages.welcome, isUser: false, accessibilityIdentifier: "welcomeMessage")
    ]
    @State private var userInput: String = ""
    @State private var currentQuestion: MathQuestion? = nil
    @State private var correctAnswers: Int = 0
    @State private var totalQuestions: Int = 0
    @State private var incorrectAnswers: Int = 0
    @State private var showSettings = false
    @State private var timerDuration: Int = 2
    @State private var mathOperations = MathOperationSettings()
    @State private var hasStarted: Bool = false
    @State private var appColorScheme: AppColorScheme = .system
    @State private var showPlayAgain: Bool = false
    @State private var continuousMode: Bool = true
    @State private var isBotTyping: Bool = false
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var soundEnabled: Bool = true

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if !continuousMode {
                    TimerView(
                        timeRemaining: timeRemaining,  // Use the actual timeRemaining state
                        timeString: timeString(for: timeRemaining))  // Show live countdown
                }
                ChatMessagesView(messages: messages)
                if showPlayAgain {
                    Button(action: playAgain) {
                        Text("Play Again")
                            .font(.headline)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(radius: 2)
                    }
                    .padding(.bottom, 8)
                    .accessibilityIdentifier("playAgainButton")
                } else {
                    UserInputView(
                        userInput: $userInput,
                        currentQuestion: currentQuestion,
                        hasStarted: hasStarted,
                        sendMessage: sendMessage
                    )
                    .accessibilityIdentifier("userInputField")
                    if isBotTyping {
                        HStack {
                            Image("robot")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .background(Circle().fill(Color.white))
                                .clipShape(Circle())
                            Text("Bot is typing...")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                        .padding(.leading, 8)
                        .padding(.bottom, 8)
                    }
                }
            }
            .navigationBarTitle("Mltply", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                }
            )
            .sheet(
                isPresented: $showSettings,
                onDismiss: {
                    // When returning from settings, always scroll to last message
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            scrollToLastMessage()
                        }
                    }
                }
            ) {
                SettingsView(
                    appColorScheme: $appColorScheme, mathOperations: $mathOperations,
                    continuousMode: $continuousMode, timerDuration: $timerDuration,
                    soundEnabled: $soundEnabled)
            }
        }
        .preferredColorScheme(appColorScheme.colorScheme)
        .onReceive(timer) { _ in
            guard timerActive, timeRemaining > 0 else { return }
            timeRemaining -= 1
            if timeRemaining == 0 {
                timerActive = false
                currentQuestion = nil  // Stop asking new questions
                // Haptic feedback when timer runs out
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
                showScoreSummary()
            }
        }
        .onAppear {
            // Show welcome message
            messages = [
                ChatMessage(
                    text: BotMessages.welcome,
                    isUser: false,
                    accessibilityIdentifier: "welcomeMessage")
            ]
            hasStarted = false
            timerActive = false
            currentQuestion = nil
            showPlayAgain = false
            timeRemaining = timerDuration * 60
            // Onboarding sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showBotMessage(BotMessages.onboardingSettings, delay: 0.0)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showBotMessage(BotMessages.onboardingReply, delay: 0.0)
                }
            }
        }
        .onChange(of: timerDuration) { newValue, _ in
            timeRemaining = newValue * 60
            // Only reset timer and state, do not clear messages
            timerActive = true  // Start timer immediately when duration changes
            hasStarted = false
            correctAnswers = 0
            totalQuestions = 0
            incorrectAnswers = 0
            userInput = ""
            currentQuestion = nil
            showPlayAgain = false
        }
        .onChange(of: mathOperations) { _, _ in
            // Only reset state, do not clear messages
            timerActive = false
            hasStarted = false
            correctAnswers = 0
            totalQuestions = 0
            incorrectAnswers = 0
            userInput = ""
            currentQuestion = nil
            showPlayAgain = false
        }
        .onChange(of: messages) { _ in
            // Play sound effect only when the bot sends a message
            if let last = messages.last, !last.isUser, !last.isTypingIndicator {
                playMessageSound()
            }
            // Scroll to the last message when messages change (e.g., after summary or play again)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.25)) {
                    scrollToLastMessage()
                }
            }
        }
        .onChange(of: continuousMode) { newValue, _ in
            if !newValue {
                // If continuous mode is turned off, start timer
                timerActive = true
                timeRemaining = timerDuration * 60
            } else {
                // If continuous mode is turned on, stop timer
                timerActive = false
            }
            // Always scroll to last message after mode change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.25)) {
                    scrollToLastMessage()
                }
            }
        }
    }

    private func timeString(for seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // Helper to show a typing indicator and then the real bot message
    private func showBotMessage(_ text: String, delay: Double = 2.0) {
        messages.append(ChatMessage(text: "", isUser: false, isTypingIndicator: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let idx = messages.firstIndex(where: { $0.isTypingIndicator }) {
                messages.remove(at: idx)
            }
            messages.append(
                ChatMessage(text: text, isUser: false, accessibilityIdentifier: "questionLabel"))
        }
    }

    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if !hasStarted {
            // Start the quiz on first user message
            hasStarted = true
            timerActive = true
            timeRemaining = timerDuration * 60
            messages.append(ChatMessage(text: userInput, isUser: true))
            userInput = ""
            let question = generateMathQuestion()
            currentQuestion = question
            showBotMessage(question.question)
            showPlayAgain = false
            return
        }
        // Only allow answering if timer is active
        if timerActive, let question = currentQuestion,
            let userAnswer = Int(userInput.trimmingCharacters(in: .whitespaces))
        {
            if userAnswer == question.answer {
                messages.append(ChatMessage(text: userInput, isUser: true, tapback: .correct))
                correctAnswers += 1
            } else {
                messages.append(ChatMessage(text: userInput, isUser: true, tapback: .incorrect))
                incorrectAnswers += 1
            }
            totalQuestions += 1
            userInput = ""
            // Ask next question only if timer is still active
            if timerActive {
                let nextQuestion = generateMathQuestion()
                currentQuestion = nextQuestion
                showBotMessage(nextQuestion.question)
            } else {
                currentQuestion = nil
            }
        } else {
            // If not answering a question, just echo
            messages.append(ChatMessage(text: userInput, isUser: true))
            userInput = ""
        }
    }

    private func showScoreSummary() {
        let allCorrect = totalQuestions > 0 && correctAnswers == totalQuestions
        let trophy = allCorrect ? " 🏆" : ""
        let summary =
            "Time's up! You answered \(correctAnswers) out of \(totalQuestions) questions correctly.\nIncorrect answers: \(incorrectAnswers)\(trophy)"
        showBotMessage(summary)
        // Ask if want to play again
        showBotMessage(BotMessages.playAgain, delay: 2.5)
        showPlayAgain = true
    }

    private func playAgain() {
        // Reset all state and prompt for timer and math operations again
        correctAnswers = 0
        totalQuestions = 0
        incorrectAnswers = 0
        userInput = ""
        timeRemaining = timerDuration * 60
        timerActive = false
        hasStarted = false
        messages = []
        showBotMessage(BotMessages.welcome, delay: 1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showBotMessage(BotMessages.chooseTimer, delay: 1.0)
        }
        showPlayAgain = false
    }
}

extension ContentView {
    private func generateMathQuestion() -> MathQuestion {
        // Get list of enabled operations
        var availableOperations: [String] = []
        if mathOperations.additionEnabled { availableOperations.append("addition") }
        if mathOperations.subtractionEnabled { availableOperations.append("subtraction") }
        if mathOperations.multiplicationEnabled { availableOperations.append("multiplication") }
        if mathOperations.divisionEnabled { availableOperations.append("division") }

        // If no operations are enabled, default to addition
        if availableOperations.isEmpty {
            availableOperations = ["addition"]
        }

        // Randomly select an operation
        let selectedOperation = availableOperations.randomElement()!

        switch selectedOperation {
        case "addition":
            let a = Int.random(in: 1...100)
            let b = Int.random(in: 1...100)
            return MathQuestion(question: "What is \(a) + \(b)?", answer: a + b)
        case "subtraction":
            let a = Int.random(in: 1...100)
            let b = Int.random(in: 1...a)
            return MathQuestion(question: "What is \(a) - \(b)?", answer: a - b)
        case "multiplication":
            let a = Int.random(in: 1...12)
            let b = Int.random(in: 1...12)
            return MathQuestion(question: "What is \(a) × \(b)?", answer: a * b)
        case "division":
            let b = Int.random(in: 1...12)
            let answer = Int.random(in: 1...12)
            let a = b * answer
            return MathQuestion(question: "What is \(a) ÷ \(b)?", answer: answer)
        default:
            // Fallback to addition
            let a = Int.random(in: 1...50)
            let b = Int.random(in: 1...50)
            return MathQuestion(question: "What is \(a) + \(b)?", answer: a + b)
        }
    }

    private func scrollToLastMessage() {
        // Use NotificationCenter to notify ChatMessagesView to scroll
        NotificationCenter.default.post(
            name: NSNotification.Name("ScrollToLastMessage"), object: nil)
    }

    // MARK: - Sound Effect
    private func playMessageSound() {
        guard soundEnabled else { return }
        // Try to load from bundle first
        if let url = Bundle.main.url(forResource: "Message", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                return
            } catch {
                // Continue to try loading from asset catalog
            }
        }
        // Try to load from asset catalog as data asset
        if let asset = NSDataAsset(name: "Message") {
            do {
                audioPlayer = try AVAudioPlayer(data: asset.data)
                audioPlayer?.play()
            } catch {
                // Handle error silently
            }
        }
    }
}

#Preview {
    ContentView()
}
