import SwiftUI

nonisolated(unsafe) let appGold = Color(red: 212/255, green: 175/255, blue: 55/255)
nonisolated(unsafe) let appNavy = Color(red: 26/255, green: 43/255, blue: 60/255)
nonisolated(unsafe) let appCream = Color(red: 249/255, green: 249/255, blue: 247/255)
nonisolated(unsafe) let appCreamDark = Color(red: 18/255, green: 25/255, blue: 35/255)

struct GraceCardStyle: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(colorScheme == .dark ? Color.white.opacity(0.06) : .white)
            .clipShape(.rect(cornerRadius: 20))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func graceCard() -> some View {
        modifier(GraceCardStyle())
    }
}
