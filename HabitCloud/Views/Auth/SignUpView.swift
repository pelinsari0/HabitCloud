

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var localError: String?
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Start tracking your habits today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Form
            VStack(spacing: 16) {
                Field(title: "Email", placeholder: "Enter your email", text: $email)
                
                Field(title: "Password", placeholder: "Enter your password", text: $password, isSecure: true)
                
                Field(title: "Confirm Password", placeholder: "Confirm your password", text: $confirmPassword, isSecure: true)
            }
            
            // Error message
            if let errorMessage = localError ?? authViewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Sign Up Button
            PrimaryButton("Create Account", isLoading: authViewModel.isLoading) {
                guard password == confirmPassword else {
                    localError = "Passwords do not match"
                    return
                }
                localError = nil
                
                Task {
                    await authViewModel.signUp(email: email, password: password)
                    if authViewModel.isAuthenticated {
                        dismiss()
                    }
                }
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationBarTitleDisplayMode(.inline)
    }
}
