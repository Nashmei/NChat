import Foundation

struct NVIDIAListModel: Codable, Identifiable, Hashable {
    let id:String
    let owned_by:String?
    var displayName:String { id.split(separator:"/").last.map(String.init) ?? id }
}
private struct ModelsEnvelope:Decodable { let data:[NVIDIAListModel] }

@MainActor final class ModelCatalogStore:ObservableObject {
    static let shared=ModelCatalogStore()
    @Published private(set) var models:[NVIDIAListModel]=[]
    @Published private(set) var verified:Set<String>=[]
    @Published private(set) var unavailable:Set<String>=[]
    @Published var isLoading=false
    @Published var error:String?
    private let cacheKey="nvidia-model-catalog-v1"

    private init() { loadCache() }

    func refresh() async {
        let key=KeychainStore.read(); guard !key.isEmpty else { error="Add your NVIDIA API key first."; return }
        isLoading=true; defer{isLoading=false}
        do {
            var r=URLRequest(url:URL(string:"https://integrate.api.nvidia.com/v1/models")!)
            r.setValue("Bearer \(key)",forHTTPHeaderField:"Authorization")
            let (d,response)=try await URLSession.shared.data(for:r)
            guard let h=response as? HTTPURLResponse,(200..<300).contains(h.statusCode) else { throw URLError(.badServerResponse) }
            models=try JSONDecoder().decode(ModelsEnvelope.self,from:d).data.sorted{$0.id<$1.id}
            UserDefaults.standard.set(try JSONEncoder().encode(models),forKey:cacheKey)
            error=nil
        } catch { self.error=error.localizedDescription }
    }

    func validate(_ model:NVIDIAListModel) async {
        do { try await NVIDIAService().probe(modelID:model.id); verified.insert(model.id); unavailable.remove(model.id) }
        catch { unavailable.insert(model.id); verified.remove(model.id) }
    }

    func validateAll(limit:Int=80) async {
        for model in models.prefix(limit) { await validate(model) }
    }

    private func loadCache() {
        guard let d=UserDefaults.standard.data(forKey:cacheKey),let x=try? JSONDecoder().decode([NVIDIAListModel].self,from:d) else{return}; models=x
    }
}
