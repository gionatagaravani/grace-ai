import SwiftUI

struct RegisterView: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        ZStack {
            appCream.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Create Account")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(appNavy)
                    .padding(.top, 40)
                    .padding(.bottom, 16)

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(12)
                        .foregroundStyle(appNavy)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(12)
                        .foregroundStyle(appNavy)
                        
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.white.opacity(0.6))
                        .cornerRadius(12)
                        .foregroundStyle(appNavy)
                }
                .padding(.horizontal, 32)
                
                if !password.isEmpty && password != confirmPassword && !confirmPassword.isEmpty {
                    Text("Passwords do not match")
                        .foregroundStyle(.red)
                        .font(.system(size: 14))
                }

                Button {
                    Task {
                        await signUp()
                    }
                } label: {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign Up")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(appNavy)
                    .cornerRadius(16)
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading || password != confirmPassword)
                .opacity((email.isEmpty || password.isEmpty || password != confirmPassword) ? 0.6 : 1.0)
                .padding(.horizontal, 32)
                .padding(.top, 16)

                Spacer()
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private func signUp() async {
        isLoading = true
        do {
            try await supabaseManager.signUp(email: email, password: password)
            // On success, isAuthenticated will become true in the manager
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}
