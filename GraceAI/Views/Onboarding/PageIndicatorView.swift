import SwiftUI

struct PageIndicatorView: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step == currentStep ? appGold : appNavy.opacity(0.15))
                    .frame(width: step == currentStep ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentStep)
            }
        }
    }
}
