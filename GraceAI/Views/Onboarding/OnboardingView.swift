import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userName") private var storedUserName = ""
    @AppStorage("userFeeling") private var storedFeeling = ""
    @AppStorage("userGoal") private var storedGoal = ""
    @AppStorage("userGuideTone") private var storedTone = ""
    @AppStorage("userCommitment") private var storedCommitment = ""

    @State private var currentStep = 1
    @State private var userName = ""
    @State private var selectedFeeling: String?
    @State private var selectedGoal: String?
    @State private var selectedTone: String?
    @State private var selectedCommitment: String?

    private let totalSteps = 9

    private var stepTransition: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        )
    }

    var body: some View {
        ZStack {
            // Background
            appCream
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page indicator (hidden on step 9)
                if currentStep < 9 {
                    PageIndicatorView(totalSteps: totalSteps, currentStep: currentStep)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        .transition(.opacity)
                }

                // Step content
                ZStack {
                    switch currentStep {
                    case 1:
                        OnboardingStep1View { advanceStep() }
                            .transition(stepTransition)
                    case 2:
                        OnboardingStep2View { advanceStep() }
                            .transition(stepTransition)
                    case 3:
                        OnboardingStep3View { advanceStep() }
                            .transition(stepTransition)
                    case 4:
                        OnboardingStep4View(userName: $userName) { advanceStep() }
                            .transition(stepTransition)
                    case 5:
                        OnboardingStep5View(userName: userName, selectedFeeling: $selectedFeeling) { advanceStep() }
                            .transition(stepTransition)
                    case 6:
                        OnboardingStep6View(selectedGoal: $selectedGoal) { advanceStep() }
                            .transition(stepTransition)
                    case 7:
                        OnboardingStep7View(selectedTone: $selectedTone) { advanceStep() }
                            .transition(stepTransition)
                    case 8:
                        OnboardingStep8View(selectedCommitment: $selectedCommitment) { advanceStep() }
                            .transition(stepTransition)
                    case 9:
                        OnboardingStep9View { finishOnboarding() }
                            .transition(stepTransition)
                    default:
                        EmptyView()
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentStep)
            }
        }
    }

    // MARK: - Actions

    private func advanceStep() {
        guard currentStep < totalSteps else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            currentStep += 1
        }
    }

    private func finishOnboarding() {
        // Persist user choices
        storedUserName = userName
        storedFeeling = selectedFeeling ?? ""
        storedGoal = selectedGoal ?? ""
        storedTone = selectedTone ?? ""
        storedCommitment = selectedCommitment ?? ""

        withAnimation(.easeInOut(duration: 0.4)) {
            hasCompletedOnboarding = true
        }
    }
}
