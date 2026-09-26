import SwiftUI
struct GenerationSettingsView:View {
 @AppStorage("temperature") private var temperature=0.4
 @AppStorage("topP") private var topP=0.9
 @AppStorage("maxTokens") private var maxTokens=4096
 @AppStorage("reasoningEffort") private var reasoning="medium"
 var body:some View {
  ZStack{NChatTheme.background.ignoresSafeArea();Form{
   Section("Sampling"){
    LabeledContent("Temperature",value:temperature.formatted(.number.precision(.fractionLength(2))))
    Slider(value:$temperature,in:0.05...0.95,step:0.05)
    LabeledContent("Top P",value:topP.formatted(.number.precision(.fractionLength(2))))
    Slider(value:$topP,in:0.1...1,step:0.05)
    Text("Balanced defaults reduce unstable or mixed-language output across different NVIDIA models.").font(.caption).foregroundStyle(.secondary)
   }
   Section("Output"){Stepper("Max tokens: \(maxTokens)",value:$maxTokens,in:256...32768,step:256)}
   Section("Reasoning"){
    Picker("Effort",selection:$reasoning){Text("Low").tag("low");Text("Medium").tag("medium");Text("High").tag("high")}
    Text("Applied only to verified model families that accept this parameter. Internal reasoning is not shown in chat.").font(.caption).foregroundStyle(.secondary)
   }
   Section{Button("Restore recommended defaults"){temperature=0.4;topP=0.9;maxTokens=4096;reasoning="medium"}}
  }.scrollContentBackground(.hidden)}
  .navigationTitle("Generation")
 }
}
