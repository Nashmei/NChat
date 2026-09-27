import SwiftUI

struct LoadoutView: View {
    @EnvironmentObject private var game: GameStore

    var body: some View {
        NavigationStack {
            ZStack {
                PWTheme.background
                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("ACTIVE SQUAD").font(.caption.bold()).foregroundStyle(.secondary)
                                ForEach(Array(game.loadout.units.enumerated()), id: \.offset) { index, unit in
                                    HStack {
                                        Image(systemName: unit.icon).foregroundStyle(PWTheme.cyan).frame(width: 34)
                                        VStack(alignment: .leading) {
                                            Text(unit.rawValue).font(.headline)
                                            Text("Power \(unit.basePower)").font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Menu {
                                            ForEach(UnitKind.allCases) { replacement in
                                                Button(replacement.rawValue) {
                                                    game.loadout.units[index] = replacement
                                                    game.resetBattle()
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                        }
                                    }
                                    if index < game.loadout.units.count - 1 { Divider() }
                                }
                            }
                        }
                        Text("Squad composition changes your raw combat power. Tactical counters still matter more than a single high-power unit.")
                            .font(.footnote).foregroundStyle(.secondary).padding(.horizontal)
                    }.padding()
                }
            }.navigationTitle("Loadout")
        }
    }
}
