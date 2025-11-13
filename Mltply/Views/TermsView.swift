import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("End User License Agreement")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Group {
                        Text("License")
                            .font(.headline)
                        Text("Apps from the App Store are licensed to you, not sold. The license lets you use the app on Apple devices you own or control. You may not redistribute, sublicense, or transfer the app except as allowed by law.")

                        Text("Scope and Use")
                            .font(.headline)
                        Text("The app and any updates are covered by the terms here unless a custom license is provided. You should not reverse-engineer, copy, or modify the app unless allowed by law.")

                        Text("Data and Technical Information")
                            .font(.headline)
                        Text("The app or its provider may collect technical information (device, system, crash reports) for improving the app. Such information is normally anonymized and used to provide updates and support.")

                        Text("External Services")
                            .font(.headline)
                        Text("The app may provide links or access to third-party services. Those services are outside the app provider’s control; use them at your own risk and follow their terms.")

                        Text("No Warranty")
                            .font(.headline)
                        Text("The app is provided 'as is'. To the maximum extent allowed by law, there are no warranties. Some jurisdictions may limit this exclusion.")

                        Text("Limitation of Liability")
                            .font(.headline)
                        Text("Except where prohibited by law, liability is limited and may be capped. This means the provider is not responsible for incidental or consequential damages in many cases.")

                        Text("Termination")
                            .font(.headline)
                        Text("If you do not follow the terms, your license may end. You must remove the app if you transfer the device to someone else when required by the agreement.")

                        Text("Governing Law")
                            .font(.headline)
                        Text("The agreement includes governing law and dispute clauses that may specify a jurisdiction, often the provider’s home jurisdiction or as otherwise stated in the full license.")
                    }
                    .font(.body)
                    .foregroundStyle(.primary)

                    Spacer()
                        .frame(height: 24)

                    Text("This is a simplified summary of Apple’s standard EULA for apps. For full legal terms, refer to Apple’s official Licensed Application EULA.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Terms of Use")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TermsView()
}
