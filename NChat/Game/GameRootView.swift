import SwiftUI

struct GameRootView: View {
    @StateObject private var game = CrownStore()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.18, blue: 0.34),
                    Color(red: 0.10, green: 0.43, blue: 0.49)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            switch game.state {
            case .levelIntro:
                LevelIntroView().environmentObject(game)
            case .playing, .won, .lost:
                PlayView().environmentObject(game)
            case .map:
                switch game.screen {
                case .home:
                    RoyalHomeView().environmentObject(game)
                case .map:
                    MapView().environmentObject(game)
                case .missions:
                    MissionsView().environmentObject(game)
                case .events:
                    EventsView().environmentObject(game)
                case .shop:
                    ShopView().environmentObject(game)
                case .regions:
                    RegionsView().environmentObject(game)
                case .settings:
                    SettingsScreen().environmentObject(game)
                case .renovation:
                    RenovationView().environmentObject(game)
                }
            }
        }
        .preferredColorScheme(.dark)
        .alert("Daily Treasure!", isPresented: $game.showDaily) {
            Button("Collect") {}
        } message: {
            Text("100 coins were added to your treasury.")
        }
    }
}

struct LevelIntroView: View {
    @EnvironmentObject var game: CrownStore

    var body: some View {
        ZStack {
            RoyalWorldBackground()
            Color.black.opacity(0.20).ignoresSafeArea()
            VStack {
                HStack {
                    Button { game.map() } label: {
                        Image(systemName: "xmark").font(.title2.bold()).foregroundStyle(.white)
                            .frame(width: 46, height: 46).background(RoyalTheme.navy, in: Circle())
                            .overlay(Circle().stroke(RoyalTheme.gold, lineWidth: 3))
                    }
                    Spacer()
                    CurrencyChip(icon: "heart.fill", value: "\(game.save.lives)", tint: .red)
                }.padding()

                Spacer()

                RoyalPanel {
                    VStack(spacing: 16) {
                        RoyalHeader(title: "المستوى \(game.level.id)")
                        HStack {
                            VStack {
                                Text("الهدف").font(.caption.bold()).foregroundStyle(.gray)
                                HStack(spacing: 12) {
                                    ForEach(Array(game.level.targets.keys), id: \.self) { kind in
                                        VStack {
                                            ZStack {
                                                Circle().fill(kind.color.gradient).frame(width: 48, height: 48)
                                                Image(systemName: kind.symbol).foregroundStyle(.white).font(.title3.bold())
                                            }
                                            Text("\(game.level.targets[kind] ?? 0)").font(.headline.bold()).foregroundStyle(RoyalTheme.navy)
                                        }
                                    }
                                }
                                if game.level.blockers > 0 {
                                    VStack {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10).fill(.brown.gradient).frame(width: 48, height: 48)
                                            Image(systemName: "shippingbox.fill").foregroundStyle(.white).font(.title3.bold())
                                        }
                                        Text("\(game.level.blockers)").font(.headline.bold()).foregroundStyle(RoyalTheme.navy)
                                    }
                                }
                            }
                            Spacer()
                            VStack {
                                Text("الحركات").font(.caption.bold()).foregroundStyle(.gray)
                                Text("\(game.level.moves)").font(.system(size: 34, weight: .black, design: .rounded)).foregroundStyle(RoyalTheme.navy)
                            }
                        }

                        Divider()
                        Text("اختر المعززات").font(.headline.bold()).foregroundStyle(RoyalTheme.navy)
                        HStack(spacing: 12) {
                            booster(icon: "burst.fill", title: "قنبلة", count: game.save.bombs, selected: $game.preBomb, tint: .purple)
                            booster(icon: "arrow.left.and.right.circle.fill", title: "صاروخ", count: game.save.rockets, selected: $game.preRocket, tint: .red)
                            booster(icon: "sparkles", title: "كرة الألوان", count: game.save.rainbows, selected: $game.preRainbow, tint: .blue)
                        }
                        RoyalButton(title: "ابدأ", icon: "play.fill") { game.beginSelectedLevel() }
                    }
                }
                .padding(20)
                Spacer()
            }
        }
    }

    private func booster(icon: String, title: String, count: Int, selected: Binding<Bool>, tint: Color) -> some View {
        Button { if count > 0 { selected.wrappedValue.toggle() } } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle().fill(tint.gradient).frame(width: 58, height: 58)
                    Image(systemName: icon).font(.title2.bold()).foregroundStyle(.white)
                    if selected.wrappedValue {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green).background(.white, in: Circle())
                            .offset(x: 23, y: -23)
                    }
                }
                Text(title).font(.caption2.bold()).foregroundStyle(RoyalTheme.navy)
                Text("×\(count)").font(.caption2.bold()).foregroundStyle(count > 0 ? .green : .red)
            }
            .frame(maxWidth: .infinity)
        }.buttonStyle(.plain).opacity(count > 0 ? 1 : 0.45).disabled(count == 0)
    }
}

