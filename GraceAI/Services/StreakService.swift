import Foundation
import SwiftData
import WidgetKit

@Observable
@MainActor
class StreakService {
    var currentStreak: Int = 0
    var totalEntries: Int = 0
    var journalDays: Set<String> = []

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    func recalculate(entries: [JournalEntry]) {
        totalEntries = entries.count

        journalDays = Set(entries.map { entry in
            dateFormatter.string(from: entry.date)
        })

        currentStreak = calculateStreak(from: journalDays)

        let shared = UserDefaults(suiteName: "group.app.rork.graceai.shared")
        shared?.set(currentStreak, forKey: "streak")

        if let lastEntry = entries.sorted(by: { $0.date > $1.date }).first {
            shared?.set(lastEntry.aiReflection, forKey: "lastReflection")
            shared?.set(lastEntry.gratitudeText, forKey: "lastGratitude")
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    func hasEntryToday(entries: [JournalEntry]) -> Bool {
        let todayKey = dateFormatter.string(from: Date())
        return journalDays.contains(todayKey)
    }

    private func calculateStreak(from days: Set<String>) -> Int {
        guard !days.isEmpty else { return 0 }

        var streak = 0
        var checkDate = Date()

        let todayKey = dateFormatter.string(from: checkDate)
        if !days.contains(todayKey) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        while true {
            let key = dateFormatter.string(from: checkDate)
            if days.contains(key) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }

        return streak
    }
}
