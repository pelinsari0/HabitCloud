

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Logo
                VStack(spacing: 12) {
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                    
                    Text("HabitCloud")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Track your habits in the cloud")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                
                // Form
                VStack(spacing: 16) {
                    Field(title: "Email", placeholder: "Enter your email", text: $email)
                    
                    Field(title: "Password", placeholder: "Enter your password", text: $password, isSecure: true)
                }
                
                // Error message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Sign In Button
                PrimaryButton("Sign In", isLoading: authViewModel.isLoading) {
                    Task {
                        await authViewModel.signIn(email: email, password: password)
                    }
                }
                .padding(.top, 8)
                
                // Sign Up Link
                Button(action: { showSignUp = true }) {
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                    }
                    .font(.subheadline)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}
