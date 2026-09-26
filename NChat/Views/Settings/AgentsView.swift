import SwiftUI
struct AgentsView:View {
 @State private var config=OrchestrationStore.load()
 @ObservedObject private var catalog=ModelCatalogStore.shared
 var body:some View {
  Form {
   Section("Orchestrator"){Toggle("Use agents automatically",isOn:$config.enabled);Picker("Responsible model",selection:$config.coordinatorModelID){ForEach(catalog.models){Text($0.displayName).tag($0.id)}};Text("The responsible model delegates when useful, receives the specialist result, then writes the final answer.").font(.caption).foregroundStyle(.secondary)}
   Section("Agents"){ForEach($config.agents){$agent in NavigationLink{AgentEditor(agent:$agent,models:catalog.models)}label:{Label{VStack(alignment:.leading){Text(agent.name);Text(agent.modelID).font(.caption2).foregroundStyle(.secondary)}}icon:{Image(systemName:agent.icon)}}}.onDelete{config.agents.remove(atOffsets:$0)};Button("Add agent"){config.agents.append(.init(name:"New Agent",icon:"sparkles",modelID:config.coordinatorModelID,instructions:"You are a specialist agent."))}}
  }.navigationTitle("Agents").onDisappear{OrchestrationStore.save(config)}.task{if catalog.models.isEmpty{await catalog.refresh()}}
 }
}
private struct AgentEditor:View {
 @Binding var agent:AgentConfiguration;let models:[NVIDIAListModel]
 var body:some View{Form{Toggle("Enabled",isOn:$agent.isEnabled);TextField("Name",text:$agent.name);Picker("Model",selection:$agent.modelID){ForEach(models){Text($0.displayName).tag($0.id)}};Section("Instructions"){TextEditor(text:$agent.instructions).frame(minHeight:180)}}.navigationTitle(agent.name)}
}
