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
    @StateObject private var viewModel = QuizViewModel()
    // MARK: - View
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if !viewModel.continuousMode {
                    TimerView(
                        timeRemaining: viewModel.timeRemaining, timeString: viewModel.timeString)
                }
                ChatMessagesView(messages: viewModel.messages)
                if viewModel.showMathOperationsCard {
                    ChatCardView(
                        card: ChatCardType(kind: .mathOperations),
                        mathOperations: $viewModel.mathOperations,
                        onSelect: { viewModel.showStartCard = true },
                        addMessage: nil
                    )
                    .padding(.bottom, 8)
                } else if viewModel.showStartCard {
                    ChatCardView(
                        card: ChatCardType(kind: .start),
                        mathOperations: $viewModel.mathOperations,
                        onSelect: { viewModel.startQuiz() },
                        addMessage: nil
                    )
                    .padding(.bottom, 8)
                } else if viewModel.showPlayAgain {
                    Button(action: viewModel.playAgain) {
                        Text("Play Again")
                            .font(.headline)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                    }
                    .accessibilityIdentifier("playAgainButton")
                    .padding(.bottom, 8)
                } else {
                    UserInputView(
                        userInput: $viewModel.userInput,
                        currentQuestion: viewModel.currentQuestion,
                        hasStarted: viewModel.hasStarted,
                        sendMessage: viewModel.sendMessage
                    )
                    if viewModel.isBotTyping {
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
                trailing: Button(action: { viewModel.showSettings = true }) {
                    Image(systemName: "gearshape")
                }
            )
            .sheet(isPresented: $viewModel.showSettings) {
                SettingsView(
                    appColorScheme: $viewModel.appColorScheme,
                    mathOperations: $viewModel.mathOperations,
                    continuousMode: $viewModel.continuousMode,
                    timerDuration: $viewModel.timerDuration,
                    soundEnabled: $viewModel.soundEnabled
                )
            }
        }
        .preferredColorScheme(viewModel.appColorScheme.colorScheme)
        .onReceive(viewModel.timer) { _ in
            viewModel.handleTimerTick()
        }
        .onAppear {
            viewModel.resetForWelcome()
        }
        .onChange(of: viewModel.timerDuration) { newValue, _ in
            viewModel.handleTimerDurationChange(newValue)
        }
        .onChange(of: viewModel.messages) { _, _ in
            viewModel.handleMessagesChange()
        }
    }
}

// MARK: - Extensions
extension ContentView {
    fileprivate func scrollToLastMessage() {
        NotificationCenter.default.post(
            name: NSNotification.Name("ScrollToLastMessage"), object: nil)
    }

    fileprivate func playMessageSound() {
        if let url = Bundle.main.url(forResource: "Message", withExtension: "wav") {
            viewModel.audioPlayer = try? AVAudioPlayer(contentsOf: url)
            viewModel.audioPlayer?.play()
            return
        }
        if let asset = NSDataAsset(name: "Message") {
            viewModel.audioPlayer = try? AVAudioPlayer(data: asset.data)
            viewModel.audioPlayer?.play()
        }
    }
}

#if DEBUG
    #Preview {
        ContentView()
    }
#endif
