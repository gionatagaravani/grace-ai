import SwiftUI

struct OnboardingStep2View: View {
    let onContinue: () -> Void

    @State private var showBubble1 = false
    @State private var showBubble2 = false
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Chat bubbles
            VStack(spacing: 16) {
                // Bubble 1 — User
                HStack {
                    Spacer()
                    Text("I feel lost today...")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(appNavy)
                        )
                }
                .padding(.horizontal, 32)
                .opacity(showBubble1 ? 1 : 0)
                .offset(y: showBubble1 ? 0 : 16)

                // Bubble 2 — Grace
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkle")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(appGold)

                        Text("You are never alone. Let's reflect together.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(appNavy)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                    )
                    Spacer()
                }
                .padding(.horizontal, 32)
                .opacity(showBubble2 ? 1 : 0)
                .offset(y: showBubble2 ? 0 : 16)
            }

            Spacer().frame(height: 48)

            // Text content
            VStack(spacing: 12) {
                Text("A guide always by your side.")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(appNavy)

                Text("Reflect with the Gratitude Journal and chat with your spiritual mentor.")
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
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showBubble1 = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
                showBubble2 = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.4)) {
                appeared = true
            }
        }
    }
}
