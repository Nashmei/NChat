import SwiftUI

struct AgentsView:View {
 @State private var config=OrchestrationStore.load()
 @ObservedObject private var catalog=ModelCatalogStore.shared

 var body:some View {
  ZStack {
   NChatPageBackground()
   Form {
    Section("Orchestrator") {
     Toggle("Use specialist agents",isOn:$config.enabled)
     Picker("Responsible model",selection:$config.coordinatorModelID) {
      ForEach(catalog.passedModels){Text($0.displayName).tag($0.id)}
     }
     .disabled(catalog.passedModels.isEmpty)
     Text("NChat can route a request to one verified specialist, then the responsible model reviews that work and writes the final answer. Specialist reasoning is never shown directly.")
      .font(.caption).foregroundStyle(.secondary)
    }

    Section("Specialists") {
     ForEach($config.agents) { $agent in
      NavigationLink {
       AgentEditor(agent:$agent,models:catalog.passedModels)
      } label:{
       HStack(spacing:12) {
        ZStack{RoundedRectangle(cornerRadius:10).fill(NChatTheme.elevated);Image(systemName:agent.icon).foregroundStyle(NChatTheme.pink)}.frame(width:36,height:36)
        VStack(alignment:.leading,spacing:3){Text(agent.name);Text(agent.modelID).font(.caption2).foregroundStyle(.secondary).lineLimit(1)}
        Spacer()
        Image(systemName:catalog.capabilities[agent.modelID]?.passed==true ? "checkmark.seal.fill":"exclamationmark.triangle.fill")
         .foregroundStyle(catalog.capabilities[agent.modelID]?.passed==true ? .green:.orange)
       }
      }
     }
     .onDelete{config.agents.remove(atOffsets:$0)}

     Button {
      guard let model=catalog.passedModels.first else{return}
      config.agents.append(.init(name:"New Agent",icon:"sparkles",modelID:model.id,instructions:"Act as a focused specialist. Return concise, accurate supporting work in the user's language."))
     } label:{Label("Add specialist",systemImage:"plus")}
     .disabled(catalog.passedModels.isEmpty)
    }

    Section {
     Text("Only models that passed NChat's chat-quality validation can be selected. If an assigned model later becomes unavailable, that specialist is skipped instead of breaking the main response.")
      .font(.caption).foregroundStyle(.secondary)
    }
   }
   .scrollContentBackground(.hidden)
  }
  .navigationTitle("Agents")
  .onAppear{repairSelections()}
  .onDisappear{OrchestrationStore.save(config)}
 }

 private func repairSelections() {
  guard let fallback=catalog.passedModels.first?.id else{return}
  if catalog.capabilities[config.coordinatorModelID]?.passed != true{config.coordinatorModelID=fallback}
  for index in config.agents.indices where catalog.capabilities[config.agents[index].modelID]?.passed != true {
   config.agents[index].modelID=fallback
  }
 }
}

private struct AgentEditor:View {
 @Binding var agent:AgentConfiguration
 let models:[NVIDIAListModel]

 var body:some View {
  ZStack {
   NChatPageBackground()
   Form {
    Section {
     Toggle("Enabled",isOn:$agent.isEnabled)
     TextField("Name",text:$agent.name)
     Picker("Model",selection:$agent.modelID){ForEach(models){Text($0.displayName).tag($0.id)}}
    }
    Section("Specialist instructions") {
     TextEditor(text:$agent.instructions).frame(minHeight:190)
     Text("Describe the specialist's role and expected output. NChat's global language and safety formatting policy is still applied.")
      .font(.caption).foregroundStyle(.secondary)
    }
   }.scrollContentBackground(.hidden)
  }
  .navigationTitle(agent.name.isEmpty ? "Agent":agent.name)
 }
}
