import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPlan: Plan = .annual
    @State private var showCloseButton = false
    @State private var backgroundOffset: CGFloat = .zero
    
    enum Plan {
        case annual
        case weekly
    }
    
    var body: some View {
        ZStack {
            // Background
            AnimatedBackground(offset: $backgroundOffset)
            
            VStack(spacing: 0) {
                // Header (Close button row)
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.gray)
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.5)))
                            // Glassmorphism on close button too
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .padding(.trailing, 24)
                    .padding(.top, 16)
                    .opacity(showCloseButton ? 0.5 : 0)
                    .animation(.easeIn(duration: 1.0), value: showCloseButton)
                }
                .zIndex(1) // Keep above scrollview
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        PaywallHeaderView()
                            .padding(.top, 16)
                        
                        // Features
                        VStack(spacing: 24) {
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
                            PaywallFeatureRow(
                                icon: "🔥",
                                title: "Streak Protector",
                                description: "Never lose your progress.",
                                delay: 0.3
                            )
                        }
                        
                        // Subscriptions
                        HStack(spacing: 16) {
                            PaywallSubscriptionCard(
                                title: "Annual",
                                price: "$49.99/year",
                                isSelected: selectedPlan == .annual,
                                badgeText: "SAVE 70%"
                            ) {
                                selectedPlan = .annual
                            }
                            
                            PaywallSubscriptionCard(
                                title: "Weekly",
                                price: "$6.99/week",
                                isSelected: selectedPlan == .weekly,
                                badgeText: nil
                            ) {
                                selectedPlan = .weekly
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Footer
                VStack(spacing: 24) {
                    PaywallCTAButton(
                        text: selectedPlan == .annual ? "Start 3-Day Free Trial" : "Continue",
                        subtitle: selectedPlan == .annual ? "Then $49.99/year. Cancel anytime." : "Then $6.99/week. Cancel anytime."
                    ) {
                        // Action
                    }
                    
                    PaywallTrustElementsView(
                        onRestore: {},
                        onTerms: {},
                        onPrivacy: {}
                    )
                }
                .padding(.bottom, 24)
                .padding(.top, 16)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                showCloseButton = true
            }
            
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: true)) {
                backgroundOffset = 100
            }
        }
    }
}

// Background
struct AnimatedBackground: View {
    @Binding var offset: CGFloat
    
    var body: some View {
        ZStack {
            Color.paywallOffWhite.ignoresSafeArea()
            
            // Subtle blur blobs
            Circle()
                .fill(Color.paywallMatteGold.opacity(0.15))
                .frame(width: 400, height: 400)
                .blur(radius: 80)
                .offset(x: -100 + offset, y: -200 + offset)
            
            Circle()
                .fill(Color.paywallDeepNavy.opacity(0.05))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: 100 - offset, y: 300 - offset)
        }
    }
}

#Preview {
    PaywallView()
}
