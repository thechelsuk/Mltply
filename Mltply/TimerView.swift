import SwiftUI

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
