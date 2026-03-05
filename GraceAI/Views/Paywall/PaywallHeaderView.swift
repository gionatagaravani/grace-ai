import SwiftUI

struct PaywallHeaderView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Glowing elegant icon
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.paywallMatteGold)
                .shadow(color: .paywallMatteGold.opacity(0.6), radius: 15, x: 0, y: 0)
                .padding(.bottom, 8)
            
            // Title
            Text("Your spiritual journey is ready.")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(.paywallDeepNavy)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Subtitle
            Text("Unlock Grace AI Premium to find daily peace and deep reflections.")
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(.paywallDeepNavy.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

#Preview {
    ZStack {
        Color.paywallOffWhite.ignoresSafeArea()
        PaywallHeaderView()
    }
}
