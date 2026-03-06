import SwiftUI

// MARK: - Main View

struct TranslationsView: View {
    @State private var downloadManager = BibleDownloadManager()
    @State private var translations: [BibleTranslationMeta] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F9F9F7")
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Loading translations...")
                        .tint(Color(hex: "#D4AF37"))
                } else if translations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "icloud.slash")
                            .font(.largeTitle)
                            .foregroundColor(Color(hex: "#1A2B3C").opacity(0.3))
                        Text("No translations available.")
                            .foregroundColor(Color(hex: "#1A2B3C").opacity(0.6))
                        Button("Retry") {
                            Task { await loadTranslations() }
                        }
                        .padding(.top, 8)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(translations) { translation in
                                TranslationCard(
                                    translation: translation,
                                    manager: downloadManager,
                                    errorMessage: $errorMessage
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Translations")
            .navigationBarTitleDisplayMode(.large)
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
    }
    
    private func loadTranslations() async {
        do {
            isLoading = true
            translations = try await downloadManager.fetchAvailableTranslations()
            isLoading = false
            print("Loaded \(translations.count) translations")
        } catch {
            print("ERROR loading translations: \(error)")
            errorMessage = "Failed to load translations: \(error.localizedDescription)"
            isLoading = false
        }
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
