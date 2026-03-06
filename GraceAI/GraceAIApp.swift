import SwiftUI
import SwiftData

@main
struct GraceAIApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ChatMessage.self,
            JournalEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.app.rork.graceai.shared")
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasSeenPaywall") private var hasSeenPaywall = false
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    @AppStorage("userName") private var storedUserName = ""
    @AppStorage("userFeeling") private var storedFeeling = ""
    @AppStorage("userGoal") private var storedGoal = ""
    @AppStorage("userGuideTone") private var storedTone = ""
    @AppStorage("userCommitment") private var storedCommitment = ""

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                if !hasSeenPaywall {
                    // Step 1: show paywall after onboarding, before any auth check
                    PaywallView()
                        .transition(.opacity)
                } else if supabaseManager.isAuthenticated {
                    // Step 3: authenticated → dashboard
                    ContentView()
                        .transition(.opacity)
                } else {
                    // Step 2: paywall seen but not logged in → login
                    LoginView()
                        .transition(.opacity)
                }
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: supabaseManager.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                Task {
                    do {
                        try await supabaseManager.syncUserContext()
                    } catch {
                        print("Failed to sync context data: \(error)")
                    }
                }
            }
        }
    }
}
