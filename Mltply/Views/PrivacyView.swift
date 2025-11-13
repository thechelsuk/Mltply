import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Privacy Policy")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Last updated: June 9, 2025")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Group {
                        Text("Overview")
                            .font(.headline)
                        Text("This app is designed with privacy in mind. We do not collect personal information or send your content to external servers. All data used by the app is stored locally on your device.")

                        Text("Information We Don’t Collect")
                            .font(.headline)
                        Text("We do not collect personal data, usage analytics, account information, or content from your device. No account creation or login is required.")

                        Text("Local Storage")
                            .font(.headline)
                        Text("Settings, preferences, and question history are stored locally on your device (for iOS this may be in app storage or iCloud, depending on settings). Your content stays on your device unless you explicitly export or share it.")

                        Text("How We Use Information")
                            .font(.headline)
                        Text("Because the app does not collect personal data, processing happens on-device only. This includes generating questions, tracking scores, and updating achievements.")

                        Text("Data Security")
                            .font(.headline)
                        Text("We do not transmit data to remote servers. Your data security therefore depends on the device’s security (passcode, Face ID/Touch ID, backups you manage).")

                        Text("Third-Party Services")
                            .font(.headline)
                        Text("The app does not integrate with external analytics or tracking services. If any third-party libraries are used, they are for internal functionality and do not send user content off device.")

                        Text("Children’s Privacy")
                            .font(.headline)
                        Text("The app does not knowingly collect data from children under 13. Because no personal data is collected, COPPA concerns are limited. Parental supervision is recommended for young children.")

                        Text("Changes to this Policy")
                            .font(.headline)
                        Text("We may update this policy from time to time. Any changes will be reflected in the app’s Privacy section with an updated date.")

                        Text("Contact")
                            .font(.headline)
                        Text("If you have questions about privacy, ask a grown-up to contact us through the app’s support channels.")
                    }
                    .font(.body)
                    .foregroundStyle(.primary)

                    Spacer().frame(height: 16)

                    Text("This is a concise summary of the app’s privacy approach. For full details or any legal disclaimers, see the app website.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
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
    PrivacyView()
}
