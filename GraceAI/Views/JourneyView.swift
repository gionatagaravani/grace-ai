import SwiftUI
import SwiftData

struct JourneyView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @State private var streakService = StreakService()
    @State private var displayedMonth: Date = Date()
    @State private var streakAnimated: Bool = false
    @State private var flameTrigger: Int = 0

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    streakCard
                    calendarCard
                    statsCard
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(colorScheme == .dark ? appCreamDark : appCream)
            .navigationTitle("Percorso")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                streakService.recalculate(entries: entries)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                    streakAnimated = true
                }
            }
            .onChange(of: entries.count) { _, _ in
                streakService.recalculate(entries: entries)
            }
        }
    }

    private var streakCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 52))
                .foregroundStyle(
                    streakService.currentStreak > 0
                        ? LinearGradient(colors: [appGold, .orange], startPoint: .top, endPoint: .bottom)
                        : LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                )
                .symbolEffect(.bounce, value: flameTrigger)
                .scaleEffect(streakAnimated ? 1.0 : 0.3)
                .opacity(streakAnimated ? 1.0 : 0)

            Text("\(streakService.currentStreak)")
                .font(.system(size: 56, weight: .bold, design: .serif))
                .foregroundStyle(colorScheme == .dark ? appCream : appNavy)
                .scaleEffect(streakAnimated ? 1.0 : 0.5)
                .opacity(streakAnimated ? 1.0 : 0)

            Text(streakService.currentStreak == 1 ? "giorno consecutivo" : "giorni consecutivi")
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(.secondary)

            if streakService.currentStreak == 0 && entries.isEmpty {
                Text("Il tuo percorso inizia oggi.\nScrivi il tuo primo pensiero di gratitudine.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity)
        .graceCard()
        .sensoryFeedback(.success, trigger: flameTrigger)
        .onAppear {
            flameTrigger += 1
        }
    }

    private var calendarCard: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    withAnimation(.snappy) {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth)!
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(appGold)
                }

                Spacer()

                Text(displayedMonth, format: .dateTime.month(.wide).year())
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(colorScheme == .dark ? appCream : appNavy)

                Spacer()

                Button {
                    withAnimation(.snappy) {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth)!
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(appGold)
                }
            }

            let weekdays = ["L", "M", "M", "G", "V", "S", "D"]
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.tertiary)
                }

                ForEach(daysInMonth(), id: \.self) { day in
                    if day == 0 {
                        Text("")
                            .frame(height: 36)
                    } else {
                        let isJournalDay = isDayWithEntry(day: day)
                        let isToday = isTodayDay(day: day)

                        ZStack {
                            if isJournalDay {
                                Circle()
                                    .fill(appGold.gradient)
                                    .frame(width: 34, height: 34)
                            } else if isToday {
                                Circle()
                                    .strokeBorder(appGold.opacity(0.5), lineWidth: 1.5)
                                    .frame(width: 34, height: 34)
                            }

                            Text("\(day)")
                                .font(.callout.weight(isJournalDay ? .bold : .regular))
                                .foregroundStyle(
                                    isJournalDay ? .white :
                                    isToday ? appGold :
                                    (colorScheme == .dark ? appCream.opacity(0.7) : appNavy.opacity(0.7))
                                )
                        }
                        .frame(height: 36)
                    }
                }
            }
        }
        .graceCard()
    }

    private var statsCard: some View {
        HStack(spacing: 20) {
            StatItem(
                icon: "book.closed.fill",
                value: "\(streakService.totalEntries)",
                label: "Riflessioni"
            )

            StatItem(
                icon: "flame.fill",
                value: "\(streakService.currentStreak)",
                label: "Streak"
            )

            StatItem(
                icon: "calendar.badge.checkmark",
                value: "\(streakService.journalDays.count)",
                label: "Giorni Attivi"
            )
        }
        .frame(maxWidth: .infinity)
        .graceCard()
    }

    private func daysInMonth() -> [Int] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!

        var weekday = calendar.component(.weekday, from: firstDay)
        weekday = weekday == 1 ? 7 : weekday - 1

        var days: [Int] = Array(repeating: 0, count: weekday - 1)
        days.append(contentsOf: range.map { $0 })
        return days
    }

    private func isDayWithEntry(day: Int) -> Bool {
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = String(format: "%04d-%02d-%02d", components.year!, components.month!, day)
        return streakService.journalDays.contains(key)
    }

    private func isTodayDay(day: Int) -> Bool {
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let displayComponents = calendar.dateComponents([.year, .month], from: displayedMonth)
        return todayComponents.year == displayComponents.year
            && todayComponents.month == displayComponents.month
            && todayComponents.day == day
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(appGold)

            Text(value)
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundStyle(colorScheme == .dark ? appCream : appNavy)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
