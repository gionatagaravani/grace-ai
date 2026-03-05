import WidgetKit
import SwiftUI

nonisolated struct GraceEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let lastReflection: String
}

nonisolated struct GraceProvider: TimelineProvider {
    func placeholder(in context: Context) -> GraceEntry {
        GraceEntry(date: .now, streak: 7, lastReflection: "\"Rendete grazie al Signore, perché egli è buono.\" — Salmo 136:1")
    }

    func getSnapshot(in context: Context, completion: @escaping (GraceEntry) -> Void) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GraceEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func loadEntry() -> GraceEntry {
        let shared = UserDefaults(suiteName: "group.app.rork.graceai.shared")
        let streak = shared?.integer(forKey: "streak") ?? 0
        let reflection = shared?.string(forKey: "lastReflection") ?? "Inizia il tuo percorso di gratitudine oggi."
        return GraceEntry(date: .now, streak: streak, lastReflection: reflection)
    }
}

struct GraceWidgetSmallView: View {
    var entry: GraceEntry

    private let gold = Color(red: 212/255, green: 175/255, blue: 55/255)
    private let navy = Color(red: 26/255, green: 43/255, blue: 60/255)
    private let cream = Color(red: 249/255, green: 249/255, blue: 247/255)

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 28))
                .foregroundStyle(gold.gradient)

            Text("\(entry.streak)")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(navy)

            Text("giorni")
                .font(.system(.caption, design: .serif))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(cream, for: .widget)
    }
}

struct GraceWidgetMediumView: View {
    var entry: GraceEntry

    private let gold = Color(red: 212/255, green: 175/255, blue: 55/255)
    private let navy = Color(red: 26/255, green: 43/255, blue: 60/255)
    private let cream = Color(red: 249/255, green: 249/255, blue: 247/255)

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(gold.gradient)

                Text("\(entry.streak)")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(navy)

                Text("streak")
                    .font(.system(.caption2, design: .serif))
                    .foregroundStyle(.secondary)
            }
            .frame(width: 80)

            Divider()
                .frame(height: 60)
                .overlay(gold.opacity(0.3))

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                        .foregroundStyle(gold)
                    Text("Parola di Conforto")
                        .font(.system(.caption2, design: .serif, weight: .semibold))
                        .foregroundStyle(gold)
                }

                Text(entry.lastReflection)
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(navy)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 4)
        .containerBackground(cream, for: .widget)
    }
}

struct GraceAIWidget: Widget {
    let kind: String = "GraceAIWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GraceProvider()) { entry in
            GraceWidgetView(entry: entry)
        }
        .configurationDisplayName("Grace AI")
        .description("Il tuo streak di gratitudine e l'ultima riflessione.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct GraceWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: GraceEntry

    var body: some View {
        switch family {
        case .systemSmall:
            GraceWidgetSmallView(entry: entry)
        default:
            GraceWidgetMediumView(entry: entry)
        }
    }
}
