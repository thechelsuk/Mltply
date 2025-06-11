import SwiftUI

struct MathOperationsView: View {
    @Binding var mathOperations: MathOperationSettings
    let questionMode: QuestionMode
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Math Operations")) {
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
                    .foregroundColor(.red)
                }
            }
            .navigationBarTitle("Math Operations", displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
}

#Preview {
    MathOperationsView(
        mathOperations: .constant(MathOperationSettings()),
        questionMode: .random
    )
}
