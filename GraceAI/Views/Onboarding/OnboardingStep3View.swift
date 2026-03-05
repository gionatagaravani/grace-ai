import SwiftUI

struct OnboardingStep3View: View {
    let onContinue: () -> Void

    @State private var flameScale: CGFloat = 0.3
    @State private var flameGlow = false
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Flame animation
            ZStack {
                // Glow backdrop
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [appGold.opacity(0.3), appGold.opacity(0)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(flameGlow ? 1.2 : 0.9)
                    .opacity(flameGlow ? 0.8 : 0.4)

                Image(systemName: "flame.fill")
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [appGold, Color.orange],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .scaleEffect(flameScale)
                    .shadow(color: appGold.opacity(0.5), radius: 20)
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    flameScale = 1.0
                }
                withAnimation(
                    .easeInOut(duration: 1.8)
                    .repeatForever(autoreverses: true)
                ) {
                    flameGlow = true
                }
            }

            Spacer().frame(height: 48)

            // Text content
            VStack(spacing: 12) {
                Text("Build a habit of light.")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(appNavy)

                Text("Just 2 minutes a day to shift your perspective.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(appNavy.opacity(0.55))
                    .multilineTextAlignment(.center)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .padding(.horizontal, 32)

            Spacer()

            OnboardingButton(title: "Continue") {
                onContinue()
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 30)

            Spacer().frame(height: 50)
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                appeared = true
            }
        }
    }
}
