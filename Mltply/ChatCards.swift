import Foundation
import SwiftUI

// BotMessages is in the same target, so no import needed, but ensure file is included in target membership in Xcode.

struct ChatCardType: Identifiable, Equatable {
    enum CardKind: Equatable {
        case timer
        case difficulty
        case start
    }
    let id = UUID()
    let kind: CardKind
}

struct ChatCardView: View {
    let card: ChatCardType
    @Binding var timerDuration: Int
    @Binding var difficulty: Difficulty
    let onSelect: () -> Void

    @State private var localTimer: Double = 1
    @State private var showTimerResult: Bool = false
    @State private var showDifficultyResult: Bool = false
    @State private var selectedDifficulty: Difficulty? = nil
    @State private var showStartResult: Bool = false

    // Add a closure to allow adding messages from the card
    var addMessage: ((String) -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Bot avatar
            Image("robot_icon")
                .resizable()
                .frame(width: 28, height: 28)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            // Card bubble
            VStack(alignment: .leading, spacing: 8) {
                contentView
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.15)))
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .onAppear {
            // Sync localTimer with timerDuration when the card appears
            localTimer = Double(timerDuration)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch card.kind {
        case .timer:
            timerView
        case .difficulty:
            difficultyView
        case .start:
            startView
        }
    }

    private var timerView: some View {
        HStack(spacing: 8) {
            Text("Time Remaining:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Slider(
                value: Binding(
                    get: { Double(timerDuration) },
                    set: { newValue in
                        let rounded = Int(round(newValue))
                        timerDuration = rounded
                        localTimer = Double(rounded)
                        showTimerResult = false
                    }
                ), in: 1...10, step: 1
            )
            .frame(width: 100)
            Text("\(timerDuration)m")
                .font(.headline)
                .foregroundColor(.primary)
            Button(action: {
                showTimerResult = true
                onSelect()
                // Show timer set as a user message
                if let addMessage = addMessage {
                    addMessage(BotMessages.timerSet(timerDuration))
                }
            }) {
                Text("Set")
                    .font(.subheadline)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }

    private var difficultyView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BotMessages.chooseDifficulty)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 2)
            HStack(spacing: 12) {
                ForEach(Difficulty.allCases, id: \.self) { level in
                    Button(action: {
                        difficulty = level
                        selectedDifficulty = level
                        showDifficultyResult = true
                        onSelect()
                        // Show difficulty set as a user message
                        if let addMessage = addMessage {
                            addMessage(BotMessages.difficultySet(level.rawValue))
                        }
                    }) {
                        Text(level.rawValue.capitalized)
                            .font(.headline)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(
                                difficulty == level ? Color.blue : Color.gray.opacity(0.25)
                            )
                            .foregroundColor(difficulty == level ? .white : .primary)
                            .cornerRadius(16)
                            .shadow(
                                color: difficulty == level
                                    ? Color.blue.opacity(0.18) : .clear, radius: 4, x: 0,
                                y: 2)
                    }
                }
            }
            if showDifficultyResult, let selected = selectedDifficulty {
                Text("Difficulty set to \(selected.rawValue.capitalized)!")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
        }
    }

    private var startView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BotMessages.readyToBegin)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 2)
            Button(action: {
                showStartResult = true
                onSelect()
            }) {
                Text("Start Quiz")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 32)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            if showStartResult {
                Text("Let's go!")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.top, 4)
            }
        }
    }
}
