

import Foundation
import FirebaseFirestore

struct Habit: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var icon: String
    var colorHex: String
    var createdAt: Date
    var schedule: [Int] // 1 = Sunday, 2 = Monday, ..., 7 = Saturday (matching Calendar weekday)
    var archived: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case icon
        case colorHex
        case createdAt
        case schedule
        case archived
    }
    
    init(id: String? = nil, title: String, icon: String, colorHex: String, createdAt: Date = Date(), schedule: [Int] = [], archived: Bool = false) {
        self.id = id
        self.title = title
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.schedule = schedule
        self.archived = archived
    }
    
    // Helper to check if habit is scheduled for a specific date
    func isScheduledFor(date: Date) -> Bool {
        // Empty schedule means daily
        if schedule.isEmpty {
            return true
        }
        
        let weekday = Calendar.current.component(.weekday, from: date)
        return schedule.contains(weekday)
    }
}
