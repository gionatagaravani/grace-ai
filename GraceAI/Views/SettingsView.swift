import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var notificationService = NotificationService()
    @State private var notificationTime = Date()
    @State private var notificationsEnabled: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Promemoria Giornaliero", systemImage: "bell.badge.fill")
                    }
                    .tint(appGold)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue {
                            Task {
                                await notificationService.requestAuthorization()
                            }
                        }
                    }

                    if notificationsEnabled {
                        DatePicker(
                            "Orario",
                            selection: $notificationTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: notificationTime) { _, newValue in
                            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                            notificationService.updateNotificationTime(
                                hour: components.hour ?? 20,
                                minute: components.minute ?? 30
                            )
                        }
                    }
                } header: {
                    Text("Notifiche")
                } footer: {
                    Text("Ricevi un invito serale alla riflessione e alla gratitudine.")
                }

                Section("Informazioni") {
                    HStack {
                        Text("Versione")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Creato con")
                        Spacer()
                        Text("❤️ e Fede")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    VStack(spacing: 8) {
                        Image(systemName: "hands.sparkles.fill")
                            .font(.largeTitle)
                            .foregroundStyle(appGold)

                        Text("Grace AI")
                            .font(.system(.headline, design: .serif))

                        Text("Il tuo compagno di gratitudine\ne riflessione spirituale quotidiana.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Impostazioni")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fatto") { dismiss() }
                        .foregroundStyle(appGold)
                }
            }
            .onAppear {
                notificationService.loadSavedTime()
                var components = DateComponents()
                components.hour = notificationService.notificationHour
                components.minute = notificationService.notificationMinute
                notificationTime = Calendar.current.date(from: components) ?? Date()
            }
        }
    }
}
