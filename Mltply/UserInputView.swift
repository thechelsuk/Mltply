import SwiftUI

struct UserInputView: View {
    @Binding var userInput: String
    let currentQuestion: MathQuestion?
    let hasStarted: Bool
    let sendMessage: () -> Void

    var body: some View {
        HStack {
            if currentQuestion != nil && hasStarted {
                TextField("Type your answer...", text: $userInput, onCommit: sendMessage)
                    .accessibilityIdentifier("userInputField")
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
