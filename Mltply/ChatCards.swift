import Foundation
import SwiftUI

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
                if card.kind == .timer {
                    Text("Choose your timer:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                    VStack(alignment: .leading, spacing: 8) {
                        Slider(
                            value: Binding(
                                get: { Double(timerDuration) },
                                set: { newValue in
                                    timerDuration = Int(newValue)
                                    localTimer = newValue
                                    showTimerResult = false
                                }
                            ), in: 1...10, step: 1
                        )
                        Text("\(timerDuration) minute\(timerDuration == 1 ? "" : "s")")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Button(action: {
                            showTimerResult = true
                            onSelect()
                        }) {
                            Text("Set Timer")
                                .font(.subheadline)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 18)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.top, 2)
                        if showTimerResult {
                            Text(
                                "Timer set to \(timerDuration) minute\(timerDuration == 1 ? "" : "s")!"
                            )
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.top, 4)
                        }
                    }
                } else if card.kind == .difficulty {
                    Text("Choose your difficulty:")
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
                            }) {
                                Text(level.rawValue.capitalized)
                                    .font(.headline)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 18)
                                    .background(
                                        difficulty == level ? Color.blue : Color(.systemGray5)
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
                } else if card.kind == .start {
                    Text("Ready to begin?")
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
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemGray6)))
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }
}
