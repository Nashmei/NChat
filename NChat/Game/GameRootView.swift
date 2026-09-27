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
            case .map:
                MapView().environmentObject(game)
            case .playing, .won, .lost:
                PlayView().environmentObject(game)
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
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 58))
                        .foregroundStyle(.yellow)
                    Text("CROWN GARDENS")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                    Text("Restore the enchanted royal gardens")
                        .foregroundStyle(.white.opacity(0.75))
                }
                .padding(.top, 22)

                HStack {
                    StatPill(icon: "heart.fill", value: "\(game.save.lives)", color: .pink)
                    StatPill(icon: "star.fill", value: "\(game.save.stars)", color: .yellow)
                    StatPill(icon: "circle.fill", value: "\(game.save.coins)", color: .orange)
                }

                LazyVStack(spacing: 12) {
                    ForEach(1...30, id: \.self) { number in
                        let open = number <= game.save.unlockedLevel
                        Button {
                            if open && game.save.lives > 0 { game.start(number) }
                        } label: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(open ? AnyShapeStyle(Color.yellow.gradient) : AnyShapeStyle(Color.gray.gradient))
                                        .frame(width: 58, height: 58)
                                    Text("\(number)")
                                        .font(.title2.bold())
                                        .foregroundStyle(open ? .black : .white.opacity(0.5))
                                }
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(Level.make(number).title).font(.headline)
                                    HStack(spacing: 3) {
                                        ForEach(0..<(game.save.completed[number] ?? 0), id: \.self) { _ in
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                                .font(.caption)
                                        }
                                    }
                                }
                                Spacer()
                                Image(systemName: open ? "play.fill" : "lock.fill")
                            }
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
                        }
                        .buttonStyle(.plain)
                        .disabled(!open)
                    }
                }

                if game.save.lives == 0 {
                    Button("Refill Lives • 250 Coins") { game.buyLives() }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                }
            }
            .padding()
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
            RoundedRectangle(cornerRadius: 12)
                .fill(tile.kind.color.gradient)
                .shadow(color: tile.kind.color.opacity(0.45), radius: selected ? 10 : 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(selected ? 1.0 : 0.25), lineWidth: selected ? 3 : 1)
                )

            Image(systemName: specialSymbol)
                .font(.system(size: 21, weight: .black))
                .foregroundStyle(.white)
                .shadow(radius: 2)

            if tile.blocker > 0 {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.85), lineWidth: 4)
                Image(systemName: "snowflake").foregroundStyle(.white.opacity(0.90))
            }
        }
        .scaleEffect(selected ? 1.08 : 1.0)
        .animation(.spring(response: 0.20), value: selected)
    }

    private var specialSymbol: String {
        switch tile.special {
        case .bomb: return "burst.fill"
        case .rainbow: return "rainbow"
        case .rowRocket: return "arrow.left.and.right"
        case .columnRocket: return "arrow.up.and.down"
        case .none: return tile.kind.symbol
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
