import SwiftUI

/// Full-screen two-step picker: 1) choose language  2) choose translation
struct BibleWelcomeView: View {
    @Binding var loadedBible: BibleTranslation?

    @State private var manager = BibleDownloadManager()
    @State private var allTranslations: [BibleTranslationMeta] = []
    @State private var languages: [BibleLanguage] = []
    @State private var selectedLanguage: BibleLanguage?
    @State private var selectedTranslation: BibleTranslationMeta?
    @State private var isLoadingList = true
    @State private var errorMessage: String?
    @State private var step: Int = 1   // 1 = language, 2 = translation
    @State private var logoScale: Double = 0.6
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: Double = 30
    @State private var listOpacity: Double = 0

    private let navy  = Color(hex: "#1A2B3C")
    private let gold  = Color(hex: "#D4AF37")
    private let cream = Color(hex: "#F9F9F7")

    // Language → translation ID mapping
    private let languageMap: [(id: String, name: String, flag: String, ids: [String])] = [
        ("en",  "English",  "🇬🇧", ["asv","asvs","bishops","coverdale","geneva","kjv","kjv_strongs","net","tyndale","web"]),
        ("it",  "Italiano", "🇮🇹", ["diodati"])
    ]

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [navy, navy.opacity(0.85), Color(hex: "#0D1B2A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Particles
            GeometryReader { geo in
                ForEach(0..<14, id: \.self) { i in
                    Circle()
                        .fill(gold.opacity(0.10))
                        .frame(width: CGFloat.seeded(4...18, i),
                               height: CGFloat.seeded(4...18, i))
                        .position(x: CGFloat.seeded(0...geo.size.width, i + 50),
                                  y: CGFloat.seeded(0...geo.size.height, i + 100))
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // ── Logo + heading ────────────────────────────────
                VStack(spacing: 16) {
                    ZStack {
                        Circle().fill(gold.opacity(0.12)).frame(width: 140, height: 140)
                        Circle().fill(gold.opacity(0.18)).frame(width: 110, height: 110)
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 52, weight: .light))
                            .foregroundColor(gold)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                    VStack(spacing: 8) {
                        if step == 1 {
                            Text("Choose your language")
                                .font(.system(size: 30, weight: .bold, design: .serif))
                                .foregroundColor(.white)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal:   .move(edge: .leading).combined(with: .opacity)
                                ))
                        } else {
                            HStack(spacing: 10) {
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        step = 1
                                        selectedTranslation = nil
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(gold)
                                }
                                Text(selectedLanguage.map { "\($0.flag) \($0.name)" } ?? "")
                                    .font(.system(size: 30, weight: .bold, design: .serif))
                                    .foregroundColor(.white)
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal:   .move(edge: .leading).combined(with: .opacity)
                            ))
                        }

                        Text(step == 1
                             ? "Pick the language of your preferred translation."
                             : "Select a Bible version to download and read offline.")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.55))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .offset(y: titleOffset)
                    .opacity(logoOpacity)
                }

                Spacer().frame(height: 40)

                // ── List ─────────────────────────────────────────
                Group {
                    if isLoadingList {
                        VStack(spacing: 12) {
                            ProgressView().tint(gold)
                            Text("Loading…")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(height: 200)
                    } else if let error = errorMessage {
                        VStack(spacing: 12) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.largeTitle).foregroundColor(gold.opacity(0.6))
                            Text(error)
                                .font(.subheadline).foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center).padding(.horizontal, 32)
                            Button("Retry") { Task { await loadList() } }
                                .foregroundColor(gold)
                        }
                        .frame(height: 200)
                    } else if step == 1 {
                        // Language picker
                        VStack(spacing: 12) {
                            ForEach(Array(languages.enumerated()), id: \.element.id) { index, lang in
                                LanguageRow(language: lang, index: index) {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                        selectedLanguage = lang
                                        selectedTranslation = nil
                                        step = 2
                                    }
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)
                        ))
                    } else {
                        // Translation picker
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 10) {
                                ForEach(Array((selectedLanguage?.translations ?? []).enumerated()),
                                        id: \.element.id) { index, t in
                                    TranslationPickerRow(
                                        translation: t,
                                        isSelected: selectedTranslation?.id == t.id,
                                        index: index
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedTranslation = t
                                        }
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .frame(maxHeight: 340)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal:   .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
                .opacity(listOpacity)

                Spacer()

                // ── Download CTA (step 2 only) ────────────────────
                if step == 2, let selected = selectedTranslation {
                    let progress = manager.downloadProgress[selected.id]
                    let isDownloading = progress != nil

                    Button {
                        guard !isDownloading else { return }
                        Task { await downloadSelected(selected) }
                    } label: {
                        ZStack {
                            if isDownloading, let p = progress {
                                HStack(spacing: 12) {
                                    CircularProgressView(progress: p)
                                        .frame(width: 22, height: 22)
                                        .colorScheme(.dark)
                                    Text("\(Int(p * 100))%")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            } else {
                                HStack(spacing: 10) {
                                    Image(systemName: "arrow.down.circle.fill")
                                        .font(.system(size: 20))
                                    Text("Download \(selected.id.uppercased())")
                                        .font(.system(size: 17, weight: .bold))
                                }
                                .foregroundColor(navy)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(gold)
                                .shadow(color: gold.opacity(0.45), radius: 16, y: 6)
                        )
                    }
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTranslation?.id)
                }

                Spacer().frame(height: 100)
            }
        }
        .task { await loadList() }
        .onAppear { runEntryAnimation() }
    }

    // MARK: - Helpers

    private func loadList() async {
        isLoadingList = true
        errorMessage = nil
        do {
            allTranslations = try await manager.fetchAvailableTranslations()
            buildLanguages()
        } catch {
            errorMessage = "Could not load list. Check your connection."
        }
        isLoadingList = false
    }

    private func buildLanguages() {
        languages = languageMap.compactMap { entry in
            let matching = allTranslations.filter { entry.ids.contains($0.id) }
            guard !matching.isEmpty else { return nil }
            return BibleLanguage(id: entry.id, name: entry.name, flag: entry.flag, translations: matching)
        }
    }

    private func downloadSelected(_ translation: BibleTranslationMeta) async {
        do {
            try await manager.downloadBible(translationID: translation.id, url: translation.url)
            if let bible = try manager.loadLocalBible(translationID: translation.id) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                UserDefaults.standard.set(translation.id, forKey: "lastUsedBibleId")
                withAnimation(.easeInOut(duration: 0.5)) {
                    loadedBible = bible
                }
            }
        } catch {
            errorMessage = "Download failed: \(error.localizedDescription)"
        }
    }

    private func runEntryAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.1)) {
            logoScale = 1.0
            logoOpacity = 1.0
            titleOffset = 0
        }
        withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
            listOpacity = 1.0
        }
    }
}

