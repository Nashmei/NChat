import SwiftUI
import AudioToolbox
import UIKit
@MainActor final class CrownStore:ObservableObject{
 enum PlayState{case map,playing,won,lost}
 @Published var save=PlayerSave();@Published var board=MatchEngine.freshBoard();@Published var level=Level.make(1);@Published var movesLeft=0;@Published var remaining:[GemKind:Int]=[:];@Published var selected:Cell?;@Published var score=0;@Published var combo=0;@Published var state:PlayState = .map;@Published var message="";@Published var showDaily=false;@Published var sound=true;@Published var haptics=true;@Published var resolving=false;@Published var celebration=0
 private let key="crown.gardens.save.v1"
 init(){load();claimDaily()}
 func start(_ n:Int){level=Level.make(n);board=MatchEngine.freshBoard();movesLeft=level.moves;remaining=level.targets;score=0;combo=0;selected=nil;message="";state = .playing;addBlockers(level.blockers)}
 private func addBlockers(_ n:Int){guard n>0 else{return};var a=(0..<MatchEngine.size).flatMap{r in(0..<MatchEngine.size).map{Cell(row:r,col:$0)}}.shuffled();for _ in 0..<min(n,a.count){let p=a.removeLast();board[p.row][p.col].blocker=1}}
 func tap(_ p:Cell){guard state == .playing else{return};if let a=selected{selected=nil;if MatchEngine.adjacent(a,p){swap(a,p)}else{selected=p;feedback(1519)}}else{selected=p;feedback(1519)}}
 func swipe(from p:Cell,dx:CGFloat,dy:CGFloat){guard state == .playing else{return};var q=p;if abs(dx)>abs(dy){q=Cell(row:p.row,col:p.col+(dx>0 ? 1:-1))}else{q=Cell(row:p.row+(dy>0 ? 1:-1),col:p.col)};guard (0..<8).contains(q.row),(0..<8).contains(q.col) else{return};swap(p,q)}
 private func swap(_ a:Cell,_ z:Cell){guard !resolving else{return};resolving=true;defer{resolving=false};var b=board;b[a.row][a.col]=board[z.row][z.col];b[z.row][z.col]=board[a.row][a.col];var m=MatchEngine.matches(b);if m.cells.isEmpty && b[a.row][a.col].special == .none && b[z.row][z.col].special == .none{message="Make a match";feedback(1521);return};board=b;movesLeft-=1;combo=0;if m.cells.isEmpty{m.cells=[a,z]};resolve(m)}
 private func resolve(_ first:MatchResult){var m=first;repeat{combo+=1;let clear=MatchEngine.expanded(m.cells,board:board);for p in clear{let t=board[p.row][p.col];if t.blocker>0{board[p.row][p.col].blocker=max(0,t.blocker-1);continue};if let v=remaining[t.kind],v>0{remaining[t.kind]=max(0,v-1)}};score+=clear.count*60*combo;if combo>1{message=combo>=4 ? "ROYAL CASCADE!":"COMBO ×\(combo)";celebration+=1};MatchEngine.collapse(&board,clearing:clear,specials:m.specials);m=MatchEngine.matches(board)}while !m.cells.isEmpty;if !MatchEngine.hasMove(board){board=MatchEngine.freshBoard();message="Fresh board!"};feedback(1520);evaluate()}
 private func evaluate(){if remaining.values.allSatisfy({$0==0}){let s=movesLeft>level.moves/2 ? 3:(movesLeft>3 ? 2:1);let old=save.completed[level.id] ?? 0;if s>old{save.stars+=s-old};save.completed[level.id]=max(old,s);save.coins+=50+s*25;save.unlockedLevel=max(save.unlockedLevel,min(30,level.id+1));state = .won;persist();feedback(1025)}else if movesLeft<=0{save.lives=max(0,save.lives-1);state = .lost;persist();feedback(1053)}}
 func hammer(_ p:Cell){guard state == .playing,save.hammer>0 else{return};save.hammer-=1;let t=board[p.row][p.col];if let v=remaining[t.kind],v>0{remaining[t.kind]=v-1};board[p.row][p.col]=Tile(kind:GemKind.allCases.randomElement() ?? .ruby);score+=100;persist();evaluate()}
 func shuffle(){guard state == .playing,save.shuffle>0 else{return};save.shuffle-=1;board=MatchEngine.freshBoard();addBlockers(level.blockers);persist();feedback(1520)}
 func next(){start(min(30,level.id+1))};func map(){state = .map}
 func buyLives(){guard save.coins>=250,save.lives<5 else{return};save.coins-=250;save.lives=5;persist()}
 private func claimDaily(){let d=Calendar.current.startOfDay(for:Date()).timeIntervalSince1970;if UserDefaults.standard.double(forKey:"crown.daily")<d{save.coins+=100;UserDefaults.standard.set(d,forKey:"crown.daily");showDaily=true;persist()}}
 private func feedback(_ id:SystemSoundID){if sound{AudioServicesPlaySystemSound(id)};if haptics{UIImpactFeedbackGenerator(style:.soft).impactOccurred()}}
 private func persist(){if let d=try? JSONEncoder().encode(save){UserDefaults.standard.set(d,forKey:key)}}
 private func load(){if let d=UserDefaults.standard.data(forKey:key),let s=try? JSONDecoder().decode(PlayerSave.self,from:d){save=s}}
}
