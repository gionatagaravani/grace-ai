import SwiftUI

struct OnboardingStep4View: View {
    @Binding var userName: String
    let onContinue: () -> Void

    @FocusState private var isNameFocused: Bool
    @State private var appeared = false

    private var isValid: Bool {
        !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)

            // Title
            VStack(spacing: 12) {
                Text("How should we call you?")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(appNavy)

                Text("We'd love to make this personal.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(appNavy.opacity(0.55))
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .padding(.horizontal, 32)

            Spacer().frame(height: 48)

            // Text field
            TextField("Your name", text: $userName)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(appNavy)
                .multilineTextAlignment(.center)
                .padding(.vertical, 18)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isNameFocused ? appGold.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
                .padding(.horizontal, 32)
                .focused($isNameFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .submitLabel(.continue)
                .onSubmit {
                    if isValid { onContinue() }
                }
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.95)

            Spacer()

            OnboardingButton(title: "Continue", isEnabled: isValid) {
                isNameFocused = false
                onContinue()
            }
            .opacity(appeared ? 1 : 0)

            Spacer().frame(height: 50)
        }
        .onAppear {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
    }
}
