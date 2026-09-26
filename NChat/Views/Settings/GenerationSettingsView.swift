import SwiftUI
struct GenerationSettingsView:View {
 @AppStorage("temperature") private var temperature=0.7
 @AppStorage("topP") private var topP=0.95
 @AppStorage("maxTokens") private var maxTokens=4096
 @AppStorage("reasoningEffort") private var reasoning="medium"
 var body:some View {
  Form {
   Section("Sampling"){LabeledContent("Temperature",value:temperature.formatted(.number.precision(.fractionLength(2))));Slider(value:$temperature,in:0...2,step:0.05);LabeledContent("Top P",value:topP.formatted(.number.precision(.fractionLength(2))));Slider(value:$topP,in:0...1,step:0.05)}
   Section("Output"){Stepper("Max tokens: \(maxTokens)",value:$maxTokens,in:128...32768,step:128)}
   Section("Reasoning"){Picker("Effort",selection:$reasoning){Text("Low").tag("low");Text("Medium").tag("medium");Text("High").tag("high")}}
  }.navigationTitle("Generation")
 }
}
