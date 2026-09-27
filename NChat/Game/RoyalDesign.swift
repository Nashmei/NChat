import SwiftUI

enum RoyalTheme {
    static let navy = Color(red: 0.025, green: 0.18, blue: 0.43)
    static let blue = Color(red: 0.02, green: 0.35, blue: 0.72)
    static let gold = Color(red: 1.0, green: 0.68, blue: 0.08)
    static let cream = Color(red: 1.0, green: 0.91, blue: 0.70)
    static let green = Color(red: 0.20, green: 0.78, blue: 0.10)
}

struct RoyalPanel<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(LinearGradient(colors: [RoyalTheme.cream, .white], startPoint: .top, endPoint: .bottom))
                    .overlay(RoundedRectangle(cornerRadius: 22).stroke(RoyalTheme.gold, lineWidth: 3))
                    .shadow(color: .black.opacity(0.30), radius: 8, y: 5)
            )
    }
}

struct RoyalButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon) }
                Text(title).font(.system(size: 19, weight: .black, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [.green, RoyalTheme.green], startPoint: .top, endPoint: .bottom))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(.yellow.opacity(0.9), lineWidth: 3))
                    .shadow(color: .black.opacity(0.30), radius: 4, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

struct TopCurrencyBar: View {
    @EnvironmentObject var game: CrownStore
    var body: some View {
        HStack(spacing: 8) {
            CurrencyChip(icon: "heart.fill", value: "\(game.save.lives)", tint: .red)
            Spacer()
            CurrencyChip(icon: "circle.fill", value: "\(game.save.coins)", tint: .yellow)
            CurrencyChip(icon: "star.fill", value: "\(game.save.stars)", tint: .yellow)
            Button { game.go(.settings) } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(RoyalTheme.navy, in: Circle())
                    .overlay(Circle().stroke(RoyalTheme.gold, lineWidth: 2))
            }
        }
        .padding(.horizontal, 12)
    }
}

struct CurrencyChip: View {
    let icon: String
    let value: String
    let tint: Color
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(tint)
            Text(value).font(.headline.bold().monospacedDigit()).foregroundStyle(.white)
        }
        .padding(.horizontal, 11).padding(.vertical, 8)
        .background(.black.opacity(0.42), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.18), lineWidth: 1))
    }
}

struct BottomRoyalNav: View {
    @EnvironmentObject var game: CrownStore
    var body: some View {
        HStack(spacing: 2) {
            item("house.fill", "Home", .home)
            item("crown.fill", "Regions", .regions)
            item("gift.fill", "Events", .events)
            item("checklist", "Tasks", .missions)
            item("storefront.fill", "Shop", .shop)
        }
        .padding(7)
        .background(RoyalTheme.navy.opacity(0.97))
        .overlay(alignment: .top) { Rectangle().fill(RoyalTheme.gold).frame(height: 2) }
    }
    private func item(_ icon: String, _ title: String, _ target: CrownStore.Screen) -> some View {
        Button { game.go(target) } label: {
            VStack(spacing: 3) {
                Image(systemName: icon).font(.title3.bold())
                Text(title).font(.caption2.bold())
            }
            .foregroundStyle(game.screen == target ? .yellow : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
        }
        .buttonStyle(.plain)
    }
}

struct RoyalHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 23, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(
                Capsule()
                    .fill(LinearGradient(colors: [RoyalTheme.blue, RoyalTheme.navy], startPoint: .top, endPoint: .bottom))
                    .overlay(Capsule().stroke(RoyalTheme.gold, lineWidth: 3))
            )
    }
}


