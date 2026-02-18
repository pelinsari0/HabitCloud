

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class HabitsViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let firestoreService = FirestoreService.shared
    private let streakService = StreakService.shared
    private let dateService = DateService.shared
    nonisolated(unsafe) private var habitsListener: ListenerRegistration?
    nonisolated(unsafe) private var logsListeners: [String: ListenerRegistration] = [:]
    
    @Published var habitLogs: [String: [HabitLog]] = [:] // habitId -> logs
    @Published var habitStreaks: [String: Int] = [:] // habitId -> streak
    @Published var habitTodayStatus: [String: Bool] = [:] // habitId -> done today
    
    var userId: String?
    
    deinit {
        stopListening()
    }
    
    func startListening(userId: String) {
        self.userId = userId
        
        // Listen to habits
        habitsListener = firestoreService.listenToHabits(for: userId) { [weak self] habits in
            Task { @MainActor in
                self?.habits = habits
                
                // Set up logs listeners for each habit
                self?.setupLogsListeners(for: habits, userId: userId)
            }
        }
    }
    
    nonisolated func stopListening() {
        habitsListener?.remove()
        habitsListener = nil
        
        for listener in logsListeners.values {
            listener.remove()
        }
        logsListeners.removeAll()
    }
    
    private func setupLogsListeners(for habits: [Habit], userId: String) {
        // Remove listeners for habits that no longer exist
        let habitIds = Set(habits.compactMap { $0.id })
        for (id, listener) in logsListeners {
            if !habitIds.contains(id) {
                listener.remove()
                logsListeners.removeValue(forKey: id)
                habitLogs.removeValue(forKey: id)
                habitStreaks.removeValue(forKey: id)
                habitTodayStatus.removeValue(forKey: id)
            }
        }
        
        // Add listeners for new habits
        for habit in habits {
            guard let habitId = habit.id else { continue }
            
            if logsListeners[habitId] == nil {
                logsListeners[habitId] = firestoreService.listenToLogs(habitId: habitId, for: userId) { [weak self] logs in
                    Task { @MainActor in
                        self?.habitLogs[habitId] = logs
                        self?.habitStreaks[habitId] = self?.streakService.calculateStreak(habit: habit, logs: logs) ?? 0
                        self?.habitTodayStatus[habitId] = self?.streakService.getTodayStatus(habit: habit, logs: logs) ?? false
                    }
                }
            }
        }
    }
    
    func createHabit(title: String, icon: String, colorHex: String, schedule: [Int]) async {
        guard let userId = userId else {
            errorMessage = "User not authenticated"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let habit = Habit(title: title, icon: icon, colorHex: colorHex, schedule: schedule)
        
        do {
            _ = try await firestoreService.createHabit(habit, for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteHabit(_ habit: Habit) async {
        guard let userId = userId, let habitId = habit.id else {
            errorMessage = "Invalid habit or user"
            return
        }
        
        do {
            try await firestoreService.deleteHabit(habitId: habitId, for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleTodayStatus(for habit: Habit) async {
        guard let userId = userId, let habitId = habit.id else {
            errorMessage = "Invalid habit or user"
            return
        }
        
        let todayKey = dateService.dateKey(from: Date())
        let currentStatus = habitTodayStatus[habitId] ?? false
        
        do {
            try await firestoreService.setLog(habitId: habitId, for: userId, dateKey: todayKey, done: !currentStatus)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
