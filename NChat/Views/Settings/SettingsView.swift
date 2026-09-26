import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey=""
    @State private var saved=false
    @AppStorage("defaultSystemPrompt") private var systemPrompt=""
    @AppStorage("customModel") private var customModel=""

    var body: some View {
        NavigationStack {
            Form {
                Section("NVIDIA API") {
                    SecureField("nvapi-…",text:$apiKey).textContentType(.password)
                    Button(saved ? "Saved ✓" : "Save API Key") { do { try KeychainStore.save(apiKey); saved=true; apiKey="" } catch {} }.disabled(apiKey.isEmpty)
                    if !KeychainStore.read().isEmpty { Button("Remove API Key",role:.destructive) { KeychainStore.delete(); saved=false } }
                }
                Section("Default system prompt") { TextEditor(text:$systemPrompt).frame(minHeight:110) }
                Section("Models") {
                    ForEach(ModelOption.featured) { model in
                        VStack(alignment:.leading) { Text(model.title); Text(model.id).font(.caption).foregroundStyle(.secondary).textSelection(.enabled) }
                    }
                    TextField("Custom model ID",text:$customModel).textInputAutocapitalization(.never).autocorrectionDisabled()
                }
                Section("Privacy") { Label("API key is stored in iOS Keychain",systemImage:"lock.shield"); Label("Chats stay on this device",systemImage:"iphone") }
                Section("About") { LabeledContent("Provider", value: "NVIDIA NIM"); LabeledContent("Client", value: "Native SwiftUI"); LabeledContent("Minimum iOS", value: "17.0") }
            }
            .navigationTitle("Settings")
            .toolbar { ToolbarItem(placement:.confirmationAction) { Button("Done"){dismiss()} } }
        }
    }
}
