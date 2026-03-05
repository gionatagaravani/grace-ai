import SwiftUI

struct PaywallCTAButton: View {
    let text: String
    let subtitle: String?
    let action: () -> Void
    
    @State private var isBreathing = false
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                action()
            }) {
                Text(text)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.paywallDeepNavy, Color.paywallDeepNavy.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: .paywallDeepNavy.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isBreathing ? 1.03 : 1.0)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isBreathing = true
                }
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.paywallDeepNavy.opacity(0.5))
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ZStack {
        Color.paywallOffWhite.ignoresSafeArea()
        PaywallCTAButton(
            text: "Start 3-Day Free Trial",
            subtitle: "Then $49.99/year. Cancel anytime."
        ) {}
    }
}
