import SwiftUI
struct AgentsView:View {
 @State private var config=OrchestrationStore.load()
 @ObservedObject private var catalog=ModelCatalogStore.shared
 var body:some View {
  ZStack{NChatTheme.background.ignoresSafeArea();Form{
   Section("Orchestrator"){
    Toggle("Use agents automatically",isOn:$config.enabled)
    Picker("Responsible model",selection:$config.coordinatorModelID){ForEach(catalog.passedModels){Text($0.displayName).tag($0.id)}}
    Text("The responsible model may delegate one task to a verified specialist. If that specialist fails, the main model continues normally.").font(.caption).foregroundStyle(.secondary)
   }
   Section("Agents"){
    ForEach($config.agents){$agent in
     NavigationLink{AgentEditor(agent:$agent,models:catalog.passedModels)}label:{
      HStack{Image(systemName:agent.icon).frame(width:28);VStack(alignment:.leading,spacing:3){Text(agent.name);Text(agent.modelID).font(.caption2).foregroundStyle(.secondary)};Spacer();if catalog.capabilities[agent.modelID]?.passed==true{Image(systemName:"checkmark.seal.fill").foregroundStyle(.green)}}
     }
    }.onDelete{config.agents.remove(atOffsets:$0)}
    Button("Add agent"){config.agents.append(.init(name:"New Agent",icon:"sparkles",modelID:catalog.passedModels.first?.id ?? config.coordinatorModelID,instructions:"Act as a focused specialist. Return concise, accurate supporting work in the user's language."))}
   }
  }.scrollContentBackground(.hidden)}
  .navigationTitle("Agents").onDisappear{OrchestrationStore.save(config)}
 }
}
private struct AgentEditor:View {
 @Binding var agent:AgentConfiguration
 let models:[NVIDIAListModel]
 var body:some View{Form{Toggle("Enabled",isOn:$agent.isEnabled);TextField("Name",text:$agent.name);Picker("Model",selection:$agent.modelID){ForEach(models){Text($0.displayName).tag($0.id)}};Section("Specialist instructions"){TextEditor(text:$agent.instructions).frame(minHeight:180)}}.navigationTitle(agent.name)}
}
