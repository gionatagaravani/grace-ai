import SwiftUI

struct PaywallFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(icon)
                .font(.system(size: 24))
                .foregroundColor(.paywallMatteGold)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.paywallDeepNavy)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.paywallDeepNavy.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.paywallOffWhite.ignoresSafeArea()
        VStack(spacing: 20) {
            PaywallFeatureRow(
                icon: "✨",
                title: "Unlimited AI Guidance",
                description: "Chat with your mentor anytime.",
                delay: 0.1
            )
            PaywallFeatureRow(
                icon: "📖",
                title: "Deep Gratitude Insights",
                description: "Advanced reflections on your daily entries.",
                delay: 0.2
            )
        }
    }
}