struct MapView: View {
    @EnvironmentObject var game: CrownStore

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoyalWorldBackground()
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators:false) {
                        VStack(spacing:0) {
                            mapHeader
                            ForEach((0..<5).reversed(),id:\.self) { region in
                                regionSection(region,width:geo.size.width)
                            }
                            Color.clear.frame(height:90)
                        }
                    }
                    .onAppear {
                        withAnimation(.easeOut(duration:0.5)) {
                            proxy.scrollTo(game.save.unlockedLevel,anchor:.center)
                        }
                    }
                }
            }
        }
    }

    private var mapHeader: some View {
        VStack(spacing:8) {
            TopCurrencyBar().environmentObject(game)
            CrownLogo().scaleEffect(0.78)
            Text("رحلة استعادة المملكة")
                .font(.headline.bold()).foregroundStyle(.white)
                .shadow(color:.black.opacity(0.55),radius:3,y:2)
        }
        .padding(.top,8).padding(.bottom,14)
    }

    private func regionSection(_ region:Int,width:CGFloat)->some View {
        let start=region*6+1
        let end=min(30,start+5)
        let names=["حدائق القصر","وادي النوافير","غابة الزمرد","مرتفعات التاج","القصر الذهبي"]
        return VStack(spacing:6) {
            HStack(spacing:8) {
                Image(systemName:["leaf.fill","drop.fill","tree.fill","mountain.2.fill","crown.fill"][region])
                Text(names[region]).font(.headline.black())
            }
            .foregroundStyle(.white)
            .padding(.horizontal,18).padding(.vertical,8)
            .background(RoyalTheme.navy.opacity(0.88),in:Capsule())
            .overlay(Capsule().stroke(RoyalTheme.gold,lineWidth:2))

            ZStack {
                RoyalPath()
                    .stroke(
                        LinearGradient(colors:[.yellow,.orange],startPoint:.bottom,endPoint:.top),
                        style:StrokeStyle(lineWidth:10,lineCap:.round,dash:[3,17])
                    )
                    .frame(width:min(width*0.72,320),height:500)

                VStack(spacing:5) {
                    ForEach(start...end,id:\.self) { number in
                        levelNode(number,width:width)
                            .id(number)
                    }
                }
                .padding(.vertical,12)
            }
            .frame(height:520)
            .background(
                RoundedRectangle(cornerRadius:38)
                    .fill(.white.opacity(0.07))
                    .overlay(RoundedRectangle(cornerRadius:38).stroke(.white.opacity(0.16),lineWidth:1))
            )
            .padding(.horizontal,10)
        }
        .padding(.bottom,18)
    }

    private func levelNode(_ number:Int,width:CGFloat)->some View {
        let open=number<=game.save.unlockedLevel
        let stars=game.save.completed[number] ?? 0
        let current=number==game.save.unlockedLevel
        let offset=sin(Double(number)*1.55)*Double(min(width*0.24,92))
        return Button {
            if open && game.save.lives>0 { game.selectLevel(number) }
        } label: {
            ZStack {
                if current {
                    RoyalKing().scaleEffect(0.25).offset(x:-68,y:-10)
                }
                VStack(spacing:2) {
                    ZStack {
                        Circle()
                            .fill(open
                                  ? LinearGradient(colors:[.yellow,.orange],startPoint:.top,endPoint:.bottom)
                                  : LinearGradient(colors:[.gray,Color.black.opacity(0.72)],startPoint:.top,endPoint:.bottom))
                            .frame(width:76,height:76)
                            .overlay(Circle().stroke(.white,lineWidth:4))
                            .overlay(Circle().stroke(RoyalTheme.navy.opacity(0.6),lineWidth:2).padding(5))
                            .shadow(color:open ? .yellow.opacity(0.48):.black.opacity(0.35),radius:9,y:5)
                        if open {
                            Text("\(number)")
                                .font(.system(size:25,weight:.black,design:.rounded))
                                .foregroundStyle(.white)
                                .shadow(color:.black.opacity(0.4),radius:2,y:2)
                        } else {
                            Image(systemName:"lock.fill").font(.title2).foregroundStyle(.white.opacity(0.75))
                        }
                    }
                    HStack(spacing:1) {
                        ForEach(0..<3,id:\.self) { i in
                            Image(systemName:i<stars ? "star.fill":"star")
                                .font(.caption.bold())
                                .foregroundStyle(i<stars ? .yellow:.white.opacity(0.55))
                        }
                    }
                }
                if current {
                    Text("التالي")
                        .font(.caption2.black()).foregroundStyle(.white)
                        .padding(.horizontal,8).padding(.vertical,4)
                        .background(.green,in:Capsule())
                        .offset(y:-47)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!open)
        .offset(x:offset)
        .frame(maxWidth:.infinity)
    }
}

struct RoyalWorldBackground: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red:0.18,green:0.67,blue:0.98),
                        Color(red:0.50,green:0.84,blue:0.98),
                        Color(red:0.39,green:0.78,blue:0.45)
                    ],
                    startPoint:.top,endPoint:.bottom
                )

                ForEach(0..<7,id:\.self) { i in
                    Capsule()
                        .fill(.white.opacity(0.68))
                        .frame(width: CGFloat(90 + i*13), height: CGFloat(25 + (i%3)*9))
                        .blur(radius: 2)
                        .position(x: CGFloat((i*83)%420)-10, y: CGFloat(65+i*42))
                }

                Path { p in
                    p.move(to:CGPoint(x:0,y:h*0.46))
                    p.addCurve(to:CGPoint(x:w,y:h*0.42),
                               control1:CGPoint(x:w*0.25,y:h*0.32),
                               control2:CGPoint(x:w*0.70,y:h*0.54))
                    p.addLine(to:CGPoint(x:w,y:h))
                    p.addLine(to:CGPoint(x:0,y:h))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors:[Color.green.opacity(0.70),Color(red:0.08,green:0.42,blue:0.18)],startPoint:.top,endPoint:.bottom))

                castle(width:w)
                    .frame(width:min(w*0.92,520),height:min(h*0.34,300))
                    .position(x:w*0.50,y:h*0.31)
                    .shadow(color:.black.opacity(0.22),radius:10,y:8)

                Path { p in
                    p.move(to:CGPoint(x:w*0.46,y:h*0.43))
                    p.addCurve(to:CGPoint(x:w*0.58,y:h),
                               control1:CGPoint(x:w*0.30,y:h*0.66),
                               control2:CGPoint(x*w*0.72,y:h*0.74))
                    p.addLine(to:CGPoint(x:w*0.82,y:h))
                    p.addCurve(to:CGPoint(x:w*0.54,y:h*0.43),
                               control1:CGPoint(x:w*0.72,y:h*0.76),
                               control2:CGPoint(x*w*0.42,y:h*0.66))
                    p.closeSubpath()
                }
                .fill(LinearGradient(colors:[Color(red:0.20,green:0.72,blue:0.94),Color(red:0.02,green:0.36,blue:0.72)],startPoint:.top,endPoint:.bottom))
                .overlay(
                    Path { p in
                        p.move(to:CGPoint(x:w*0.50,y:h*0.45))
                        p.addCurve(to:CGPoint(x:w*0.66,y:h),control1:CGPoint(x:w*0.38,y:h*0.68),control2:CGPoint(x:w*0.68,y:h*0.78))
                    }.stroke(.white.opacity(0.58),lineWidth:4)
                )

                VStack {
                    Spacer()
                    HStack(alignment:.bottom,spacing:-12) {
                        ForEach(0..<9,id:\.self) { i in
                            gardenTree(index:i)
                                .frame(width:CGFloat(70+(i%3)*15),height:CGFloat(115+(i%4)*12))
                        }
                    }
                    .offset(y:20)
                }

                ForEach(0..<18,id:\.self) { i in
                    Circle()
                        .fill([Color.pink,.yellow,.white,.purple][i%4])
                        .frame(width:CGFloat(5+i%4),height:CGFloat(5+i%4))
                        .position(x:CGFloat((i*71)%390)+10,y:h*CGFloat(0.58+Double((i*17)%36)/100.0))
                        .shadow(color:.white.opacity(0.5),radius:2)
                }

                LinearGradient(colors:[.clear,.black.opacity(0.12)],startPoint:.center,endPoint:.bottom)
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder private func castle(width:CGFloat) -> some View {
        GeometryReader { g in
            let cw=g.size.width, ch=g.size.height
            ZStack(alignment:.bottom) {
                RoundedRectangle(cornerRadius:24)
                    .fill(LinearGradient(colors:[Color(red:1.0,green:0.91,blue:0.72),Color(red:0.86,green:0.66,blue:0.40)],startPoint:.top,endPoint:.bottom))
                    .frame(width:cw*0.54,height:ch*0.56)
                    .overlay(RoundedRectangle(cornerRadius:24).stroke(.white.opacity(0.65),lineWidth:3))
                ForEach([-1,1],id:\.self) { side in
                    VStack(spacing:-5) {
                        ZStack {
                            Triangle().fill(LinearGradient(colors:[RoyalTheme.blue,RoyalTheme.navy],startPoint:.top,endPoint:.bottom))
                            Circle().fill(RoyalTheme.gold).frame(width:8,height:8).offset(y:-18)
                        }.frame(width:cw*0.18,height:ch*0.25)
                        RoundedRectangle(cornerRadius:18)
                            .fill(LinearGradient(colors:[RoyalTheme.cream,Color(red:0.82,green:0.61,blue:0.38)],startPoint:.top,endPoint:.bottom))
                            .frame(width:cw*0.18,height:ch*0.54)
                            .overlay(VStack(spacing:12){
                                ForEach(0..<3,id:\.self){_ in Capsule().fill(Color.blue.opacity(0.72)).frame(width:18,height:30)}
                            })
                    }
                    .offset(x:CGFloat(side)*cw*0.32,y:0)
                }
                VStack(spacing:-6) {
                    ZStack {
                        Triangle().fill(LinearGradient(colors:[Color.indigo,RoyalTheme.navy],startPoint:.top,endPoint:.bottom))
                        Image(systemName:"crown.fill").foregroundStyle(.yellow).font(.title3).offset(y:8)
                    }.frame(width:cw*0.25,height:ch*0.30)
                    RoundedRectangle(cornerRadius:20)
                        .fill(LinearGradient(colors:[.white,RoyalTheme.cream],startPoint:.top,endPoint:.bottom))
                        .frame(width:cw*0.25,height:ch*0.72)
                        .overlay(VStack(spacing:10){
                            Capsule().fill(Color.blue.opacity(0.78)).frame(width:26,height:40)
                            RoundedRectangle(cornerRadius:12).fill(Color(red:0.35,green:0.16,blue:0.08)).frame(width:42,height:58)
                        })
                }
                .offset(y:-ch*0.02)
            }
        }
    }

    private func gardenTree(index:Int) -> some View {
        VStack(spacing:-12) {
            ZStack {
                Circle().fill(index.isMultiple(of:2) ? Color(red:0.16,green:0.62,blue:0.22) : Color(red:0.08,green:0.48,blue:0.18))
                Circle().fill(Color.green.opacity(0.55)).scaleEffect(0.66).offset(x:-13,y:-12)
                Circle().fill(Color.mint.opacity(0.35)).scaleEffect(0.38).offset(x:14,y:-18)
            }
            Rectangle().fill(Color(red:0.42,green:0.23,blue:0.10)).frame(width:10,height:42)
        }
    }
}

