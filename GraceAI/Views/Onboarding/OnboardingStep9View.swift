import SwiftUI

struct OnboardingStep9View: View {
    let onFinish: () -> Void

    @State private var currentTextIndex = 0
    @State private var isReady = false
    @State private var isPulsing = false
    @State private var appeared = false
    @State private var ringProgress: CGFloat = 0

    private let loadingTexts = [
        "Analyzing your goals...",
        "Aligning your spiritual guide...",
        "Preparing your daily journal...",
        "Ready.",
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Pulsing ring indicator
            ZStack {
                // Background ring
                Circle()
                    .stroke(appNavy.opacity(0.08), lineWidth: 4)
                    .frame(width: 120, height: 120)

                // Animated progress ring
                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        LinearGradient(
                            colors: [appGold, appGold.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                // Inner glow
                Circle()
                    .fill(appGold.opacity(0.08))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isPulsing ? 1.1 : 0.9)
                    .opacity(isPulsing ? 0.6 : 0.2)

                Image(systemName: isReady ? "checkmark" : "sparkle")
                    .font(.system(size: isReady ? 36 : 28, weight: .medium))
                    .foregroundStyle(appGold)
                    .contentTransition(.symbolEffect(.replace))
            }
            .shadow(color: appGold.opacity(0.2), radius: isPulsing ? 20 : 10)

            Spacer().frame(height: 48)

            // Title
            Text("Personalizing your journey...")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(appNavy)
                .opacity(appeared ? 1 : 0)

            Spacer().frame(height: 20)

            // Cycling text
            Text(loadingTexts[currentTextIndex])
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(appNavy.opacity(0.55))
                .id(currentTextIndex)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.4), value: currentTextIndex)

            Spacer()

            // Final CTA
            if isReady {
                OnboardingButton(title: "Start Your Journey") {
                    onFinish()
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer().frame(height: 50)
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                isPulsing = true
            }
            startTextCycling()
            animateRing()
        }
    }

    private func startTextCycling() {
        for i in 1..<loadingTexts.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 * Double(i)) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    currentTextIndex = i
                }

                // When we hit "Ready."
                if i == loadingTexts.count - 1 {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isReady = true
                    }
                }
            }
        }
    }

    private func animateRing() {
        let totalDuration = 1.5 * Double(loadingTexts.count - 1)
        withAnimation(.easeInOut(duration: totalDuration)) {
            ringProgress = 1.0
        }
    }
}
