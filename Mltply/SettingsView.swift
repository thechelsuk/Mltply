import SwiftUI

struct SettingsView: View {
    @Binding var appColorScheme: AppColorScheme
    @Binding var mathOperations: MathOperationSettings
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

                Section(header: Text("Math Operations")) {
                    Toggle("Addition (X + Y)", isOn: $mathOperations.additionEnabled)
                    Toggle("Subtraction (X - Y)", isOn: $mathOperations.subtractionEnabled)
                    Toggle("Multiplication (X × Y)", isOn: $mathOperations.multiplicationEnabled)
                    Toggle("Division (X ÷ Y)", isOn: $mathOperations.divisionEnabled)
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