struct RoyalPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        let steps = 12
        for i in 1...steps {
            let progress = CGFloat(i) / CGFloat(steps)
            let y = rect.maxY - progress * rect.height
            let x = rect.midX + sin(progress * .pi * 5) * rect.width * 0.32
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let color: Color

    var body: some View {
        Label(value, systemImage: icon)
            .font(.headline.monospacedDigit())
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(.black.opacity(0.28), in: Capsule())
    }
}

struct PlayView: View {
    @EnvironmentObject var game: CrownStore

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.18, green: 0.52, blue: 0.82), Color(red: 0.04, green: 0.18, blue: 0.42)],
                    startPoint: .top,
                    endPoint: .bottom
                ).ignoresSafeArea()

                VStack(spacing: 8) {
                    HStack {
                        Button { game.map() } label: {
                            Image(systemName: "chevron.backward")
                                .font(.title3.bold()).foregroundStyle(.white)
                                .frame(width: 42, height: 42).background(RoyalTheme.navy, in: Circle())
                                .overlay(Circle().stroke(RoyalTheme.gold, lineWidth: 2))
                        }
                        CurrencyChip(icon: "heart.fill", value: "\(game.save.lives)", tint: .red)
                        Spacer()
                        CurrencyChip(icon: "circle.fill", value: "\(game.save.coins)", tint: .yellow)
                        Button { game.go(.settings) } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title3.bold()).foregroundStyle(.white)
                                .frame(width: 42, height: 42).background(RoyalTheme.navy, in: Circle())
                                .overlay(Circle().stroke(RoyalTheme.gold, lineWidth: 2))
                        }
                    }
                    .padding(.horizontal, 10)

                    HStack(spacing: 10) {
                        RoyalPanel {
                            HStack(spacing: 14) {
                                ForEach(Array(game.remaining.keys), id: \.self) { kind in
                                    HStack(spacing: 5) {
                                        ZStack {
                                            Circle().fill(kind.color.gradient).frame(width: 34, height: 34)
                                            Image(systemName: kind.symbol).font(.caption.bold()).foregroundStyle(.white)
                                        }
                                        Text("\(game.remaining[kind] ?? 0)")
                                            .font(.headline.bold().monospacedDigit()).foregroundStyle(RoyalTheme.navy)
                                    }
                                }
                                if game.level.blockers > 0 {
                                    HStack(spacing: 5) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8).fill(.brown.gradient).frame(width: 34, height: 34)
                                            Image(systemName: "shippingbox.fill").font(.caption.bold()).foregroundStyle(.white)
                                        }
                                        Text("\(game.blockersLeft)")
                                            .font(.headline.bold().monospacedDigit()).foregroundStyle(RoyalTheme.navy)
                                    }
                                }
                            }
                        }
                        VStack(spacing: 1) {
                            Text("الحركات").font(.caption2.bold()).foregroundStyle(.white.opacity(0.85))
                            Text("\(game.movesLeft)")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 72, height: 62)
                        .background(RoyalTheme.navy, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(RoyalTheme.gold, lineWidth: 3))
                    }
                    .padding(.horizontal, 10)

                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(colors: [RoyalTheme.gold, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: .black.opacity(0.45), radius: 10, y: 6)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(red: 0.02, green: 0.22, blue: 0.45))
                            .padding(5)
                        BoardView().environmentObject(game).padding(9)
                    }
                    .frame(width: min(geometry.size.width - 12, 500), height: min(geometry.size.width - 12, 500))

                    HStack(spacing: 14) {
                        actionBooster("hammer.fill", "\(game.save.hammer)", .purple) {
                            game.message = "اضغط مطولاً على قطعة لاستخدام المطرقة"
                        }
                        actionBooster("shuffle", "\(game.save.shuffle)", .red) { game.shuffle() }
                        actionBooster("burst.fill", "×", .orange) { game.message = "اصنع 5 قطع للحصول على معزز قوي" }
                        actionBooster("sparkles", "×", .blue) { game.message = "ادمج المعززات لتأثير أكبر" }
                    }

                    Text(game.message)
                        .font(.subheadline.bold())
                        .foregroundStyle(.yellow)
                        .frame(height: 22)

                    HStack {
                        Label("\(game.score)", systemImage: "star.circle.fill")
                        Spacer()
                        if game.combo > 1 { Text("COMBO ×\(game.combo)").foregroundStyle(.yellow) }
                    }
                    .font(.caption.bold()).foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    Spacer(minLength: 4)
                }
                .padding(.top, 4)
            }
        }
        .overlay {
            if game.state == .won {
                ResultCard(win: true).environmentObject(game)
            } else if game.state == .lost {
                ResultCard(win: false).environmentObject(game)
            }
        }
    }

    private func actionBooster(_ icon: String, _ value: String, _ tint: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(tint.gradient)
                    .frame(width: 58, height: 58)
                    .overlay(Circle().stroke(.yellow.opacity(0.9), lineWidth: 3))
                    .shadow(color: .black.opacity(0.35), radius: 4, y: 3)
                    .overlay(Image(systemName: icon).font(.title2.bold()).foregroundStyle(.white))
                Text(value)
                    .font(.caption2.weight(.black)).foregroundStyle(.white)
                    .padding(5).background(.red, in: Circle())
                    .offset(x: 3, y: 3)
            }
        }.buttonStyle(.plain)
    }
}

