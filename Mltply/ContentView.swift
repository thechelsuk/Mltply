//
//  ContentView.swift
//  Mltply
//
//  Created by Mat Benfield on 11/05/2025.
//

import AVFoundation  // For sound playback
import Foundation
import SwiftUI

#if canImport(UIKit)
    import UIKit  // For haptic feedback
#endif

struct ContentView: View {
    // MARK: - State
    @State private var timeRemaining: Int = 120  // 2 minutes in seconds
    @State private var timerActive: Bool = true
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: BotMessages.welcome, isUser: false)
    ]
    @State private var userInput: String = ""
    @State private var currentQuestion: MathQuestion? = nil
    @State private var correctAnswers: Int = 0
    @State private var totalQuestions: Int = 0
    @State private var incorrectAnswers: Int = 0
    @State private var showSettings = false
    @State private var timerDuration: Int = 2
    @State private var hasStarted: Bool = false
    @State private var appColorScheme: AppColorScheme = .system
    @State private var showPlayAgain: Bool = false
    @State private var showTimerCard: Bool = true
    @State private var showDifficultyCard: Bool = false
    @State private var showStartCard: Bool = false
    @State private var isBotTyping: Bool = false
    @State private var typingIndicatorID: UUID? = nil
    @State private var audioPlayer: AVAudioPlayer? = nil
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - View
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if !showTimerCard {
                    TimerView(timeRemaining: timeRemaining, timeString: timeString)
                }
                ChatMessagesView(messages: messages)
                if showTimerCard {
                    ChatCardView(
                        card: ChatCardType(kind: .timer),
                        timerDuration: $timerDuration,
                        difficulty: $difficulty,
                        onSelect: {
                            showTimerCard = false
                            showDifficultyCard = true
                        },
                        addMessage: { msg in
                            messages.append(ChatMessage(text: msg, isUser: true))
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
                        },
                        addMessage: { msg in
                            messages.append(ChatMessage(text: msg, isUser: true))
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
                            startQuiz()
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
            .sheet(isPresented: $showSettings) {
                SettingsView(appColorScheme: $appColorScheme)
            }
        }
        .preferredColorScheme(appColorScheme.colorScheme)
        .onReceive(timer) { _ in
            handleTimerTick()
        }
        .onAppear {
            resetForWelcome()
        }
        .onChange(of: timerDuration) { newValue, _ in
            handleTimerDurationChange(newValue)
        }
        .onChange(of: difficulty) { _, _ in
            handleDifficultyChange()
        }
        .onChange(of: messages) { _, _ in
            handleMessagesChange()
        }
    }

    // MARK: - Computed
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Helpers
    private func showBotMessage(_ text: String, delay: Double = 2.0) {
        let typingID = UUID()
        messages.append(ChatMessage(text: "", isUser: false, isTypingIndicator: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let idx = messages.firstIndex(where: { $0.isTypingIndicator }) {
                messages.remove(at: idx)
            }
            messages.append(ChatMessage(text: text, isUser: false))
        }
    }

    private func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if !hasStarted {
            startQuiz(userMessage: userInput)
            return
        }
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
            if timerActive {
                let nextQuestion = generateMathQuestion()
                currentQuestion = nextQuestion
                showBotMessage(nextQuestion.question)
            } else {
                currentQuestion = nil
            }
        } else {
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
        showBotMessage(BotMessages.playAgain, delay: 2.5)
        showPlayAgain = true
    }

    private func playAgain() {
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
        showTimerCard = true
        showDifficultyCard = false
        showStartCard = false
        currentQuestion = nil
    }

    private func startQuiz(userMessage: String? = nil) {
        hasStarted = true
        timerActive = true
        timeRemaining = timerDuration * 60
        if let userMessage = userMessage {
            messages.append(ChatMessage(text: userMessage, isUser: true))
            userInput = ""
        }
        showBotMessage(BotMessages.letsGo)
        let question = generateMathQuestion()
        currentQuestion = question
        showBotMessage(question.question)
        showPlayAgain = false
    }

    private func handleTimerTick() {
        guard timerActive, timeRemaining > 0 else { return }
        timeRemaining -= 1
        if timeRemaining == 0 {
            timerActive = false
            currentQuestion = nil
            #if canImport(UIKit)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            #endif
            showScoreSummary()
        }
    }

    private func resetForWelcome() {
        messages = [
            ChatMessage(
                text: BotMessages.welcome,
                isUser: false),
            ChatMessage(
                text: BotMessages.chooseTimer,
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

    private func handleTimerDurationChange(_ newValue: Int) {
        timeRemaining = newValue * 60
        timerActive = false
        hasStarted = false
        messages = [
            ChatMessage(
                text: BotMessages.welcome,
                isUser: false)
        ]
        correctAnswers = 0
        totalQuestions = 0
        incorrectAnswers = 0
        userInput = ""
        currentQuestion = nil
        showPlayAgain = false
    }

    private func handleDifficultyChange() {
        timerActive = false
        hasStarted = false
        messages = [
            ChatMessage(
                text: BotMessages.welcome,
                isUser: false)
        ]
        correctAnswers = 0
        totalQuestions = 0
        incorrectAnswers = 0
        userInput = ""
        currentQuestion = nil
        showPlayAgain = false
    }

    private func handleMessagesChange() {
        if let last = messages.last, !last.isUser, !last.isTypingIndicator {
            playMessageSound()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.25)) {
                scrollToLastMessage()
            }
        }
    }
}

// MARK: - Extensions
private extension ContentView {
    func generateMathQuestion() -> MathQuestion {
        switch difficulty {
        case .easy:
            let type = Int.random(in: 0..<2)
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

    func scrollToLastMessage() {
        NotificationCenter.default.post(
            name: NSNotification.Name("ScrollToLastMessage"), object: nil)
    }

    func playMessageSound() {
        if let url = Bundle.main.url(forResource: "Message", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                return
            } catch {}
        }
        if let asset = NSDataAsset(name: "Message") {
            do {
                audioPlayer = try AVAudioPlayer(data: asset.data)
                audioPlayer?.play()
            } catch {}
        }
    }
}

#if DEBUG
#Preview {
    ContentView()
}
#endif
