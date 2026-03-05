import Foundation
import UserNotifications

@Observable
@MainActor
class NotificationService {
    var isAuthorized = false
    var notificationHour: Int = 20
    var notificationMinute: Int = 30

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            if granted {
                scheduleDailyReminder()
            }
        } catch {
            isAuthorized = false
        }
    }

    func scheduleDailyReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily_gratitude"])

        let content = UNMutableNotificationContent()
        content.title = "Grace AI"
        content.body = "Prenditi un momento per la gratitudine 🙏"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = notificationHour
        dateComponents.minute = notificationMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_gratitude", content: content, trigger: trigger)

        center.add(request)
    }

    func updateNotificationTime(hour: Int, minute: Int) {
        notificationHour = hour
        notificationMinute = minute
        UserDefaults.standard.set(hour, forKey: "notificationHour")
        UserDefaults.standard.set(minute, forKey: "notificationMinute")
        scheduleDailyReminder()
    }

    func loadSavedTime() {
        if UserDefaults.standard.object(forKey: "notificationHour") != nil {
            notificationHour = UserDefaults.standard.integer(forKey: "notificationHour")
            notificationMinute = UserDefaults.standard.integer(forKey: "notificationMinute")
        }
    }
}
