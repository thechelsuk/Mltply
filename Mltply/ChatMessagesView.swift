import Foundation
import SwiftUI

struct ChatMessagesView: View {
    let messages: [ChatMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        ChatMessageRow(message: message)
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
