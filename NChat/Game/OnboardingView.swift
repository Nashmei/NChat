import SwiftUI

struct OnboardingView: View {
    @Binding var completed: Bool
    @State private var page = 0

    private let items: [(String,String,String)] = [
        ("Command, don't tap.", "Give natural-language orders. Your strategy becomes the controller.", "brain.head.profile"),
        ("Rules stay fair.", "AI interprets intent. The deterministic engine owns health, damage and victory.", "shield.checkered"),
        ("Master the arena.", "Read lanes, counter tactics, build your rating and refine your loadout.", "scope")
    ]

    var body: some View {
        ZStack {
            PWTheme.background
            VStack(spacing: 28) {
                Spacer()
                Image(systemName: items[page].2)
                    .font(.system(size: 72, weight: .thin))
                    .foregroundStyle(PWTheme.cyan)
                    .symbolEffect(.pulse)
                VStack(spacing: 12) {
                    Text(items[page].0).font(.largeTitle.bold()).multilineTextAlignment(.center)
                    Text(items[page].1).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
                }
                Spacer()
                HStack(spacing: 8) {
                    ForEach(items.indices, id: \.self) { i in
                        Capsule().fill(i == page ? PWTheme.accent : .white.opacity(0.15))
                            .frame(width: i == page ? 28 : 8, height: 8)
                    }
                }
                Button(page == items.count - 1 ? "ENTER PROMPT WARS" : "CONTINUE") {
                    withAnimation(.snappy) {
                        if page < items.count - 1 { page += 1 } else { completed = true }
                    }
                }
                .buttonStyle(.borderedProminent).tint(PWTheme.accent)
                .controlSize(.large).frame(maxWidth: .infinity)
            }.padding(24)
        }
    }
}
