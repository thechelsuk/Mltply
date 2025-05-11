import SwiftUI

struct SettingsView: View {
    @Binding var timerDuration: Int
    @Binding var difficulty: Difficulty
    @Binding var appColorScheme: AppColorScheme
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Timer Duration")) {
                    VStack(alignment: .leading) {
                        Slider(
                            value: Binding(
                                get: { Double(timerDuration) },
                                set: { timerDuration = Int($0) }
                            ), in: 1...10, step: 1)
                        Text("\(timerDuration) minute\(timerDuration == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Section(header: Text("Difficulty")) {
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(Difficulty.allCases, id: \.self) { level in
                            Text(level.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Appearance")) {
                    Picker("Appearance", selection: $appColorScheme) {
                        ForEach(AppColorScheme.allCases) { scheme in
                            Text(scheme.displayName)
                                .tag(scheme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
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
