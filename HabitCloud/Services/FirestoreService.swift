
import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    private let dateService = DateService.shared
    
    private init() {}
    
    // MARK: - Habits
    
    func habitsCollection(for userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("habits")
    }
    
    func logsCollection(for userId: String, habitId: String) -> CollectionReference {
        return habitsCollection(for: userId).document(habitId).collection("logs")
    }
    
    func createHabit(_ habit: Habit, for userId: String) async throws -> String {
        let ref = habitsCollection(for: userId).document()
        var newHabit = habit
        newHabit.id = ref.documentID
        try ref.setData(from: newHabit)
        return ref.documentID
    }
    
    func updateHabit(_ habit: Habit, for userId: String) async throws {
        guard let habitId = habit.id else {
            throw NSError(domain: "FirestoreService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Habit ID is required"])
        }
        try habitsCollection(for: userId).document(habitId).setData(from: habit, merge: true)
    }
    
    func deleteHabit(habitId: String, for userId: String) async throws {
        try await habitsCollection(for: userId).document(habitId).delete()
    }
    
    func listenToHabits(for userId: String, completion: @escaping ([Habit]) -> Void) -> ListenerRegistration {
        return habitsCollection(for: userId)
            .whereField("archived", isEqualTo: false)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let habits = documents.compactMap { document -> Habit? in
                    try? document.data(as: Habit.self)
                }
                completion(habits)
            }
    }
    
    // MARK: - Logs
    
    func setLog(habitId: String, for userId: String, dateKey: String, done: Bool) async throws {
        let logsRef = logsCollection(for: userId, habitId: habitId)
        
        // Check if log exists for this date
        let snapshot = try await logsRef.whereField("dateKey", isEqualTo: dateKey).getDocuments()
        
        if let existingDoc = snapshot.documents.first {
            // Update existing log
            try await existingDoc.reference.updateData([
                "done": done,
                "timestamp": Timestamp(date: Date())
            ])
        } else {
            // Create new log
            let log = HabitLog(dateKey: dateKey, done: done)
            try logsRef.document().setData(from: log)
        }
    }
    
    func getLog(habitId: String, for userId: String, dateKey: String) async throws -> HabitLog? {
        let snapshot = try await logsCollection(for: userId, habitId: habitId)
            .whereField("dateKey", isEqualTo: dateKey)
            .getDocuments()
        
        guard let document = snapshot.documents.first else {
            return nil
        }
        
        return try? document.data(as: HabitLog.self)
    }
    
    func getLogs(habitId: String, for userId: String, from startDate: Date, to endDate: Date) async throws -> [HabitLog] {
        let startKey = dateService.dateKey(from: startDate)
        let endKey = dateService.dateKey(from: endDate)
        
        let snapshot = try await logsCollection(for: userId, habitId: habitId)
            .whereField("dateKey", isGreaterThanOrEqualTo: startKey)
            .whereField("dateKey", isLessThanOrEqualTo: endKey)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: HabitLog.self) }
    }
    
    func getAllLogs(habitId: String, for userId: String) async throws -> [HabitLog] {
        let snapshot = try await logsCollection(for: userId, habitId: habitId)
            .order(by: "dateKey", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: HabitLog.self) }
    }
    
    func listenToLogs(habitId: String, for userId: String, completion: @escaping ([HabitLog]) -> Void) -> ListenerRegistration {
        return logsCollection(for: userId, habitId: habitId)
            .order(by: "dateKey", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let logs = documents.compactMap { try? $0.data(as: HabitLog.self) }
                completion(logs)
            }
    }
}
