

import Foundation

class DateService {
    static let shared = DateService()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private init() {}
    
    func dateKey(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func date(from dateKey: String) -> Date? {
        return dateFormatter.date(from: dateKey)
    }
    
    func startOfDay(_ date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
    
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    func daysBetween(_ date1: Date, _ date2: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: date1), to: calendar.startOfDay(for: date2))
        return abs(components.day ?? 0)
    }
    
    func addDays(_ days: Int, to date: Date) -> Date? {
        return Calendar.current.date(byAdding: .day, value: days, to: date)
    }
    
    func startOfMonth(_ date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return Calendar.current.date(from: components) ?? date
    }
    
    func daysInMonth(_ date: Date) -> Int {
        let range = Calendar.current.range(of: .day, in: .month, for: date)
        return range?.count ?? 30
    }
    
    func weekday(_ date: Date) -> Int {
        return Calendar.current.component(.weekday, from: date)
    }
}
