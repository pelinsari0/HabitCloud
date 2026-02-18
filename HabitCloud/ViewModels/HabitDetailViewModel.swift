

import Foundation
import FirebaseFirestore
import Combine

@MainActor
class HabitDetailViewModel: ObservableObject {
    @Published var logs: [HabitLog] = []
    @Published var currentMonth: Date = Date()
    @Published var errorMessage: String?
    
    private let firestoreService = FirestoreService.shared
    private let streakService = StreakService.shared
    private let dateService = DateService.shared
    nonisolated(unsafe) private var logsListener: ListenerRegistration?
    
    var habit: Habit
    var userId: String
    
    init(habit: Habit, userId: String) {
        self.habit = habit
        self.userId = userId
        startListening()
    }
    
    deinit {
        stopListening()
    }
    
    func startListening() {
        logsListener = firestoreService.listenToLogs(habitId: habit.id ?? "", for: userId) { [weak self] logs in
            Task { @MainActor in
                self?.logs = logs
            }
        }
    }
    
    nonisolated func stopListening() {
        logsListener?.remove()
        logsListener = nil
    }
    
    var streak: Int {
        return streakService.calculateStreak(habit: habit, logs: logs)
    }
    
    func isCompleted(date: Date) -> Bool {
        let dateKey = dateService.dateKey(from: date)
        return logs.first(where: { $0.dateKey == dateKey })?.done ?? false
    }
    
    func isScheduled(date: Date) -> Bool {
        return habit.isScheduledFor(date: date)
    }
    
    func nextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func previousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    func toggleDay(date: Date) async {
        let dateKey = dateService.dateKey(from: date)
        let currentStatus = logs.first(where: { $0.dateKey == dateKey })?.done ?? false
        
        do {
            try await firestoreService.setLog(habitId: habit.id ?? "", for: userId, dateKey: dateKey, done: !currentStatus)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
