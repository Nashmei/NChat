import SwiftUI
enum GemKind:Int,CaseIterable,Codable{case ruby,sapphire,emerald,sun,grape,pearl
 var color:Color{switch self{case .ruby:.red;case .sapphire:.blue;case .emerald:.green;case .sun:.yellow;case .grape:.purple;case .pearl:.cyan}}
 var symbol:String{switch self{case .ruby:"heart.fill";case .sapphire:"shield.fill";case .emerald:"leaf.fill";case .sun:"crown.fill";case .grape:"sparkles";case .pearl:"drop.fill"}}}
enum Special:String,Codable{case none,rowRocket,columnRocket,bomb,rainbow}
struct Tile:Identifiable,Equatable,Codable{let id:UUID;var kind:GemKind;var special:Special;var blocker:Int
 init(kind:GemKind,special:Special = .none,blocker:Int = 0){id=UUID();self.kind=kind;self.special=special;self.blocker=blocker}}
struct Cell:Hashable{let row:Int;let col:Int}
struct Level:Identifiable,Codable{let id:Int;let moves:Int;let targets:[GemKind:Int];let blockers:Int;let title:String
 static func make(_ n:Int)->Level{let k=GemKind.allCases;return Level(id:n,moves:max(18,29-n/3),targets:[k[(n-1)%k.count]:12+n,k[(n+1)%k.count]:8+n/2],blockers:n<4 ? 0:min(18,2+n/2),title:n%5==0 ? "Royal Challenge":"Garden Quest")}}
struct PlayerSave:Codable{var unlockedLevel=1;var coins=500;var stars=0;var lives=5;var completed:[Int:Int]=[:];var hammer=3;var shuffle=3}
