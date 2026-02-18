

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var habitsViewModel = HabitsViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(habitsViewModel)
                    .onAppear {
                        if let userId = authViewModel.user?.uid {
                            habitsViewModel.startListening(userId: userId)
                        }
                    }
                    .onChange(of: authViewModel.user) { oldValue, newValue in
                        if let userId = newValue?.uid {
                            habitsViewModel.startListening(userId: userId)
                        } else {
                            habitsViewModel.stopListening()
                        }
                    }
            } else {
                SignInView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var habitsViewModel: HabitsViewModel
    
    var body: some View {
        TabView {
            HabitsListView()
                .tabItem {
                    Label("Habits", systemImage: "list.bullet.circle.fill")
                }
            
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let email = authViewModel.user?.email {
                        HStack {
                            Text("Email")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(email)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive, action: {
                        authViewModel.signOut()
                    }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
