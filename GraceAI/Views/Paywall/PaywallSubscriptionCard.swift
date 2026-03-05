import SwiftUI

struct PaywallSubscriptionCard: View {
    let title: String
    let price: String
    let isSelected: Bool
    let badgeText: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .center, spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? .paywallDeepNavy : .paywallDeepNavy.opacity(0.7))
                    
                    Text(price)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(isSelected ? .paywallDeepNavy : .paywallDeepNavy.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.6))
                        // Glassmorphism effect overlay
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.paywallMatteGold : Color.clear, lineWidth: 2)
                )
                .scaleEffect(isSelected ? 1.02 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                // Floating Badge
                if let badgeText = badgeText {
                    Text(badgeText)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(Color.paywallMatteGold)
                        )
                        .offset(x: -12, y: -12)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.paywallOffWhite.ignoresSafeArea()
        HStack(spacing: 16) {
            PaywallSubscriptionCard(
                title: "Annual",
                price: "$49.99/year",
                isSelected: true,
                badgeText: "SAVE 70%"
            ) {}
            
            PaywallSubscriptionCard(
                title: "Weekly",
                price: "$6.99/week",
                isSelected: false,
                badgeText: nil
            ) {}
        }
        .padding()
    }
}
