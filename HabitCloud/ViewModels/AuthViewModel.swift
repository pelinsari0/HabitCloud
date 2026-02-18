
import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let authService = AuthService.shared
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handle = authStateHandle {
            authService.removeAuthStateListener(handle)
        }
    }
    
    private func setupAuthStateListener() {
        authStateHandle = authService.addAuthStateListener { [weak self] user in
            Task { @MainActor in
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func signUp(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔵 Attempting sign up with email: \(email)")
            _ = try await authService.signUp(email: email, password: password)
            print("✅ Sign up successful!")
        } catch {
            print("❌ Sign up error: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            if let authError = error as NSError? {
                print("❌ Error code: \(authError.code)")
                print("❌ Error domain: \(authError.domain)")
                print("❌ Error userInfo: \(authError.userInfo)")
            }
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔵 Attempting sign in with email: \(email)")
            _ = try await authService.signIn(email: email, password: password)
            print("✅ Sign in successful!")
        } catch {
            print("❌ Sign in error: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            if let authError = error as NSError? {
                print("❌ Error code: \(authError.code)")
                print("❌ Error domain: \(authError.domain)")
                print("❌ Error userInfo: \(authError.userInfo)")
            }
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try authService.signOut()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
