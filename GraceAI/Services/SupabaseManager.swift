import Foundation
import Supabase
import AuthenticationServices
import CryptoKit
import Combine

@MainActor
class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    // Replace with your actual Supabase URL and Anon Key
    private let supabaseURL = URL(string: "https://idzkgqplossyajtdnbbx.supabase.co")!
    private let supabaseKey = "sb_publishable_xsXdJ7khQlJy549gl_Wypw_gHuj65A8"
    
    let client: SupabaseClient
    
    @Published var isAuthenticated = false
    @Published var currentUserID: UUID?
    
    struct ProfileResponse: Decodable {
        let user_name: String?
    }
    
    struct OnboardingDataResponse: Decodable {
        let feeling: String
        let goal: String
        let guide_tone: String
        let commitment: String
    }
    
    private init() {
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        
        Task {
            await checkSession()
        }
    }
    
    func checkSession() async {
        do {
            let session = try await client.auth.session
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.currentUserID = session.user.id
            }
        } catch {
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.currentUserID = nil
            }
        }
    }
    
    // MARK: - Email Auth
    
    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
        await checkSession()
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
        await checkSession()
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.currentUserID = nil
        }
    }
    
    // MARK: - Apple Sign In
    
    // We need to pass the identityToken string received from Apple
    func signInWithApple(idToken: String, nonce: String) async throws {
        _ = try await client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idToken, nonce: nonce))
        await checkSession()
    }
    
    // MARK: - Data Synchronization
    
    func syncUserContext() async throws {
        guard let userId = currentUserID else { return }
        
        do {
            // Check if user already has onboarding data
            let existingData: [OnboardingDataResponse] = try await client.database
                .from("onboarding_data")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            if let data = existingData.first {
                // User already exists, fetch username and overwrite local defaults
                let profileData: [ProfileResponse] = try await client.database
                    .from("profiles")
                    .select("user_name")
                    .eq("id", value: userId.uuidString)
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    if let profile = profileData.first, let name = profile.user_name {
                        UserDefaults.standard.set(name, forKey: "userName")
                    }
                    UserDefaults.standard.set(data.feeling, forKey: "userFeeling")
                    UserDefaults.standard.set(data.goal, forKey: "userGoal")
                    UserDefaults.standard.set(data.guide_tone, forKey: "userGuideTone")
                    UserDefaults.standard.set(data.commitment, forKey: "userCommitment")
                    
                    // Mark onboarding and paywall as completed/seen because they are logging into an existing account
                    UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    UserDefaults.standard.set(true, forKey: "hasSeenPaywall")
                }
            } else {
                // New user, save local onboarding data to the DB
                let userName = UserDefaults.standard.string(forKey: "userName") ?? ""
                let feeling = UserDefaults.standard.string(forKey: "userFeeling") ?? ""
                let goal = UserDefaults.standard.string(forKey: "userGoal") ?? ""
                let tone = UserDefaults.standard.string(forKey: "userGuideTone") ?? ""
                let commitment = UserDefaults.standard.string(forKey: "userCommitment") ?? ""
                
                try await saveOnboardingData(userName: userName, feeling: feeling, goal: goal, guideTone: tone, commitment: commitment)
            }
        } catch {
            print("Failed to sync user context: \(error)")
            throw error
        }
    }
    
    private func saveOnboardingData(userName: String, feeling: String, goal: String, guideTone: String, commitment: String) async throws {
        guard let userId = currentUserID else { return }
        
        // 1. Update public.profiles with userName
        struct ProfileUpdate: Encodable {
            let user_name: String
        }
        
        try await client.database
            .from("profiles")
            .update(ProfileUpdate(user_name: userName))
            .eq("id", value: userId.uuidString)
            .execute()
        
        // 2. Insert into onboarding_data
        struct OnboardingData: Encodable {
            let user_id: UUID
            let feeling: String
            let goal: String
            let guide_tone: String
            let commitment: String
        }
        
        let data = OnboardingData(
            user_id: userId,
            feeling: feeling,
            goal: goal,
            guide_tone: guideTone,
            commitment: commitment
        )
        
        try await client.database
            .from("onboarding_data")
            .insert(data)
            .execute()
    }
    
    // MARK: - App Data Synchronization
    
    func syncChatMessage(_ message: ChatMessage) async throws {
        guard let userId = currentUserID else { return }
        
        struct ChatMessageData: Encodable {
            let id: UUID
            let user_id: UUID
            let content: String
            let is_user: Bool
            let timestamp: Date
            let style: String
        }
        
        let data = ChatMessageData(
            id: message.id,
            user_id: userId,
            content: message.content,
            is_user: message.isFromUser,
            timestamp: message.timestamp,
            style: message.conversationStyle
        )
        
        try await client.database
            .from("chat_messages")
            .upsert(data)
            .execute()
    }
    
    func syncJournalEntry(_ entry: JournalEntry) async throws {
        guard let userId = currentUserID else { return }
        
        struct JournalEntryData: Encodable {
            let id: UUID
            let user_id: UUID
            let title: String
            let content: String
            let date: Date
            let mood: String?
        }
        
        let data = JournalEntryData(
            id: entry.id,
            user_id: userId,
            title: String(entry.gratitudeText.prefix(100)),
            content: entry.gratitudeText + "\n\nRiflessione AI:\n" + entry.aiReflection,
            date: entry.date,
            mood: nil
        )
        
        try await client.database
            .from("journal_entries")
            .upsert(data)
            .execute()
    }
    
    // MARK: - User Stats (Percorso) Synchronization
    
    func syncUserStats(currentStreak: Int, totalEntries: Int, activeDays: Int) async throws {
        guard let userId = currentUserID else { return }
        
        struct UserStatsData: Encodable {
            let id: UUID
            let current_streak: Int
            let total_entries: Int
            let active_days: Int
        }
        
        let data = UserStatsData(
            id: userId,
            current_streak: currentStreak,
            total_entries: totalEntries,
            active_days: activeDays
        )
        
        try await client.database
            .from("user_stats")
            .upsert(data)
            .execute()
    }
}


// Apple Sign In Helper for random nonce generation
func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                )
            }
            return random
        }

        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }

            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }

    return result
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()

    return hashString
}
