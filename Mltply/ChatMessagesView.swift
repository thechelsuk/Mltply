import Foundation
import SwiftUI

struct ChatMessagesView: View {
    let messages: [ChatMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages.indices, id: \.self) { idx in
                        let message = messages[idx]
                        HStack(alignment: .bottom, spacing: 8) {
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
                                HStack(alignment: .bottom, spacing: 8) {
                                    Image("robot")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .background(Circle().fill(Color.white))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                    if isQuizQuestion(message: message) {
                                        Text(message.text)
                                            .accessibilityIdentifier("questionLabel")
                                            .padding(12)
                                            .frame(width: 260, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color(.systemGray5))
                                            )
                                            .foregroundColor(.primary)
                                            .shadow(
                                                color: Color.black.opacity(0.05), radius: 1, x: 0,
                                                y: 1
                                            )
                                    } else {
                                        Text(message.text)
                                            .accessibilityIdentifier(
                                                message.accessibilityIdentifier ?? ""
                                            )
                                            .padding(12)
                                            .frame(width: 260, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color(.systemGray5))
                                            )
                                            .foregroundColor(.primary)
                                            .shadow(
                                                color: Color.black.opacity(0.05), radius: 1, x: 0,
                                                y: 1
                                            )
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 4)
                        .id(message.id)
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.gray.opacity(0.04))
                )
                .padding(.horizontal, 4)
            }
            .onChange(of: messages) { _, _ in
                // Always scroll to the last message when messages change
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    if let last = messages.last {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .onAppear {
                // Scroll to last message on appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    if let last = messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

// Helper to detect quiz questions
private func isQuizQuestion(message: ChatMessage) -> Bool {
    guard !message.isUser, !message.isTypingIndicator else { return false }
    // Heuristic: math questions always start with "What is " and end with "?"
    return message.text.hasPrefix("What is ") && message.text.hasSuffix("?")
}

struct TypingIndicatorView: View {
    @State private var dots = ""
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    var body: some View {
        Text("…")
            .font(.body)
            .foregroundColor(.secondary)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.15))
            .cornerRadius(16)
            .frame(width: 60, alignment: .leading)
            .accessibilityIdentifier("typingIndicator")
    }
}
