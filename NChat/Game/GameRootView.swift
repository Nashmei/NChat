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

struct MapView: View {
    @EnvironmentObject var game: CrownStore

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoyalWorldBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        title
                        stats
                            .padding(.bottom, 20)

                        ZStack {
                            RoyalPath()
                                .stroke(
                                    LinearGradient(colors: [.yellow.opacity(0.85), .orange], startPoint: .top, endPoint: .bottom),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round, dash: [4, 18])
                                )
                                .frame(height: 1500)
                                .padding(.horizontal, 70)

                            VStack(spacing: 18) {
                                ForEach(1...30, id: \.self) { number in
                                    levelNode(number, width: geo.size.width)
                                }
                            }
                            .padding(.vertical, 24)
                        }
                    }
                }
            }
        }
    }

    private var title: some View {
        VStack(spacing: 2) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))
                    .frame(width: 74, height: 74)
                    .shadow(color: .yellow.opacity(0.55), radius: 16)
                Image(systemName: "crown.fill")
                    .font(.system(size: 39, weight: .black))
                    .foregroundStyle(.white)
            }
            Text("CROWN")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(.yellow)
                .shadow(color: .black.opacity(0.6), radius: 2, y: 2)
            Text("GARDENS")
                .font(.system(size: 23, weight: .black, design: .rounded))
                .tracking(5)
                .foregroundStyle(.white)
        }
        .padding(.top, 18)
    }

    private var stats: some View {
        HStack(spacing: 8) {
            StatPill(icon: "heart.fill", value: "\(game.save.lives)", color: .pink)
            StatPill(icon: "star.fill", value: "\(game.save.stars)", color: .yellow)
            StatPill(icon: "circle.fill", value: "\(game.save.coins)", color: .orange)
        }
        .padding(.top, 12)
    }

    private func levelNode(_ number: Int, width: CGFloat) -> some View {
        let open = number <= game.save.unlockedLevel
        let stars = game.save.completed[number] ?? 0
        let offset = sin(Double(number) * 1.42) * Double(min(width * 0.25, 95))
        return Button {
            if open && game.save.lives > 0 { game.start(number) }
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(
                            open
                            ? LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
                            : LinearGradient(colors: [.gray, .black.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(width: 70, height: 70)
                        .overlay(Circle().stroke(.white.opacity(0.85), lineWidth: 4))
                        .shadow(color: open ? .yellow.opacity(0.45) : .black.opacity(0.4), radius: 8, y: 4)
                    if open {
                        Text("\(number)")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "lock.fill").font(.title2)
                    }
                }
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < stars ? "star.fill" : "star")
                            .font(.caption2.bold())
                            .foregroundStyle(.yellow)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!open)
        .offset(x: offset)
        .frame(maxWidth: .infinity)
    }
}

