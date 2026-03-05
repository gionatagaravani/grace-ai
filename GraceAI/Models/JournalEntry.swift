import Foundation
import SwiftData

@Model
class JournalEntry {
    var id: UUID
    var gratitudeText: String
    var aiReflection: String
    var date: Date

    init(gratitudeText: String, aiReflection: String = "", date: Date = Date()) {
        self.id = UUID()
        self.gratitudeText = gratitudeText
        self.aiReflection = aiReflection
        self.date = date
    }

    var dayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
