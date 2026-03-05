import WidgetKit
import SwiftUI

// MARK: - Colori Personalizzati
private let deepNavy = Color(red: 26/255, green: 43/255, blue: 60/255) // #1A2B3C
private let matteGold = Color(red: 212/255, green: 175/255, blue: 55/255) // #D4AF37

// MARK: - Timeline Entry
struct GraceAIEntry: TimelineEntry {
    let date: Date
    let streakCount: Int
    let dailyVerse: String
    let verseReference: String
    let weeklyProgress: [Bool]
}

// MARK: - Timeline Provider
struct GraceAIProvider: TimelineProvider {
    let appGroupID = "group.app.rork.graceai.shared"
    
    private func getEntry(for date: Date) -> GraceAIEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        
        let streakCount = defaults?.integer(forKey: "streakCount") ?? 0
        let dailyVerse = defaults?.string(forKey: "dailyVerse") ?? "Non temere, perché io sono con te..."
        let verseReference = defaults?.string(forKey: "verseReference") ?? "Isaia 41:10"
        let weeklyProgress = defaults?.array(forKey: "weeklyProgress") as? [Bool] ?? [false, false, false, false, false, false, false]
        
        return GraceAIEntry(
            date: date,
            streakCount: streakCount,
            dailyVerse: dailyVerse,
            verseReference: verseReference,
            weeklyProgress: weeklyProgress
        )
    }

    func placeholder(in context: Context) -> GraceAIEntry {
        GraceAIEntry(
            date: Date(),
            streakCount: 5,
            dailyVerse: "Non temere, perché io sono con te, non smarrirti, perché io sono il tuo Dio.",
            verseReference: "Isaia 41:10",
            weeklyProgress: [true, true, true, false, false, false, false]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (GraceAIEntry) -> ()) {
        let entry = getEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getEntry(for: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

// MARK: - UI: Componente Giorno (Weekly Tracker)
struct GraceAITrackerDayView: View {
    let dayLabel: String
    let isCompleted: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isCompleted ? matteGold : Color.white.opacity(0.3))
                .frame(width: 8, height: 8)
            Text(dayLabel)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - UI: Home Screen Widget (.systemMedium)
struct GraceAIMediumWidgetView: View {
    var entry: GraceAIEntry
    let days = ["L", "M", "M", "G", "V", "S", "D"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("Il tuo Versetto")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Pillola Streak
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(matteGold)
                    Text("\(entry.streakCount)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())
            }
            
            // Corpo Centrale
            VStack(spacing: 4) {
                Text(entry.dailyVerse)
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                
                Text(entry.verseReference)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(matteGold)
            }
            .frame(maxHeight: .infinity)
            
            // Footer: Weekly Tracker
            HStack(spacing: 16) {
                ForEach(0..<7, id: \.self) { index in
                    let isCompleted = index < entry.weeklyProgress.count ? entry.weeklyProgress[index] : false
                    GraceAITrackerDayView(dayLabel: days[index], isCompleted: isCompleted)
                }
            }
        }
    }
}

// MARK: - UI: Lock Screen Widget (.accessoryRectangular)
struct GraceAILockScreenWidgetView: View {
    var entry: GraceAIEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                Text("\(entry.streakCount) Giorni")
                    .font(.headline)
            }
            Text(entry.dailyVerse)
                .font(.caption)
                .lineLimit(2)
        }
    }
}

// MARK: - Main Entry View
struct GraceAIWidgetEntryView : View {
    var entry: GraceAIProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemMedium:
            GraceAIMediumWidgetView(entry: entry)
                .containerBackground(deepNavy, for: .widget)
        case .accessoryRectangular:
            GraceAILockScreenWidgetView(entry: entry)
                .containerBackground(.clear, for: .widget)
        default:
            Text("Formato non supportato")
                .containerBackground(deepNavy, for: .widget)
        }
    }
}

// MARK: - Widget Configuration
struct GraceAIWidget: Widget {
    let kind: String = "GraceAIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GraceAIProvider()) { entry in
            GraceAIWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Grace AI Widget")
        .description("Il tuo versetto quotidiano e i tuoi progressi.")
        .supportedFamilies([.systemMedium, .accessoryRectangular])
    }
}
