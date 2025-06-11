import SwiftUI

struct SettingsView: View {
    @Binding var appColorScheme: AppColorScheme
    @Binding var mathOperations: MathOperationSettings
    @Binding var continuousMode: Bool
    @Binding var timerDuration: Int
    @Binding var soundEnabled: Bool
    @Binding var questionMode: QuestionMode
    @Binding var practiceSettings: PracticeSettings
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingClearHistoryAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Appearance", selection: $appColorScheme) {
                        ForEach(AppColorScheme.allCases) { scheme in
                            Text(scheme.displayName)
                                .tag(scheme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Set Timer Options")) {
                    Toggle("Continuous Mode", isOn: $continuousMode)
                    if !continuousMode {
                        HStack {
                            Text("Duration")
                            Slider(
                                value: Binding(
                                    get: { Double(timerDuration) }, set: { timerDuration = Int($0) }
                                ),
                                in: 1...10, step: 1
                            )
                            .accessibilityIdentifier("timerSlider")
                            Text("\(timerDuration)m")
                                .font(.headline)
                                .accessibilityIdentifier("timerDurationLabel")
                        }
                    }
                }
                
                Section(header: Text("Math Configuration options")) {
                    HStack {
                        Text("Question Order")
                        Spacer()
                        Picker("Order", selection: $questionMode) {
                            ForEach(QuestionMode.allCases) { mode in
                                Image(systemName: mode.iconName)
                                    .tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 80)
                    }
                    NavigationLink(destination: NumberSelectionView(practiceSettings: $practiceSettings)) {
                        Text("Select Numbers")
                    }
                    NavigationLink(destination: MathOperationsView(mathOperations: $mathOperations, questionMode: questionMode)) {
                        Text("Selecct Math Operations")
                    }
                }

                Section(header: Text("Chat Options")) {
                    Toggle("Enable Sound", isOn: $soundEnabled)
                    Button(action: {
                        showingClearHistoryAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Clear Message History")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section(header: Text("Legal")) {
                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        HStack {
                            Text("Terms of Use")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        // Placeholder for privacy policy
                        print("Privacy Policy - Coming Soon")
                    }) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("Coming Soon")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .disabled(true)
                }

            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
            .alert("Clear Message History", isPresented: $showingClearHistoryAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearMessageHistory()
                }
            } message: {
                Text("This will permanently delete all chat messages. This action cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView(
        appColorScheme: .constant(.system),
        mathOperations: .constant(MathOperationSettings()),
        continuousMode: .constant(true),
        timerDuration: .constant(2),
        soundEnabled: .constant(true),
        questionMode: .constant(.random),
        practiceSettings: .constant(PracticeSettings()),
        viewModel: QuizViewModel()
    )
}
