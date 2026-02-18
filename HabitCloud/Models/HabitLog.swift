

import Foundation
import FirebaseFirestore

struct HabitLog: Identifiable, Codable {
    @DocumentID var id: String?
    var dateKey: String // "yyyy-MM-dd"
    var done: Bool
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case dateKey
        case done
        case timestamp
    }
    
    init(id: String? = nil, dateKey: String, done: Bool, timestamp: Date = Date()) {
        self.id = id
        self.dateKey = dateKey
        self.done = done
        self.timestamp = timestamp
    }
}
