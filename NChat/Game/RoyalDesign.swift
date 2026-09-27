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