struct RoyalKing: View {
    var celebrating = false
    var body: some View {
        ZStack {
            Ellipse().fill(.black.opacity(0.18)).frame(width:150,height:28).offset(y:116)
            RoundedRectangle(cornerRadius:38)
                .fill(LinearGradient(colors:[Color(red:0.78,green:0.08,blue:0.10),Color(red:0.42,green:0.02,blue:0.08)],startPoint:.top,endPoint:.bottom))
                .frame(width:128,height:118).offset(y:72)
                .overlay(RoundedRectangle(cornerRadius:38).stroke(RoyalTheme.gold,lineWidth:7).frame(width:128,height:118).offset(y:72))
            Circle().fill(Color(red:0.98,green:0.76,blue:0.58)).frame(width:112,height:112).offset(y:-8)
                .overlay(Circle().stroke(Color.white.opacity(0.55),lineWidth:3).frame(width:104,height:104).offset(y:-11))
            HStack(spacing:34) {
                Circle().fill(Color(red:0.12,green:0.20,blue:0.30)).frame(width:12,height:16)
                Circle().fill(Color(red:0.12,green:0.20,blue:0.30)).frame(width:12,height:16)
            }.offset(y:-20)
            Capsule().fill(Color(red:0.74,green:0.38,blue:0.25)).frame(width:17,height:24).offset(y:-3)
            HStack(spacing:-4) {
                Capsule().fill(.white).frame(width:49,height:28).rotationEffect(.degrees(13))
                Capsule().fill(.white).frame(width:49,height:28).rotationEffect(.degrees(-13))
            }.offset(y:14)
            Path { p in
                p.move(to:CGPoint(x:38,y:102));p.addQuadCurve(to:CGPoint(x:112,y:102),control:CGPoint(x:75,y:130))
            }.stroke(Color.white,lineWidth:20).offset(x:-75,y:-55)
            ZStack {
                CrownShape().fill(LinearGradient(colors:[.yellow,RoyalTheme.gold,.orange],startPoint:.top,endPoint:.bottom))
                HStack(spacing:13) {
                    Circle().fill(.red).frame(width:8,height:8)
                    Circle().fill(.blue).frame(width:9,height:9)
                    Circle().fill(.green).frame(width:8,height:8)
                }.offset(y:15)
            }.frame(width:104,height:70).offset(y:-78)
            HStack(spacing:88) {
                Circle().fill(Color(red:0.98,green:0.76,blue:0.58)).frame(width:28,height:28)
                Circle().fill(Color(red:0.98,green:0.76,blue:0.58)).frame(width:28,height:28)
            }.offset(y:65)
            .rotationEffect(.degrees(celebrating ? -10 : 0))
        }
        .frame(width:190,height:245)
        .shadow(color:.black.opacity(0.28),radius:9,y:7)
    }
}

struct CrownShape: Shape {
    func path(in rect:CGRect)->Path {
        Path { p in
            p.move(to:CGPoint(x:rect.minX,y:rect.maxY*0.82))
            p.addLine(to:CGPoint(x:rect.minX+rect.width*0.08,y:rect.height*0.28))
            p.addLine(to:CGPoint(x:rect.width*0.32,y:rect.height*0.52))
            p.addLine(to:CGPoint(x:rect.midX,y:rect.minY))
            p.addLine(to:CGPoint(x:rect.width*0.68,y:rect.height*0.52))
            p.addLine(to:CGPoint(x:rect.width*0.92,y:rect.height*0.28))
            p.addLine(to:CGPoint(x:rect.maxX,y:rect.maxY*0.82))
            p.closeSubpath()
        }
    }
}

struct CrownLogo: View {
    var body: some View {
        VStack(spacing:-4) {
            Image(systemName:"crown.fill")
                .font(.system(size:46,weight:.black)).foregroundStyle(.yellow)
                .shadow(color:.orange.opacity(0.8),radius:6,y:3)
            Text("CROWN")
                .font(.system(size:38,weight:.black,design:.rounded))
                .foregroundStyle(LinearGradient(colors:[.yellow,.orange],startPoint:.top,endPoint:.bottom))
                .shadow(color:RoyalTheme.navy,radius:0,x:0,y:4)
            Text("GARDENS")
                .font(.system(size:24,weight:.black,design:.rounded))
                .tracking(3).foregroundStyle(.white)
                .padding(.horizontal,12).padding(.vertical,4)
                .background(RoyalTheme.navy,in:Capsule())
                .overlay(Capsule().stroke(RoyalTheme.gold,lineWidth:2))
        }
    }
}
