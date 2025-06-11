import SwiftUI

struct TimerView: View {
    let timeRemaining: Int
    let timeString: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("Time: ")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(timeString)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(timeRemaining > 0 ? .primary : .red)
                .accessibilityIdentifier("timerLabel")
        }
        .padding(.top, 4)
        .padding(.bottom, 2)
    }
}

#Preview {
    TimerView(timeRemaining: 120, timeString: "02:00")
}
