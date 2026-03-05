import Foundation
import WidgetKit

class WidgetDataManager {
    // Stesso App Group ID configurato nel progetto (Sia main app che estensione)
    static let appGroupID = "group.app.rork.graceai.shared"
    
    static func updateWidgetData(streakCount: Int,
                                 dailyVerse: String,
                                 verseReference: String,
                                 weeklyProgress: [Bool]) {
        
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            print("❌ Impossibile inizializzare UserDefaults per l'App Group.")
            return
        }
        
        // Salviamo i dati aggiornati
        defaults.set(streakCount, forKey: "streakCount")
        defaults.set(dailyVerse, forKey: "dailyVerse")
        defaults.set(verseReference, forKey: "verseReference")
        defaults.set(weeklyProgress, forKey: "weeklyProgress")
        
        // Forziamo il ricaricamento di tutte le timeline dei widget
        WidgetCenter.shared.reloadAllTimelines()
    }
}
