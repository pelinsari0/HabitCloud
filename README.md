# HabitCloud ☁️

A beautiful, cloud-synced habit tracker built with SwiftUI and Firebase.

## Features

- ✅ **Daily Habit Tracking** - Check off habits as you complete them
- 🔥 **Streak Tracking** - Monitor consecutive completion streaks
- 📅 **Custom Schedules** - Set specific days for each habit (Mon-Sun)
- 🎨 **Personalization** - Choose from 16 icons and 12 colors
- 📊 **Statistics** - View 7-day completion rates
- ☁️ **Cloud Sync** - All data synced with Firebase Firestore
- 🔐 **Authentication** - Secure email/password sign-in

## Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **Firebase Auth** - User authentication
- **Firebase Firestore** - Real-time cloud database
- **MVVM Architecture** - Clean separation of concerns
- **Async/Await** - Modern Swift concurrency

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Firebase account

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/HabitCloud.git
cd HabitCloud
```

### 2. Install Firebase Packages

Open `HabitCloud.xcodeproj` in Xcode:

1. Go to **File → Add Package Dependencies**
2. Enter: `https://github.com/firebase/firebase-ios-sdk`
3. Select these packages:
   - FirebaseAuth
   - FirebaseCore
   - FirebaseFirestore
4. Click **Add Package**

### 3. Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or use existing)
3. Add an iOS app with your Bundle ID (e.g., `com.yourname.HabitCloud`)
4. Download `GoogleService-Info.plist`
5. Drag the plist file into Xcode (check "Copy items if needed")

### 4. Enable Firebase Services

In Firebase Console:

**Authentication:**
1. Go to **Authentication → Sign-in method**
2. Enable **Email/Password**

**Firestore Database:**
1. Go to **Firestore Database**
2. Click **Create database**
3. Start in **test mode** (for development)
4. Choose your region

### 5. Build & Run

Press `⌘R` in Xcode to build and run!

## Project Structure

```
HabitCloud/
├── App/
│   └── HabitCloudApp.swift          # App entry point
├── Models/
│   ├── Habit.swift                  # Habit data model
│   └── HabitLog.swift               # Log data model
├── Services/
│   ├── AuthService.swift            # Authentication logic
│   ├── FirestoreService.swift       # Database operations
│   ├── StreakService.swift          # Streak calculations
│   └── DateService.swift            # Date utilities
├── ViewModels/
│   ├── AuthViewModel.swift          # Auth state management
│   ├── HabitsViewModel.swift        # Habits list logic
│   └── HabitDetailViewModel.swift   # Detail view logic
└── Views/
    ├── RootView.swift               # Root navigation
    ├── Auth/                        # Sign in/up screens
    ├── Habits/                      # Habit management views
    └── Components/                  # Reusable UI components
```

## Usage

### Creating a Habit

1. Tap the **+** button
2. Enter a habit name (e.g., "Morning Run")
3. Choose an icon and color
4. Select which days to track (leave empty for daily)
5. Tap **Save**

### Tracking Completion

- Tap the checkbox next to a habit to mark it complete for today
- Your streak will automatically update
- View details by tapping on the habit row

### Viewing Statistics

- Switch to the **Stats** tab
- See your 7-day completion rates
- Track progress across all habits

## Firestore Data Structure

```
users/{userId}/
  ├── habits/{habitId}
  │   ├── title: String
  │   ├── icon: String
  │   ├── colorHex: String
  │   ├── schedule: [Int]
  │   ├── createdAt: Timestamp
  │   └── archived: Bool
  │
  └── habits/{habitId}/logs/{logId}
      ├── dateKey: String (yyyy-MM-dd)
      ├── done: Bool
      └── timestamp: Timestamp
```

## License

This project is licensed under the MIT License.
