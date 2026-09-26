import SwiftUI

struct SettingsView:View {
 @Environment(\.dismiss) private var dismiss
 @State private var apiKey=""
 @State private var statusMessage:String?
 @AppStorage("defaultSystemPrompt") private var systemPrompt=""
 @ObservedObject private var catalog=ModelCatalogStore.shared

 private var hasKey:Bool{!KeychainStore.read().isEmpty}

 var body:some View {
  NavigationStack {
   ZStack {
    NChatPageBackground()
    Form {
     Section {
      HStack(spacing:12) {
       ZStack{RoundedRectangle(cornerRadius:14).fill(NChatTheme.gradient);Image(systemName:"sparkles").foregroundStyle(.white)}.frame(width:46,height:46)
       VStack(alignment:.leading,spacing:3) {
        Text("NChat").font(.headline)
        Text("NVIDIA-powered AI workspace").font(.caption).foregroundStyle(.secondary)
       }
       Spacer()
       Text(hasKey ? "Connected":"Not connected").font(.caption.weight(.semibold)).foregroundStyle(hasKey ? .green:.secondary)
      }
     }

     Section("NVIDIA API") {
      SecureField("nvapi-…",text:$apiKey).textContentType(.password).autocorrectionDisabled().textInputAutocapitalization(.never)
      Button {
       saveKey()
      } label:{
       Label("Save key & verify models",systemImage:"checkmark.shield")
      }
      .disabled(apiKey.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty)

      if catalog.isLoading {
       ProgressView(value:catalog.progress).tint(NChatTheme.pink)
       Text("Testing \(catalog.testedCount) of \(catalog.totalToTest) candidate models").font(.caption).foregroundStyle(.secondary)
      } else if hasKey {
       LabeledContent("Verified chat models",value:"\(catalog.passedModels.count)")
       if let date=catalog.lastValidatedAt {
        LabeledContent("Last checked",value:date.formatted(date:.abbreviated,time:.shortened))
       }
       Button("Retest NVIDIA catalog"){Task{await catalog.refreshAndValidate(force:true)}}
       Button("Remove API Key",role:.destructive){KeychainStore.delete();apiKey="";statusMessage="API key removed from this device."}
      }
      if let statusMessage{Text(statusMessage).font(.caption).foregroundStyle(.secondary)}
      if let error=catalog.error{Text(error).font(.caption).foregroundStyle(.orange)}
     }

     Section("AI") {
      NavigationLink{ModelsView()}label:{settingsRow("Verified Models",subtitle:"\(catalog.passedModels.count) available",icon:"checkmark.seal")}
      NavigationLink{AgentsView()}label:{settingsRow("Orchestrator & Agents",subtitle:"Delegate focused work",icon:"point.3.connected.trianglepath.dotted")}
      NavigationLink{GenerationSettingsView()}label:{settingsRow("Generation",subtitle:"Sampling, output and reasoning",icon:"slider.horizontal.3")}
     }

     Section("Custom instructions") {
      TextEditor(text:$systemPrompt).frame(minHeight:120)
      Text("These instructions are appended after NChat's built-in language, RTL and response-quality policy.").font(.caption).foregroundStyle(.secondary)
     }

     Section("Privacy") {
      Label("API key is stored in iOS Keychain",systemImage:"lock.shield")
      Label("Conversation history is stored locally on this device",systemImage:"iphone")
      Text("NChat sends conversation content and selected attachments to NVIDIA only when you send a message.").font(.caption).foregroundStyle(.secondary)
     }

     Section("About") {
      LabeledContent("Version",value:AppSettings.appVersion)
      LabeledContent("Build",value:"20")
      LabeledContent("Provider",value:"NVIDIA NIM")
     }
    }
    .scrollContentBackground(.hidden)
   }
   .navigationTitle("Settings")
   .toolbar{ToolbarItem(placement:.confirmationAction){Button("Done"){dismiss()}}}
  }
  .tint(NChatTheme.pink)
 }

 @ViewBuilder private func settingsRow(_ title:String,subtitle:String,icon:String)->some View {
  HStack(spacing:12) {
   Image(systemName:icon).frame(width:28).foregroundStyle(NChatTheme.pink)
   VStack(alignment:.leading,spacing:2){Text(title);Text(subtitle).font(.caption).foregroundStyle(.secondary)}
  }
 }

 private func saveKey() {
  let value=apiKey.trimmingCharacters(in:.whitespacesAndNewlines)
  guard !value.isEmpty else{return}
  do {
   try KeychainStore.save(value)
   apiKey=""
   statusMessage="Key saved securely. Verifying available models…"
   Task{await catalog.refreshAndValidate(force:true)}
  } catch {
   statusMessage="Could not save the API key: \(error.localizedDescription)"
  }
 }
}
