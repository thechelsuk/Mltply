//
//  ContentView.swift
//  Mltply
//
//  Created by Mat Benfield on 11/05/2025.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var tapback: Tapback? = nil
}

enum Tapback: String {
    case correct, incorrect
}

struct MathQuestion {
    let question: String
    let answer: Int
}

enum Difficulty: String, CaseIterable {
    case easy, medium, hard
}

enum AppColorScheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct SettingsView: View {
    @Binding var timerDuration: Int
    @Binding var difficulty: Difficulty
    @Binding var appColorScheme: AppColorScheme
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Timer Duration")) {
                    VStack(alignment: .leading) {
                        Slider(
                            value: Binding(
                                get: { Double(timerDuration) },
                                set: { timerDuration = Int($0) }
                            ), in: 1...10, step: 1)
                        Text("\(timerDuration) minute\(timerDuration == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Section(header: Text("Difficulty")) {
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Appearance")) {
                    Picker("Appearance", selection: $appColorScheme) {
                        ForEach(AppColorScheme.allCases) { scheme in
                            Text(scheme.displayName)
                                .tag(scheme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
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

struct ContentView: View {
    @State private var timeRemaining: Int = 600  // 10 minutes in seconds
    @State private var timerActive: Bool = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi! I'm your math robot. Ready to start?", isUser: false)
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

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TimerView(timeRemaining: timeRemaining, timeString: timeString)
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
            // Show only welcome message, wait for user to start
            messages = [
                ChatMessage(
                    text: "Hi! I'm your math robot. Type anything to start your quiz!",
                    isUser: false)
            ]
            hasStarted = false
            timerActive = false
            currentQuestion = nil
            showPlayAgain = false
        }
        .onChange(of: timerDuration) { newValue, _ in
            // Reset timer and state when timer duration changes
            timeRemaining = newValue * 60
            timerActive = false
            hasStarted = false
            messages = [
                ChatMessage(
                    text: "Hi! I'm your math robot. Type anything to start your quiz!",
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
                    text: "Hi! I'm your math robot. Type anything to start your quiz!",
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
        let summary =
            "Time's up! You answered \(correctAnswers) out of \(totalQuestions) questions correctly.\nIncorrect answers: \(incorrectAnswers)"
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

#Preview {
    ContentView()
}
struct TimerView: View {
    let timeRemaining: Int
    let timeString: String

    var body: some View {
        VStack(spacing: 4) {
            Text("Time Remaining")
                .font(.headline)
            Text(timeString)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(timeRemaining > 0 ? .primary : .red)
        }
        .padding(.top)
    }
}

struct ChatMessagesView: View {
    let messages: [ChatMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        HStack(alignment: .bottom, spacing: 4) {
                            if message.isUser {
                                Spacer()
                                ZStack(alignment: .bottomTrailing) {
                                    Text(message.text)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.blue)
                                        )
                                        .foregroundColor(.white)
                                        .shadow(
                                            color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1
                                        )
                                        .frame(maxWidth: 260, alignment: .trailing)
                                    if let tapback = message.tapback {
                                        Group {
                                            if tapback == .correct {
                                                Text("🎉")
                                                    .font(.system(size: 24))
                                                    .padding(.top, 4)
                                            } else if tapback == .incorrect {
                                                Text("👎")
                                                    .font(.system(size: 24))
                                                    .padding(.top, 4)
                                            }
                                        }
                                        .offset(x: 0, y: 32)
                                    }
                                }
                            } else {
                                HStack(spacing: 8) {
                                    Image("robot_icon")
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(
                                                Color.gray.opacity(0.3), lineWidth: 1))
                                    Text(message.text)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color(.systemGray5))
                                        )
                                        .foregroundColor(.primary)
                                        .shadow(
                                            color: Color.black.opacity(0.05), radius: 1, x: 0,
                                            y: 1
                                        )
                                        .frame(maxWidth: 260, alignment: .leading)
                                }
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 4)
                        .id(message.id)
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                )
                .padding(.horizontal, 4)
            }
            .onChange(of: messages) { _ in
                // Improved: Always scroll to the last message, with a slight delay to ensure layout is updated
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    if let last = messages.last {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}

struct UserInputView: View {
    @Binding var userInput: String
    let currentQuestion: MathQuestion?
    let hasStarted: Bool
    let sendMessage: () -> Void

    var body: some View {
        HStack {
            if currentQuestion != nil && hasStarted {
                TextField("Type your answer...", text: $userInput, onCommit: sendMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 36)
                    .keyboardType(.numberPad)
            } else {
                TextField("Type your message...", text: $userInput, onCommit: sendMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 36)
                    .keyboardType(.default)
            }
            Button(action: sendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(userInput.isEmpty ? .gray : .blue)
            }
            .disabled(userInput.isEmpty)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
