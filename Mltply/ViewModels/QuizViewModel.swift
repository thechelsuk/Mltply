import AVFoundation
import Foundation
import SwiftUI

// MARK: - Models and BotMessages
// These are in Models.swift and BotMessages.swift
// If using modules, import Mltply

// Import all models and bot messages

class QuizViewModel: ObservableObject {
    // MARK: - Published State
    @Published var timeRemaining: Int = 120
    @Published var timerActive: Bool = true
    @Published var messages: [ChatMessage] = [ChatMessage(text: BotMessages.welcome, isUser: false)]
    @Published var userInput: String = ""
    @Published var currentQuestion: MathQuestion? = nil
    @Published var correctAnswers: Int = 0
    @Published var totalQuestions: Int = 0
    @Published var incorrectAnswers: Int = 0
    @Published var showSettings = false
    @Published var timerDuration: Int = 2
    @Published var hasStarted: Bool = false
    @Published var appColorScheme: AppColorScheme = .system
    @Published var showPlayAgain: Bool = false
    @Published var showMathOperationsCard: Bool = false
    @Published var showStartCard: Bool = false
    @Published var isBotTyping: Bool = false
    @Published var audioPlayer: AVAudioPlayer? = nil
    @Published var mathOperations = MathOperationSettings()
    @Published var continuousMode: Bool = true
    @Published var soundEnabled: Bool = false
    @Published var questionMode: QuestionMode = .random
    @Published var practiceSettings = PracticeSettings()
    
