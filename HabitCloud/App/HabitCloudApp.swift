
import SwiftUI
import FirebaseCore

// Firebase App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🔵 Configuring Firebase...")
        FirebaseApp.configure()
        
        if let app = FirebaseApp.app() {
            print("✅ Firebase configured successfully!")
            print("✅ Firebase app name: \(app.name)")
        } else {
            print("❌ Firebase NOT configured!")
        }
        
        return true
    }
}

@main
struct HabitCloudApp: App {
    // Register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}
