import SwiftUI

struct MathOperationsView: View {
    @Binding var mathOperations: MathOperationSettings
    let questionMode: QuestionMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Select Math Operations") {
                Toggle("Addition (X + Y)", isOn: $mathOperations.additionEnabled)
                Toggle("Subtraction (X - Y)", isOn: $mathOperations.subtractionEnabled)
                Toggle("Multiplication (X × Y)", isOn: $mathOperations.multiplicationEnabled)
                Toggle("Division (X ÷ Y)", isOn: $mathOperations.divisionEnabled)
            }
            
            Section {
                Button("Enable All") {
                    mathOperations.additionEnabled = true
                    mathOperations.subtractionEnabled = true
                    mathOperations.multiplicationEnabled = true
                    mathOperations.divisionEnabled = true
                }
                
                Button("Disable All") {
                    mathOperations.additionEnabled = false
                    mathOperations.subtractionEnabled = false
                    mathOperations.multiplicationEnabled = false
                    mathOperations.divisionEnabled = false
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle("Math Operations")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
}

#Preview {
    MathOperationsView(
        mathOperations: .constant(MathOperationSettings()),
        questionMode: .random
    )
}
