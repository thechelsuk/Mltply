import SwiftUI

struct NumberSelectionView: View {
    @Binding var practiceSettings: PracticeSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty Level")
                        .font(.headline)
                    
                    Picker("Difficulty", selection: $practiceSettings.difficulty) {
                        ForEach(NumberDifficulty.allCases) { level in
                            HStack {
                                Image(systemName: level.iconName)
                                Text(level.displayName)
                            }
                            .tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text(difficultyDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            if practiceSettings.difficulty.allowsGranularSelection {
                Section("Select Numbers for Practice") {
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
                    .foregroundStyle(.red)
                }
            } else {
                Section {
                    Text("Numbers will be randomly generated from 1 to \(practiceSettings.difficulty.range.upperBound).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Number Range")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private var difficultyDescription: String {
        switch practiceSettings.difficulty {
        case .starter:
            return "Numbers 1-12 with manual selection"
        case .explorer:
            return "Random numbers from 1-100"
        case .champion:
            return "Random numbers from 1-1,000"
        case .goat:
            return "Random numbers from 1-9,999"
        }
    }
}

#Preview {
    NumberSelectionView(practiceSettings: .constant(PracticeSettings()))
}