struct BoardView: View {
    @EnvironmentObject var game: CrownStore
    @State private var pulse = false

    var body: some View {
        GeometryReader { geometry in
            let cellSize = geometry.size.width / CGFloat(MatchEngine.size)
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.black.opacity(0.24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                game.combo > 1 ? Color.yellow.opacity(0.85) : Color.white.opacity(0.10),
                                lineWidth: game.combo > 1 ? 3 : 1
                            )
                    )
                    .shadow(color: game.combo > 1 ? .yellow.opacity(0.45) : .clear, radius: pulse ? 16 : 4)

                VStack(spacing: 2) {
                    ForEach(0..<MatchEngine.size, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<MatchEngine.size, id: \.self) { col in
                                let cell = Cell(row: row, col: col)
                                let tile = game.board[row][col]
                                GemView(tile: tile, selected: game.selected == cell)
                                    .id(tile.id)
                                    .frame(width: cellSize - 2, height: cellSize - 2)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.45).combined(with: .opacity),
                                        removal: .scale(scale: 1.35).combined(with: .opacity)
                                    ))
                                    .contentShape(Rectangle())
                                    .onTapGesture { game.tap(cell) }
                                    .gesture(
                                        DragGesture(minimumDistance: 15).onEnded { value in
                                            game.swipe(
                                                from: cell,
                                                dx: value.translation.width,
                                                dy: value.translation.height
                                            )
                                        }
                                    )
                                    .contextMenu {
                                        Button("مطرقة") { game.hammer(cell) }
                                    }
                            }
                        }
                    }
                }
                .padding(3)
                .animation(.spring(response: 0.30, dampingFraction: 0.70), value: game.board)
            }
            .scaleEffect(pulse ? 1.012 : 1.0)
            .animation(.easeInOut(duration: 0.16), value: pulse)
            .onChange(of: game.celebration) { _, _ in
                pulse = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { pulse = false }
            }
        }
    }
}

