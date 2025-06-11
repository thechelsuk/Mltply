import SwiftUI

struct NumberSelectionView: View {
    @Binding var practiceSettings: PracticeSettings
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Numbers for Practice")) {
                    ForEach(1...12, id: \.self) { number in
                        HStack {
                            Text("\(number)")
                                .font(.headline)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { practiceSettings.selectedNumbers.contains(number) },
                                set: { isSelected in
                                    if isSelected {
                                        practiceSettings.selectedNumbers.insert(number)
                                    } else {
                                        practiceSettings.selectedNumbers.remove(number)
                                    }
                                }
                            ))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if practiceSettings.selectedNumbers.contains(number) {
                                practiceSettings.selectedNumbers.remove(number)
                            } else {
                                practiceSettings.selectedNumbers.insert(number)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Select All") {
                        practiceSettings.selectedNumbers = Set(1...12)
                    }
                    
                    Button("Clear All") {
                        practiceSettings.selectedNumbers.removeAll()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationBarTitle("Choose Numbers", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    NumberSelectionView(practiceSettings: .constant(PracticeSettings()))
}
