import SwiftUI

struct SettingsView: View {
    @Binding var appColorScheme: AppColorScheme
    @Binding var mathOperations: MathOperationSettings
    @Binding var continuousMode: Bool
    @Binding var timerDuration: Int
    @Binding var soundEnabled: Bool
    @Binding var questionMode: QuestionMode
    @Binding var practiceSettings: PracticeSettings
    @Environment(\.presentationMode) var presentationMode

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

                Section(header: Text("Timer")) {
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
                
                Section(header: Text("Question Order")) {
                    Picker("Order", selection: $questionMode) {
                        ForEach(QuestionMode.allCases) { mode in
                            Text(mode.displayName)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Numbers to Practice")) {
                    NavigationLink(destination: NumberSelectionView(practiceSettings: $practiceSettings)) {
                        Text("Choose Numbers")
                    }
                }

                Section(header: Text("Math Operations")) {
                    NavigationLink(destination: MathOperationsView(mathOperations: $mathOperations, questionMode: questionMode)) {
                        Text("Select Operations")
                    }
                }

                Section(header: Text("Sound")) {
                    Toggle("Enable Sound", isOn: $soundEnabled)
                }

            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
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
        practiceSettings: .constant(PracticeSettings())
    )
}
