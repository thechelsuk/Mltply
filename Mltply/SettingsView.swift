import SwiftUI

struct SettingsView: View {
    @Binding var appColorScheme: AppColorScheme
    @Binding var mathOperations: MathOperationSettings
    @Binding var continuousMode: Bool
    @Binding var timerDuration: Int
    @Binding var soundEnabled: Bool
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

                Section(header: Text("Math Operations")) {
                    Toggle("Addition (X + Y)", isOn: $mathOperations.additionEnabled)
                    Toggle("Subtraction (X - Y)", isOn: $mathOperations.subtractionEnabled)
                    Toggle("Multiplication (X × Y)", isOn: $mathOperations.multiplicationEnabled)
                    Toggle("Division (X ÷ Y)", isOn: $mathOperations.divisionEnabled)
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
