import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @State private var aiService = AIService()
    @State private var streakService = StreakService()
    @State private var gratitudeText: String = ""
    @State private var isSaving: Bool = false
    @State private var showSavedFeedback: Bool = false
    @State private var streakTrigger: Int = 0

    private var hasEntryToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = formatter.string(from: Date())
        return entries.contains { entry in
            formatter.string(from: entry.date) == todayKey
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if !hasEntryToday {
                        newEntrySection
                    } else {
                        todayCompletedBanner
                    }

                    if !entries.isEmpty {
                        pastEntriesSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(colorScheme == .dark ? appNavy : appCream)
            .navigationTitle("Diario")
            .navigationBarTitleDisplayMode(.large)
            .sensoryFeedback(.success, trigger: streakTrigger)
        }
    }

    private var newEntrySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "heart.text.clipboard")
                    .font(.title3)
                    .foregroundStyle(appGold)
                Text("Riflessione del Giorno")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(colorScheme == .dark ? appCream : appNavy)
            }

            Text("Cosa ti ha reso grato oggi?")
                .font(.system(.title2, design: .serif, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? appCream : appNavy)

            TextEditor(text: $gratitudeText)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(colorScheme == .dark ? Color.white.opacity(0.06) : Color.white)
                .clipShape(.rect(cornerRadius: 16))
                .overlay(alignment: .topLeading) {
                    if gratitudeText.isEmpty {
                        Text("Scrivi qui la tua gratitudine...")
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }

            Button {
                saveEntry()
            } label: {
                HStack {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                        Text("Salva e Rifletti")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? AnyShapeStyle(Color.gray.opacity(0.3))
                        : AnyShapeStyle(appGold.gradient)
                )
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 16))
            }
            .disabled(gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
        }
        .graceCard()
    }

    private var todayCompletedBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundStyle(appGold)
                .symbolEffect(.bounce, value: showSavedFeedback)

            Text("Hai già scritto oggi!")
                .font(.system(.headline, design: .serif))
                .foregroundStyle(colorScheme == .dark ? appCream : appNavy)

            Text("Torna domani per una nuova riflessione.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .graceCard()
    }

    private var pastEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Le tue Riflessioni")
                .font(.system(.title3, design: .serif, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? appCream : appNavy)
                .padding(.leading, 4)

            ForEach(entries) { entry in
                JournalCardView(entry: entry)
            }
        }
    }

    private func saveEntry() {
        let text = gratitudeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        isSaving = true

        Task {
            let reflection = await aiService.generateReflection(for: text)
            let entry = JournalEntry(gratitudeText: text, aiReflection: reflection)
            modelContext.insert(entry)
            gratitudeText = ""
            isSaving = false
            showSavedFeedback = true
            streakTrigger += 1

            streakService.recalculate(entries: entries)
        }
    }
}

struct JournalCardView: View {
    let entry: JournalEntry
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(appGold)
                    .font(.caption)
                Text(entry.date, format: .dateTime.day().month(.wide).year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(entry.gratitudeText)
                .font(.body)
                .foregroundStyle(colorScheme == .dark ? appCream : appNavy)
                .lineLimit(3)

            if !entry.aiReflection.isEmpty {
                Divider().opacity(0.3)

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(appGold)
                        .padding(.top, 2)

                    Text(entry.aiReflection)
                        .font(.system(.callout, design: .serif))
                        .foregroundStyle(.secondary)
                        .lineLimit(5)
                }
            }
        }
        .graceCard()
    }
}