struct GemView: View {
    let tile: Tile
    let selected: Bool

    var body: some View {
        ZStack {
            gemShape
                .fill(
                    LinearGradient(
                        colors: [tile.kind.color.opacity(0.72), tile.kind.color, .white.opacity(0.32)],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
                .overlay(gemShape.stroke(.white.opacity(0.48), lineWidth: 1.5))
                .shadow(color: .black.opacity(0.28), radius: 2, y: 3)
                .shadow(color: tile.kind.color.opacity(0.55), radius: selected ? 11 : 3)

            gemShape
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.58), .clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .scaleEffect(0.72)
                .offset(y: -5)

            Image(systemName: specialSymbol)
                .font(.system(size: tile.special == .none ? 17 : 23, weight: .black))
                .foregroundStyle(.white.opacity(tile.special == .none ? 0.72 : 1.0))
                .shadow(color: .black.opacity(0.25), radius: 1, y: 1)

            if tile.blocker > 0 {
                RoundedRectangle(cornerRadius: 13)
                    .fill(.cyan.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(.white.opacity(0.92), lineWidth: 3)
                    )
                Image(systemName: "snowflake")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .shadow(color: .cyan, radius: 4)
            }
        }
        .padding(3)
        .scaleEffect(selected ? 1.10 : 1.0)
        .rotationEffect(.degrees(selected ? 2 : 0))
        .animation(.spring(response: 0.22, dampingFraction: 0.62), value: selected)
    }

    private var gemShape: AnyShape {
        switch tile.kind {
        case .ruby:
            return AnyShape(RoundedRectangle(cornerRadius: 16))
        case .sapphire:
            return AnyShape(DiamondShape())
        case .emerald:
            return AnyShape(Capsule())
        case .sun:
            return AnyShape(CrownGemShape())
        case .grape:
            return AnyShape(RoundedRectangle(cornerRadius: 7))
        case .pearl:
            return AnyShape(Circle())
        }
    }

    private var specialSymbol: String {
        switch tile.special {
        case .bomb: return "burst.fill"
        case .rainbow: return "sparkles"
        case .rowRocket: return "arrow.left.and.right.circle.fill"
        case .columnRocket: return "arrow.up.and.down.circle.fill"
        case .none:
            switch tile.kind {
            case .ruby: return "heart.fill"
            case .sapphire: return "diamond.fill"
            case .emerald: return "leaf.fill"
            case .sun: return "crown.fill"
            case .grape: return "flower.fill"
            case .pearl: return "drop.fill"
            }
        }
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            p.closeSubpath()
        }
    }
}

