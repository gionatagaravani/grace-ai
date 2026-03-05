import SwiftUI

struct OnboardingStep6View: View {
    @Binding var selectedGoal: String?
    let onContinue: () -> Void

    @State private var appeared = false

    private let options: [(text: String, emoji: String)] = [
        ("Reduce anxiety", "🧘"),
        ("Understand the Scriptures better", "📖"),
        ("Find daily motivation", "⚡"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            Text("What is your main goal here?")
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
                        isSelected: selectedGoal == option.text
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedGoal = option.text
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
