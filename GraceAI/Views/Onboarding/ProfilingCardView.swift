import SwiftUI

struct ProfilingCardView: View {
    let text: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            HStack(spacing: 16) {
                Text(emoji)
                    .font(.system(size: 28))

                Text(text)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(appNavy)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? appGold : Color.clear, lineWidth: 2.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(OnboardingButtonStyle())
        .padding(.horizontal, 24)
    }
}