struct CrownGemShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.maxY * 0.82))
            p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.02, y: rect.minY + rect.height * 0.25))
            p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.30, y: rect.minY + rect.height * 0.48))
            p.addLine(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.10))
            p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.70, y: rect.minY + rect.height * 0.48))
            p.addLine(to: CGPoint(x: rect.minX + rect.width * 0.98, y: rect.minY + rect.height * 0.25))
            p.addLine(to: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.maxY * 0.82))
            p.closeSubpath()
        }
    }
}

struct ResultCard: View {
    @EnvironmentObject var game: CrownStore
    let win: Bool
    @State private var celebrate = false

    private var stars: Int { game.save.completed[game.level.id] ?? 1 }

    var body: some View {
        ZStack {
            Color.black.opacity(0.68).ignoresSafeArea()

            if win {
                ForEach(0..<16, id: \.self) { i in
                    Image(systemName: i.isMultiple(of: 3) ? "star.fill" : "sparkles")
                        .foregroundStyle(i.isMultiple(of: 2) ? .yellow : .white)
                        .font(.system(size: CGFloat(12 + (i % 4) * 5)))
                        .offset(
                            x: celebrate ? CGFloat((i % 5) * 72 - 145) : 0,
                            y: celebrate ? CGFloat((i % 4) * 95 - 180) : 0
                        )
                        .opacity(celebrate ? 0.9 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.62).delay(Double(i) * 0.025), value: celebrate)
                }
            }

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [win ? .yellow : .pink, .clear],
                                center: .center,
                                startRadius: 5,
                                endRadius: 72
                            )
                        )
                        .frame(width: 145, height: 145)
                    Image(systemName: win ? "crown.fill" : "heart.slash.fill")
                        .font(.system(size: 70, weight: .black))
                        .foregroundStyle(win ? .yellow : .pink)
                        .scaleEffect(celebrate ? 1.08 : 0.75)
                        .rotationEffect(.degrees(celebrate && win ? -5 : 0))
                }

                Text(win ? "رائع!" : "كانت قريبة!")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(win ? RoyalTheme.navy : .pink)

                Text(win ? "اكتمل المستوى \(game.level.id)" : "جرّب استراتيجية مختلفة")
                    .font(.headline.bold())
                    .foregroundStyle(.gray)

                if win {
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { index in
                            Image(systemName: index < stars ? "star.fill" : "star")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(index < stars ? .yellow : .gray.opacity(0.4))
                                .scaleEffect(celebrate ? 1 : 0.3)
                                .animation(.spring(response: 0.45).delay(Double(index) * 0.12), value: celebrate)
                        }
                    }

                    HStack(spacing: 20) {
                        reward(icon: "circle.fill", value: "+\(50 + stars * 25)", label: "عملات", color: .orange)
                        reward(icon: "star.circle.fill", value: "+\(stars)", label: "تجديد", color: .purple)
                    }
                    .padding(.vertical, 4)
                }

                RoyalButton(title: win ? "المستوى التالي" : "حاول مجددًا", icon: win ? "play.fill" : "arrow.clockwise") {
                    if win { game.next() } else { game.start(game.level.id) }
                }

                if win {
                    Button {
                        game.state = .map
                        game.screen = .renovation
                    } label: {
                        Label("تجديد الحديقة", systemImage: "hammer.fill")
                            .font(.headline.bold())
                            .foregroundStyle(RoyalTheme.navy)
                    }
                    .buttonStyle(.plain)
                }

                Button("العودة للخريطة") { game.map() }
                    .font(.subheadline.bold())
                    .foregroundStyle(.gray)
            }
            .padding(26)
            .frame(maxWidth: 350)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(LinearGradient(colors: [RoyalTheme.cream, .white], startPoint: .top, endPoint: .bottom))
                    .overlay(RoundedRectangle(cornerRadius: 30).stroke(RoyalTheme.gold, lineWidth: 4))
                    .shadow(color: .black.opacity(0.45), radius: 18, y: 8)
            )
            .padding(18)
        }
        .onAppear { celebrate = true }
    }

    private func reward(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(value).font(.title3.bold()).foregroundStyle(RoyalTheme.navy)
            Text(label).font(.caption2.bold()).foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
