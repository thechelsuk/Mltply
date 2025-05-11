//
//  ContentView.swift
//  Mltply
//
//  Created by Mat Benfield on 11/05/2025.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State private var timeRemaining: Int = 600  // 10 minutes in seconds
    @State private var timerActive: Bool = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi! I'm your math robot. Lets play!", isUser: false)
    ]
    @State private var userInput: String = ""
    @State private var currentQuestion: MathQuestion? = nil
    @State private var correctAnswers: Int = 0
    @State private var totalQuestions: Int = 0
    @State private var incorrectAnswers: Int = 0
    @State private var showSettings = false
    @State private var timerDuration: Int = 10
    @State private var difficulty: Difficulty = .easy
    @State private var hasStarted: Bool = false
    @State private var appColorScheme: AppColorScheme = .system
    @State private var showPlayAgain: Bool = false
    @State private var showTimerCard: Bool = true
    @State private var showDifficultyCard: Bool = false
    @State private var showStartCard: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TimerView(timeRemaining: timeRemaining, timeString: timeString)
                ChatMessagesView(messages: messages)
                if showTimerCard {
                    ChatCardView(
                        card: ChatCardType(kind: .timer),
                        timerDuration: $timerDuration,
                        difficulty: $difficulty,
                        onSelect: {
                            showTimerCard = false
                            showDifficultyCard = true
                            // Add a bot message to confirm selection
                            messages.append(
                                ChatMessage(
                                    text:
                                        "Timer set to \(timerDuration) minute\(timerDuration == 1 ? "" : "s")!",
                                    isUser: false))
                        }
                    )
                    .padding(.bottom, 8)
                } else if showDifficultyCard {
                    ChatCardView(
                        card: ChatCardType(kind: .difficulty),
                        timerDuration: $timerDuration,
                        difficulty: $difficulty,
                        onSelect: {
                            showDifficultyCard = false
                            showStartCard = true
                            // Add a bot message to confirm selection
                            messages.append(
                                ChatMessage(
                                    text: "Difficulty set to \(difficulty.rawValue.capitalized)!",
                                    isUser: false))
                        }
                    )
                    .padding(.bottom, 8)
                } else if showStartCard {
                    ChatCardView(
                        card: ChatCardType(kind: .start),
                        timerDuration: $timerDuration,
                        difficulty: $difficulty,
                        onSelect: {
                            showStartCard = false
                            // Start the quiz as if the user sent a message
                            hasStarted = true
                            timerActive = true
                            timeRemaining = timerDuration * 60
                            messages.append(ChatMessage(text: "Let's go!", isUser: false))
                            let question = generateMathQuestion()
                            currentQuestion = question
                            messages.append(ChatMessage(text: question.question, isUser: false))
                        }
                    )
                    .padding(.bottom, 8)
                } else if showPlayAgain {
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
                } else {
                    UserInputView(
                        userInput: $userInput,
                        currentQuestion: currentQuestion,
                        hasStarted: hasStarted,
                        sendMessage: sendMessage
                    )
                }
            }
            .navigationBarTitle("Mltply", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                }
            )
            .sheet(isPresented: $showSettings) {
                SettingsView(
                    timerDuration: $timerDuration, difficulty: $difficulty,
                    appColorScheme: $appColorScheme)
            }
        }
        .preferredColorScheme(appColorScheme.colorScheme)
        .onReceive(timer) { _ in
            guard timerActive, timeRemaining > 0 else { return }
            timeRemaining -= 1
            if timeRemaining == 0 {
                timerActive = false
                currentQuestion = nil  // Stop asking new questions
                showScoreSummary()
            }
        }
        .onAppear {
            // Show welcome and prompt for timer and difficulty
            messages = [
                ChatMessage(
                    text: "Hi! I'm your math robot. Let's get ready to play!",
                    isUser: false),
                ChatMessage(
                    text: "First, choose your timer:",
                    isUser: false),
            ]
            hasStarted = false
            timerActive = false
            currentQuestion = nil
            showPlayAgain = false
            showTimerCard = true
            showDifficultyCard = false
            showStartCard = false
        }
        .onChange(of: timerDuration) { newValue, _ in
            // Reset timer and state when timer duration changes
            timeRemaining = newValue * 60
            timerActive = false
            hasStarted = false
            messages = [
                ChatMessage(
                    text: "Hi! I'm your math robot. Let's get ready to play!",
                    isUser: false)
            ]
            correctAnswers = 0
            totalQuestions = 0
            incorrectAnswers = 0
            userInput = ""
            currentQuestion = nil
            showPlayAgain = false
        }
        .onChange(of: difficulty) { _, _ in
            // Reset state when difficulty changes
            timerActive = false
            hasStarted = false
            messages = [
                ChatMessage(
                    text: "Hi! I'm your math robot. Let's get ready to play!",
                    isUser: false)
            ]
            correctAnswers = 0
            totalQuestions = 0
            incorrectAnswers = 0
            userInput = ""
            currentQuestion = nil
            showPlayAgain = false
        }
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
            messages.append(ChatMessage(text: question.question, isUser: false))
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let question = generateMathQuestion()
                    currentQuestion = question
                    messages.append(ChatMessage(text: question.question, isUser: false))
                }
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
        messages.append(ChatMessage(text: summary, isUser: false))
        // Ask if want to play again
        messages.append(ChatMessage(text: "Would you like to play again?", isUser: false))
        showPlayAgain = true
    }

    private func playAgain() {
        // Reset all state and start a new quiz
        correctAnswers = 0
        totalQuestions = 0
        incorrectAnswers = 0
        userInput = ""
        timeRemaining = timerDuration * 60
        timerActive = true
        hasStarted = true
        messages = [
            ChatMessage(text: "Let's go! Here's your first question:", isUser: false)
        ]
        let question = generateMathQuestion()
        currentQuestion = question
        messages.append(ChatMessage(text: question.question, isUser: false))
        showPlayAgain = false
    }
}

