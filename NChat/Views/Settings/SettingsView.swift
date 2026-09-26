import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey = ""
    @State private var saved = false
    @AppStorage("defaultSystemPrompt") private var systemPrompt = ""
    @ObservedObject private var catalog = ModelCatalogStore.shared

    var body: some View {
        NavigationStack {
            ZStack {
                NChatTheme.background.ignoresSafeArea()
                Form {
                    Section("NVIDIA API") {
                        SecureField("nvapi-…", text: $apiKey)
                            .textContentType(.password)
                        Button(saved ? "Saved & testing models…" : "Save key & test all models") {
                            do {
                                try KeychainStore.save(apiKey)
                                saved = true
                                apiKey = ""
                                Task { await catalog.refreshAndValidate(force:true) }
                            } catch { }
                        }
                        .disabled(apiKey.isEmpty)

                        if catalog.isLoading {
                            ProgressView(value: catalog.progress)
                            Text("\(catalog.testedCount) / \(catalog.totalToTest) tested")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !KeychainStore.read().isEmpty {
                            Button("Remove API Key", role: .destructive) {
                                KeychainStore.delete()
                                saved = false
                            }
                        }
                    }
                    Section("AI") {
                        NavigationLink { ModelsView() } label: {
                            Label("Verified Models (\(catalog.passedModels.count))", systemImage: "checkmark.seal")
                        }
                        NavigationLink { AgentsView() } label: {
                            Label("Orchestrator & Agents", systemImage: "point.3.connected.trianglepath.dotted")
                        }
                        NavigationLink { GenerationSettingsView() } label: {
                            Label("Generation", systemImage: "slider.horizontal.3")
                        }
                    }
                    Section("Custom instructions") {
                        TextEditor(text: $systemPrompt).frame(minHeight: 100)
                        Text("NChat's built-in language and quality policy is always applied first.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Section("Privacy") {
                        Label("API key stays in iOS Keychain", systemImage: "lock.shield")
                        Label("Chats are stored locally", systemImage: "iphone")
                    }
                    Section("About") {
                        LabeledContent("Version", value: AppSettings.appVersion)
                        LabeledContent("Build", value: "20")
                        LabeledContent("Provider", value: "NVIDIA NIM")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .tint(NChatTheme.pink)
    }
}