struct RoyalWorldBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.16, green: 0.64, blue: 0.96), Color(red: 0.42, green: 0.82, blue: 0.66)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                ZStack(alignment: .bottom) {
                    ForEach(0..<5, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.95))
                            .frame(width: i == 2 ? 105 : 72, height: i == 2 ? 170 : 125)
                            .overlay(alignment: .top) {
                                Triangle()
                                    .fill(i == 2 ? Color.blue : Color.indigo)
                                    .frame(width: i == 2 ? 115 : 80, height: 70)
                                    .offset(y: -46)
                            }
                            .offset(x: CGFloat(i - 2) * 62)
                    }
                }
                .frame(height: 190)
                .padding(.top, 130)

                Spacer()

                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(0..<8, id: \.self) { i in
                        Circle()
                            .fill(i.isMultiple(of: 2) ? Color.green : Color.mint)
                            .frame(width: 100, height: 100)
                            .offset(y: CGFloat((i % 3) * 18))
                    }
                }
                .blur(radius: 1)
            }
            .opacity(0.75)
            .ignoresSafeArea()
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
            VStack(spacing: 10) {
                HStack {
                    Button { game.map() } label: {
                        Image(systemName: "chevron.left").font(.title2.bold())
                    }
                    Spacer()
                    Text("LEVEL \(game.level.id)").font(.headline.bold())
                    Spacer()
                    Text("\(game.movesLeft)")
                        .font(.title2.bold().monospacedDigit())
                        .frame(width: 44)
                        .padding(7)
                        .background(.black.opacity(0.30), in: Circle())
                }
                .padding(.horizontal)

                targets

                BoardView()
                    .environmentObject(game)
                    .frame(
                        width: min(geometry.size.width - 16, 500),
                        height: min(geometry.size.width - 16, 500)
                    )

                HStack(spacing: 30) {
                    VStack {
                        Image(systemName: "hammer.fill").font(.title2)
                        Text("Hold a tile").font(.caption2)
                        Text("×\(game.save.hammer)").bold()
                    }
                    Button { game.shuffle() } label: {
                        VStack {
                            Image(systemName: "shuffle").font(.title2)
                            Text("Shuffle").font(.caption2)
                            Text("×\(game.save.shuffle)").bold()
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)

                Text(game.message)
                    .font(.caption.bold())
                    .foregroundStyle(.yellow)
                    .frame(height: 18)
                Spacer()
            }
            .padding(.top, 6)
        }
        .overlay {
            if game.state == .won {
                ResultCard(win: true).environmentObject(game)
            } else if game.state == .lost {
                ResultCard(win: false).environmentObject(game)
            }
        }
    }

    private var targets: some View {
        HStack(spacing: 8) {
            ForEach(Array(game.remaining.keys), id: \.self) { kind in
                HStack(spacing: 5) {
                    Image(systemName: kind.symbol).foregroundStyle(kind.color)
                    Text("\(game.remaining[kind] ?? 0)").bold().monospacedDigit()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(.black.opacity(0.25), in: Capsule())
            }
            Spacer()
            Text("\(game.score)").font(.caption.bold().monospacedDigit())
        }
        .padding(.horizontal)
    }
}

struct BoardView: View {
    @EnvironmentObject var game: CrownStore

    var body: some View {
        GeometryReader { geometry in
            let cellSize = geometry.size.width / CGFloat(MatchEngine.size)
            ZStack {
                RoundedRectangle(cornerRadius: 22).fill(.black.opacity(0.24))
                VStack(spacing: 2) {
                    ForEach(0..<MatchEngine.size, id: \.self) { row in
                        HStack(spacing: 2) {
                            ForEach(0..<MatchEngine.size, id: \.self) { col in
                                let cell = Cell(row: row, col: col)
                                let tile = game.board[row][col]
                                GemView(tile: tile, selected: game.selected == cell)
                                    .frame(width: cellSize - 2, height: cellSize - 2)
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
                                        Button("Hammer") { game.hammer(cell) }
                                    }
                            }
                        }
                    }
                }
                .padding(3)
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

    var body: some View {
        ZStack {
            Color.black.opacity(0.60).ignoresSafeArea()
            VStack(spacing: 18) {
                Image(systemName: win ? "crown.fill" : "heart.slash.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(win ? .yellow : .pink)

                Text(win ? "SPECTACULAR!" : "SO CLOSE!")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))

                Text(win ? "The garden shines brighter." : "Try a new strategy and come back stronger.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                if win {
                    HStack {
                        ForEach(0..<(game.save.completed[game.level.id] ?? 1), id: \.self) { _ in
                            Image(systemName: "star.fill").font(.title).foregroundStyle(.yellow)
                        }
                    }
                }

                Button(win ? "NEXT LEVEL" : "TRY AGAIN") {
                    if win { game.next() } else { game.start(game.level.id) }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(win ? .green : .pink)

                Button("MAP") { game.map() }.buttonStyle(.bordered)
            }
            .padding(28)
            .frame(maxWidth: 340)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30))
        }
    }
}
