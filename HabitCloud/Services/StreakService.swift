
import Foundation

class StreakService {
    static let shared = StreakService()
    
    private let dateService = DateService.shared
    
    private init() {}
    
    func calculateStreak(habit: Habit, logs: [HabitLog]) -> Int {
        // Get today's date
        let today = dateService.startOfDay(Date())
        
        // Create a dictionary of completed dates
        let completedDates = Set(logs.filter { $0.done }.compactMap { dateService.date(from: $0.dateKey) })
        
        var streak = 0
        var currentDate = today
        
        // Check backwards from today
        while true {
            // Skip if not scheduled for this day
            if !habit.isScheduledFor(date: currentDate) {
                // Move to previous day
                guard let previousDay = dateService.addDays(-1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
                continue
            }
            
            // Check if completed on scheduled day
            if completedDates.contains(where: { dateService.isSameDay($0, currentDate) }) {
                streak += 1
                // Move to previous day
                guard let previousDay = dateService.addDays(-1, to: currentDate) else {
                    break
                }
                currentDate = previousDay
            } else {
                // If this is today and not completed yet, don't break streak
                if dateService.isToday(currentDate) {
                    guard let previousDay = dateService.addDays(-1, to: currentDate) else {
                        break
                    }
                    currentDate = previousDay
                    continue
                }
                // Streak is broken
                break
            }
        }
        
        return streak
    }
    
    func getTodayStatus(habit: Habit, logs: [HabitLog]) -> Bool {
        let todayKey = dateService.dateKey(from: Date())
        return logs.first(where: { $0.dateKey == todayKey })?.done ?? false
    }
    
    func getCompletionRate(habit: Habit, logs: [HabitLog], days: Int) -> Double {
        let today = dateService.startOfDay(Date())
        
        var scheduledDays = 0
        var completedDays = 0
        
        let completedDates = Set(logs.filter { $0.done }.compactMap { dateService.date(from: $0.dateKey) })
        
        for dayOffset in 0..<days {
            guard let date = dateService.addDays(-dayOffset, to: today) else { continue }
            
            if habit.isScheduledFor(date: date) {
                scheduledDays += 1
                
                if completedDates.contains(where: { dateService.isSameDay($0, date) }) {
                    completedDays += 1
                }
            }
        }
        
        guard scheduledDays > 0 else { return 0.0 }
        
        return Double(completedDays) / Double(scheduledDays)
    }
}
