import SwiftUI

// MARK: - Main View


struct TranslationsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var downloadManager = BibleDownloadManager()
    @State private var allTranslations: [BibleTranslationMeta] = []
    @State private var languages: [BibleLanguage] = []
    @State private var selectedLanguage: BibleLanguage?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var step: Int = 1 // 1 = Language, 2 = Translation
    
    // Language → translation ID mapping (Must match BibleWelcomeView)
    private let languageMap: [(id: String, name: String, flag: String, ids: [String])] = [
        ("en",  "English",  "🇬🇧", ["asv","asvs","bishops","coverdale","geneva","kjv","kjv_strongs","net","tyndale","web"]),
        ("it",  "Italiano", "🇮🇹", ["diodati"])
    ]
    
    private let navy = Color(hex: "#1A2B3C")
    private let gold = Color(hex: "#D4AF37")
    private let background = Color(hex: "#F9F9F7")

    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(gold)
                    Text("Loading translations...")
                        .font(.subheadline)
                        .foregroundColor(navy.opacity(0.5))
                }
            } else {
                VStack(spacing: 0) {
                    if step == 2 {
                        // Language Header / Back Button
                        HStack {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    step = 1
                                    selectedLanguage = nil
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(gold)
                            }
                            Spacer()
                            if let lang = selectedLanguage {
                                Text("\(lang.flag) \(lang.name)")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(navy)
                            }
                            Spacer()
                            // Invisible spacer to balance the back button
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }.opacity(0)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                        .background(background)
                    }

                    ScrollView {
                        VStack(spacing: 16) {
                            if step == 1 {
                                // Language Selection
                                ForEach(languages) { lang in
                                    LanguageSelectionRow(language: lang) {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            selectedLanguage = lang
                                            step = 2
                                        }
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                }
                            } else if let lang = selectedLanguage {
                                // Versions for Selected Language
                                ForEach(lang.translations) { translation in
                                    TranslationCard(
                                        translation: translation,
                                        manager: downloadManager,
                                        errorMessage: $errorMessage
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle(step == 1 ? "Choose Language" : "Translations")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(step == 2)
        .task {
            await loadTranslations()
        }
        .alert("Translation Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred.")
        }
    }
    
    private func loadTranslations() async {
        do {
            isLoading = true
            allTranslations = try await downloadManager.fetchAvailableTranslations()
            buildLanguages()
            isLoading = false
        } catch {
            errorMessage = "Failed to load translations: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func buildLanguages() {
        languages = languageMap.compactMap { entry in
            let matching = allTranslations.filter { entry.ids.contains($0.id) }
            guard !matching.isEmpty else { return nil }
            return BibleLanguage(id: entry.id, name: entry.name, flag: entry.flag, translations: matching)
        }
    }
}

// MARK: - Language Selection Row

private struct LanguageSelectionRow: View {
    let language: BibleLanguage
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(language.flag)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A2B3C"))
                    Text("\(language.translations.count) versions")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#1A2B3C").opacity(0.45))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#D4AF37").opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Translation Card Component

struct TranslationCard: View {
    let translation: BibleTranslationMeta
    
    @Bindable var manager: BibleDownloadManager
    @Binding var errorMessage: String?
    
    var isDownloaded: Bool {
        manager.isDownloaded(translationID: translation.id)
    }
    
    var progress: Double? {
        manager.downloadProgress[translation.id]
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(translation.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1A2B3C"))
                    .bold()
                
                Text(isDownloaded ? "Available Offline" : "Tap to download")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#1A2B3C").opacity(0.6))
            }
            
            Spacer()
            
            if let downloadProgressValue = progress {
                CircularProgressView(progress: downloadProgressValue)
                    .frame(width: 28, height: 28)
            } else if isDownloaded {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                    
                    Button(role: .destructive) {
                        withAnimation {
                            manager.deleteBible(translationID: translation.id)
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red.opacity(0.8))
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Button {
                    Task {
                        do {
                            try await manager.downloadBible(translationID: translation.id, url: translation.url)
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                } label: {
                    Image(systemName: "icloud.and.arrow.down")
                        .foregroundColor(Color(hex: "#D4AF37"))
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Circular Progress View

struct CircularProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(hex: "#D4AF37").opacity(0.2),
                    lineWidth: 3
                )
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(
                    Color(hex: "#D4AF37"),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
        }
    }
}

#Preview {
    TranslationsView()
}