extension ContentView {
    private func generateMathQuestion() -> MathQuestion {
        switch difficulty {
        case .easy:
            let type = Int.random(in: 0..<2)  // Only addition/subtraction
            if type == 0 {
                let a = Int.random(in: 1...20)
                let b = Int.random(in: 1...20)
                return MathQuestion(question: "What is \(a) + \(b)?", answer: a + b)
            } else {
                let a = Int.random(in: 1...20)
                let b = Int.random(in: 1...a)
                return MathQuestion(question: "What is \(a) - \(b)?", answer: a - b)
            }
        case .medium:
            let type = Int.random(in: 0..<4)
            switch type {
            case 0:
                let a = Int.random(in: 1...50)
                let b = Int.random(in: 1...50)
                return MathQuestion(question: "What is \(a) + \(b)?", answer: a + b)
            case 1:
                let a = Int.random(in: 1...50)
                let b = Int.random(in: 1...a)
                return MathQuestion(question: "What is \(a) - \(b)?", answer: a - b)
            case 2:
                let a = Int.random(in: 1...10)
                let b = Int.random(in: 1...10)
                return MathQuestion(question: "What is \(a) × \(b)?", answer: a * b)
            default:
                let b = Int.random(in: 1...10)
                let answer = Int.random(in: 1...10)
                let a = b * answer
                return MathQuestion(question: "What is \(a) ÷ \(b)?", answer: answer)
            }
        case .hard:
            let type = Int.random(in: 0..<4)
            switch type {
            case 0:
                let a = Int.random(in: 1...100)
                let b = Int.random(in: 1...100)
                return MathQuestion(question: "What is \(a) + \(b)?", answer: a + b)
            case 1:
                let a = Int.random(in: 1...100)
                let b = Int.random(in: 1...a)
                return MathQuestion(question: "What is \(a) - \(b)?", answer: a - b)
            case 2:
                let a = Int.random(in: 1...12)
                let b = Int.random(in: 1...12)
                return MathQuestion(question: "What is \(a) × \(b)?", answer: a * b)
            default:
                let b = Int.random(in: 1...12)
                let answer = Int.random(in: 1...12)
                let a = b * answer
                return MathQuestion(question: "What is \(a) ÷ \(b)?", answer: answer)
            }
        }
    }
}

#Preview {
    ContentView()
}
