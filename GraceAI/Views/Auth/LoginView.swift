import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var currentNonce: String?
    @State private var isShowingEmailLogin = false
    @State private var isShowingRegister = false
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            ZStack {
                appCream.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "sparkles")
                        .font(.system(size: 60, weight: .light))
                        .foregroundStyle(appGold)
                        .padding(.bottom, 16)

                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(appNavy)

                    Text("Sign in to continue your journey of peace and mindfulness.")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundStyle(appNavy.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)

                    Spacer()

                    // Apple Sign In Button
                    SignInWithAppleButton(.signIn, onRequest: { request in
                        let nonce = randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = sha256(nonce)
                    }, onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                                guard let nonce = currentNonce else {
                                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                }
                                guard let appleIDToken = appleIDCredential.identityToken else {
                                    showError(message: "Unable to fetch identity token")
                                    return
                                }
                                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                    showError(message: "Unable to serialize token string from data")
                                    return
                                }

                                Task {
                                    do {
                                        try await supabaseManager.signInWithApple(idToken: idTokenString, nonce: nonce)
                                        // Upon success, checkSession inside manager updates state
                                    } catch {
                                        showError(message: error.localizedDescription)
                                    }
                                }
                            }
                        case .failure(let error):
                            showError(message: error.localizedDescription)
                        }
                    })
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 54)
                    .cornerRadius(16)
                    .padding(.horizontal, 32)

                    // Email Sign In Button
                    Button {
                        isShowingEmailLogin = true
                    } label: {
                        Text("Sign in with Email")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(appNavy)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(appGold.opacity(0.2))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)
                    
                    // Sign Up Link
                    Button {
                        isShowingRegister = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundStyle(appNavy.opacity(0.6))
                            Text("Sign Up")
                                .foregroundStyle(appGold)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 15, design: .rounded))
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .navigationDestination(isPresented: $isShowingEmailLogin) {
                EmailLoginView()
            }
            .navigationDestination(isPresented: $isShowingRegister) {
                RegisterView()
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
