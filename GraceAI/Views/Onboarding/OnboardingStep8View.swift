import SwiftUI

struct OnboardingStep8View: View {
    @Binding var selectedCommitment: String?
    let onContinue: () -> Void

    @State private var appeared = false

    private let options: [(text: String, emoji: String)] = [
        ("Yes, I am ready", "✨"),
        ("I will try my best", "💪"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            Text("Are you ready to dedicate 2 minutes a day to yourself?")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(appNavy)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            Spacer().frame(height: 36)

            VStack(spacing: 14) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    ProfilingCardView(
                        text: option.text,
                        emoji: option.emoji,
                        isSelected: selectedCommitment == option.text
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedCommitment = option.text
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onContinue()
                        }
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.15 * Double(index)), value: appeared)
                }
            }

            Spacer()
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
}
