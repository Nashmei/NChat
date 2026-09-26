import SwiftUI
struct SettingsView:View {
 @Environment(\.dismiss) private var dismiss
 @State private var apiKey="";@State private var saved=false
 @AppStorage("defaultSystemPrompt") private var systemPrompt=""
 var body:some View{
  NavigationStack{Form{
   Section("NVIDIA API"){SecureField("nvapi-…",text:$apiKey).textContentType(.password);Button(saved ? "Saved ✓":"Save API Key"){do{try KeychainStore.save(apiKey);saved=true;apiKey="";Task{await ModelCatalogStore.shared.refresh()}}catch{}}.disabled(apiKey.isEmpty);if !KeychainStore.read().isEmpty{Button("Remove API Key",role:.destructive){KeychainStore.delete();saved=false}}}
   Section("AI"){NavigationLink{ModelsView()}{Label("Models",systemImage:"cpu")};NavigationLink{AgentsView()}{Label("Orchestrator & Agents",systemImage:"point.3.connected.trianglepath.dotted")};NavigationLink{GenerationSettingsView()}{Label("Generation",systemImage:"slider.horizontal.3")}}
   Section("Default system prompt"){TextEditor(text:$systemPrompt).frame(minHeight:110)}
   Section("Privacy"){Label("API key stays in iOS Keychain",systemImage:"lock.shield");Label("Chats are local-first",systemImage:"iphone")}
   Section("About"){LabeledContent("Provider",value:"NVIDIA NIM");LabeledContent("Client",value:"Native SwiftUI");LabeledContent("Minimum iOS",value:"17.0")}
  }.navigationTitle("Settings").toolbar{ToolbarItem(placement:.confirmationAction){Button("Done"){dismiss()}}}}
 }
}
