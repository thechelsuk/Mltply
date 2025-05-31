import Foundation
import SwiftUI

struct ChatMessagesView: View {
    let messages: [ChatMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages, id: \.id) { message in
                        if message.isTypingIndicator {
                            HStack(alignment: .bottom, spacing: 4) {
                                Image("robot")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .background(Circle().fill(Color.white))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                TypingIndicatorView()
                                Spacer()
                            }
                            .padding(.leading, 4)
                        } else {
                            ChatMessageRow(message: message)
                        }
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.gray.opacity(0.04))
                )
                .padding(.horizontal, 4)
            }
            .onChange(of: messages) { _ in
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

struct ChatMessageRow: View {
    let message: ChatMessage
    var body: some View {
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
                    Image("robot")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.white))
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
    }
}