    // MARK: - Timer
    // Use the correct type for the timer publisher
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Computed
    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Quiz Logic
    func showBotMessage(_ text: String, delay: Double = 2.0) {
        messages.append(ChatMessage(text: "", isUser: false, isTypingIndicator: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if let idx = self.messages.firstIndex(where: { $0.isTypingIndicator }) {
                self.messages.remove(at: idx)
            }
            self.messages.append(ChatMessage(text: text, isUser: false))
        }
    }
    
    func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        if !hasStarted {
            startQuiz(userMessage: userInput)
            return
        }
        if hasStarted, let question = currentQuestion,
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
            // In timer mode, only continue if timerActive; in continuous mode, always continue
            if timerActive || continuousMode {
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
    
    func showScoreSummary() {
        let allCorrect = totalQuestions > 0 && correctAnswers == totalQuestions
        let trophy = allCorrect ? " 🏆" : ""
        let summary =
        "Time's up! You answered \(correctAnswers) out of \(totalQuestions) questions correctly.\nIncorrect answers: \(incorrectAnswers)\(trophy)"
        showBotMessage(summary)
        showBotMessage(BotMessages.playAgain, delay: 2.5)
        showPlayAgain = true
    }
    
    func playAgain() {
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
        }
        showPlayAgain = false
        showMathOperationsCard = false
        showStartCard = false
        currentQuestion = nil
        
        // Reset practice settings
        practiceSettings.reset()
    }
    
    func startQuiz(userMessage: String? = nil) {
        hasStarted = true
        timerActive = !continuousMode
        timeRemaining = timerDuration * 60
        if let userMessage = userMessage {
            messages.append(ChatMessage(text: userMessage, isUser: true))
            userInput = ""
        }
        // Sequentially show letsgo and first question with delays
        showLetsGoAndFirstQuestion()
        showPlayAgain = false
    }
    
    private func showLetsGoAndFirstQuestion() {
        messages.append(ChatMessage(text: "", isUser: false, isTypingIndicator: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let idx = self.messages.firstIndex(where: { $0.isTypingIndicator }) {
                self.messages.remove(at: idx)
            }
            self.messages.append(ChatMessage(text: BotMessages.letsGo, isUser: false))
            let question = self.generateMathQuestion()
            self.currentQuestion = question
            self.messages.append(ChatMessage(text: "", isUser: false, isTypingIndicator: true))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let idx2 = self.messages.firstIndex(where: { $0.isTypingIndicator }) {
                    self.messages.remove(at: idx2)
                }
                self.messages.append(ChatMessage(text: question.question, isUser: false))
            }
        }
    }
    
    func handleTimerTick() {
        guard timerActive, timeRemaining > 0, !continuousMode else { return }
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
    
    func resetForWelcome() {
        messages = []
        hasStarted = false
        timerActive = false
        currentQuestion = nil
        showPlayAgain = false
        showMathOperationsCard = false
        showStartCard = false
        // Sequentially show onboarding messages with delay
        showOnboardingSequence()
    }
    
    private func showOnboardingSequence() {
        let onboarding: [(String, String?)] = [
            (BotMessages.welcome, "welcomeMessage"),
            (BotMessages.onboardingSettings, nil),
            (BotMessages.onboardingReply, nil),
        ]
        func showNext(_ idx: Int) {
            guard idx < onboarding.count else { return }
            let (text, id) = onboarding[idx]
            messages.append(ChatMessage(text: "", isUser: false, isTypingIndicator: true))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let typingIdx = self.messages.firstIndex(where: { $0.isTypingIndicator }) {
                    self.messages.remove(at: typingIdx)
                }
                self.messages.append(
                    ChatMessage(text: text, isUser: false, accessibilityIdentifier: id))
                showNext(idx + 1)
            }
        }
        showNext(0)
    }
    
    func handleTimerDurationChange(_ newValue: Int) {
        timerDuration = newValue
        timeRemaining = newValue * 60
        timerActive = false
        hasStarted = false
        messages = [
            ChatMessage(text: BotMessages.welcome, isUser: false),
            ChatMessage(text: BotMessages.onboardingSettings, isUser: false),
            ChatMessage(text: BotMessages.onboardingReply, isUser: false),
        ]
        correctAnswers = 0
        totalQuestions = 0
        incorrectAnswers = 0
        userInput = ""
        currentQuestion = nil
        showPlayAgain = false
        
        // Reset practice settings
        practiceSettings.reset()
    }
    
    func handleMessagesChange() {
        if let last = messages.last, !last.isUser, !last.isTypingIndicator {
            playMessageSound()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.25)) {
                self.scrollToLastMessage()
            }
        }
    }
    
    // MARK: - Helpers
    func generateMathQuestion() -> MathQuestion {
        // Both modes use the same number and operation selection
        // The only difference is the order of questions
        if questionMode == .sequential {
            return generateSequentialQuestion()
        } else {
            return generateRandomQuestion()
        }
    }
    
    private func generateSequentialQuestion() -> MathQuestion {
        guard practiceSettings.hasSelectedNumbers else {
            // Fallback if no numbers selected
            return MathQuestion(question: "What is 6 × 7?", answer: 42)
        }
        
        let currentNumber = practiceSettings.currentNumber
        let multiplier = practiceSettings.currentMultiplier
        
        // Generate question based on enabled operations
        let enabledOps = getEnabledOperations()
        let (_, question, answer) = enabledOps.randomElement()!(currentNumber, multiplier)
        
        // Advance to next question for next time
        practiceSettings.nextQuestion()
        
        return MathQuestion(question: question, answer: answer)
    }
    
    private func generateRandomQuestion() -> MathQuestion {
        guard practiceSettings.hasSelectedNumbers && mathOperations.hasAtLeastOneEnabled else {
            // Fallback
            return MathQuestion(question: "What is 6 × 7?", answer: 42)
        }
        
        // Pick random number from selected numbers
        let selectedNumbers = Array(practiceSettings.selectedNumbers)
        let num1 = selectedNumbers.randomElement()!
        let num2 = Int.random(in: 1...12)
        
        // Generate question based on enabled operations
        let enabledOps = getEnabledOperations()
        let (_, question, answer) = enabledOps.randomElement()!(num1, num2)
        
        return MathQuestion(question: question, answer: answer)
    }
    
    private func getEnabledOperations() -> [(Int, Int) -> (String, String, Int)] {
        var operations: [(Int, Int) -> (String, String, Int)] = []
        
        // Use the same math operations settings for both modes
        if mathOperations.additionEnabled {
            operations.append { num, mult in
                let answer = num + mult
                return ("addition", "What is \(num) + \(mult)?", answer)
            }
        }
        
        if mathOperations.subtractionEnabled {
            operations.append { num, mult in
                // Ensure positive result
                let larger = max(num, mult)
                let smaller = min(num, mult)
                let answer = larger - smaller
                return ("subtraction", "What is \(larger) - \(smaller)?", answer)
            }
        }
        
        if mathOperations.multiplicationEnabled {
            operations.append { num, mult in
                let answer = num * mult
                return ("multiplication", "What is \(num) × \(mult)?", answer)
            }
        }
        
        if mathOperations.divisionEnabled {
            operations.append { num, mult in
                // Create division where num * mult gives a clean division
                let dividend = num * mult
                let answer = num
                return ("division", "What is \(dividend) ÷ \(mult)?", answer)
            }
        }
        
        // Fallback to multiplication if no operations enabled
        if operations.isEmpty {
            operations.append { num, mult in
                let answer = num * mult
                return ("multiplication", "What is \(num) × \(mult)?", answer)
            }
        }
        
        return operations
    }
    
    // MARK: - Settings Change Handlers
    func handleQuestionModeChange() {
        // Reset practice settings when switching modes
        practiceSettings.reset()
    }
    
    func handlePracticeSettingsChange() {
        // Reset the progression when number selection changes
        practiceSettings.reset()
    }
    
    func scrollToLastMessage() {
        NotificationCenter.default.post(
            name: NSNotification.Name("ScrollToLastMessage"), object: nil)
    }
    
    func playMessageSound() {
        guard soundEnabled else { return }
        if let url = Bundle.main.url(forResource: "Message", withExtension: "wav") {
            audioPlayer = try? AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            return
        }
        if let asset = NSDataAsset(name: "Message") {
            audioPlayer = try? AVAudioPlayer(data: asset.data)
            audioPlayer?.play()
        }
    }
    
    init() {
        #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-UITestFastTimer") {
                self.timerDuration = 1
                self.timeRemaining = 1
            }
        #endif
    }
}