// MARK: - Language Row

private struct LanguageRow: View {
    let language: BibleLanguage
    let index: Int
    let onTap: () -> Void

    @State private var appeared = false
    private let gold = Color(hex: "#D4AF37")

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 18) {
                Text(language.flag)
                    .font(.system(size: 36))

                VStack(alignment: .leading, spacing: 2) {
                    Text(language.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    Text("\(language.translations.count) version\(language.translations.count == 1 ? "" : "s")")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(gold.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 24)
        .onAppear {
            withAnimation(.easeOut(duration: 0.45).delay(Double(index) * 0.1 + 0.4)) {
                appeared = true
            }
        }
    }
}

// MARK: - Translation Picker Row

private struct TranslationPickerRow: View {
    let translation: BibleTranslationMeta
    let isSelected: Bool
    let index: Int

    @State private var appeared = false
    private let gold = Color(hex: "#D4AF37")

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(isSelected ? gold : Color.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 24, height: 24)
                if isSelected {
                    Circle().fill(gold).frame(width: 14, height: 14)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

            VStack(alignment: .leading, spacing: 2) {
                Text(translation.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(translation.id.uppercased())
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? gold : Color.white.opacity(0.4))
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(gold)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? gold.opacity(0.5) : Color.clear, lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(Double(index) * 0.06 + 0.15)) {
                appeared = true
            }
        }
    }
}

// MARK: - Deterministic CGFloat helpers

private extension CGFloat {
    static func seeded(_ range: ClosedRange<CGFloat>, _ seed: Int) -> CGFloat {
        let s = UInt64(bitPattern: Int64(seed &* 2654435761))
        let frac = CGFloat(s >> 11) / CGFloat(1 << 53)
        return range.lowerBound + frac * (range.upperBound - range.lowerBound)
    }
}
