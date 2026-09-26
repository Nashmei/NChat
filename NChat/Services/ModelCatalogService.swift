import Foundation

struct NVIDIAListModel:Codable,Identifiable,Hashable {
 let id:String
 let owned_by:String?
 var displayName:String{id.split(separator:"/").last.map(String.init) ?? id}
}
private struct ModelsEnvelope:Decodable{let data:[NVIDIAListModel]}

@MainActor final class ModelCatalogStore:ObservableObject {
 static let shared=ModelCatalogStore()
 @Published private(set)var models:[NVIDIAListModel]=[]
 @Published private(set)var capabilities:[String:ModelCapability]=[:]
 @Published var isLoading=false
 @Published var testedCount=0
 @Published var totalToTest=0
 @Published var error:String?
 @Published private(set)var lastValidatedAt:Date?
 private var validationTask:Task<Void,Never>?
 private let catalogKey="nvidia-passed-models-v2"
 private let capabilityKey="nvidia-model-capabilities-v4"
 var passedModels:[NVIDIAListModel]{models.filter{capabilities[$0.id]?.passed==true}}
 var progress:Double{totalToTest==0 ? 0:Double(testedCount)/Double(totalToTest)}
 private init(){loadCache()}

 func refreshAndValidate(force:Bool=false)async {
  if isLoading{return}
  if !force,let lastValidatedAt,Date().timeIntervalSince(lastValidatedAt)<60{return}
  let key=KeychainStore.read()
  guard !key.isEmpty else{models=[];capabilities=[:];error="Add your NVIDIA API key first.";return}
  isLoading=true;testedCount=0;error=nil
  defer{isLoading=false}
  do{
   var req=URLRequest(url:URL(string:AppSettings.modelsEndpoint)!)
   req.setValue("Bearer \(key)",forHTTPHeaderField:"Authorization")
   let(data,response)=try await URLSession.shared.data(for:req)
   guard let h=response as? HTTPURLResponse,(200..<300).contains(h.statusCode)else{throw URLError(.userAuthenticationRequired)}
   let all=try JSONDecoder().decode(ModelsEnvelope.self,from:data).data.filter{ModelEligibility.isChatCandidate($0.id)}.sorted{$0.id<$1.id}
   totalToTest=all.count
   var passed:[NVIDIAListModel]=[]
   var caps:[String:ModelCapability]=[:]
   await withTaskGroup(of:(NVIDIAListModel,ModelCapability).self){group in
    var iterator=all.makeIterator()
    for _ in 0..<min(4,all.count){if let model=iterator.next(){group.addTask{await Self.test(model)}}}
    while let(model,cap)=await group.next(){
     testedCount+=1;caps[model.id]=cap;if cap.passed{passed.append(model)}
     if let next=iterator.next(){group.addTask{await Self.test(next)}}
    }
   }
   models=passed.sorted{$0.id<$1.id};capabilities=caps
   let saved=UserDefaults.standard.string(forKey:"lastWorkingModel")
   if let saved,!models.contains(where:{$0.id==saved}){UserDefaults.standard.removeObject(forKey:"lastWorkingModel")}
   if UserDefaults.standard.string(forKey:"lastWorkingModel")==nil,let preferred=models.first(where:{$0.id==AppSettings.defaultModel}) ?? models.first{UserDefaults.standard.set(preferred.id,forKey:"lastWorkingModel")}
   lastValidatedAt = .now;persist();error=models.isEmpty ? "No chat models passed validation.":nil
  }catch{self.error=error.localizedDescription}
 }

 func refresh()async{await refreshAndValidate(force:true)}
 func validate(_ model:NVIDIAListModel)async{let(_,cap)=await Self.test(model);capabilities[model.id]=cap;if cap.passed,!models.contains(model){models.append(model);models.sort{$0.id<$1.id}};persist()}
 func validateAll(limit:Int=999)async{await refreshAndValidate(force:true)}

 nonisolated private static func test(_ model:NVIDIAListModel)async->(NVIDIAListModel,ModelCapability){
  let start=Date()
  do{
   let result=try await NVIDIAService().qualityProbe(modelID:model.id)
   let latency=Int(Date().timeIntervalSince(start)*1000)
   let normalized=result.trimmingCharacters(in:.whitespacesAndNewlines)
   let arabicOK=normalized.contains("مرحبا")
   let latinOK=normalized.uppercased().contains("NCHAT")
   let corrupted=normalized.contains("�")
   let passed=arabicOK && latinOK && !corrupted
   return(model,.init(id:model.id,displayName:model.displayName,passed:passed,supportsArabic:arabicOK,supportsStreaming:true,supportsVision:ModelEligibility.inferredVision(model.id),supportsReasoning:ModelEligibility.inferredReasoning(model.id),supportsTools:ModelEligibility.inferredTools(model.id),visionConfidence:.inferred,reasoningConfidence:.inferred,toolsConfidence:.inferred,testedAt:.now,latencyMS:latency,failureReason:passed ? nil:"Quality probe returned invalid multilingual text"))
  }catch{
   return(model,.init(id:model.id,displayName:model.displayName,passed:false,supportsArabic:false,supportsStreaming:false,supportsVision:false,supportsReasoning:false,supportsTools:false,visionConfidence:.unknown,reasoningConfidence:.unknown,toolsConfidence:.unknown,testedAt:.now,latencyMS:Int(Date().timeIntervalSince(start)*1000),failureReason:error.localizedDescription))
  }
 }

 private func persist(){if let d=try? JSONEncoder().encode(models){UserDefaults.standard.set(d,forKey:catalogKey)};if let d=try? JSONEncoder().encode(capabilities){UserDefaults.standard.set(d,forKey:capabilityKey)}}
 private func loadCache(){if let d=UserDefaults.standard.data(forKey:catalogKey),let x=try? JSONDecoder().decode([NVIDIAListModel].self,from:d){models=x};if let d=UserDefaults.standard.data(forKey:capabilityKey),let x=try? JSONDecoder().decode([String:ModelCapability].self,from:d){capabilities=x}}
}
