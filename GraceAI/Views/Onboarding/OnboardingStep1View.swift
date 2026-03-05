import SwiftUI

struct OnboardingStep1View: View {
    let onContinue: () -> Void

    @State private var isPulsing = false
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Breathing gold circle
            ZStack {
                Circle()
                    .fill(appGold.opacity(0.12))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isPulsing ? 1.15 : 0.95)
                    .opacity(isPulsing ? 0.6 : 0.3)

                Circle()
                    .fill(appGold.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .scaleEffect(isPulsing ? 1.08 : 0.96)

                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(appGold)
                    .scaleEffect(isPulsing ? 1.05 : 0.95)
            }
            .shadow(color: appGold.opacity(0.35), radius: isPulsing ? 30 : 15)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.4)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }

            Spacer()
                .frame(height: 48)

            // Text content
            VStack(spacing: 12) {
                Text("Find your inner peace.")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(appNavy)

                Text("Grace AI is your safe haven from daily chaos.")
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
            withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
                appeared = true
            }
        }
    }
}
