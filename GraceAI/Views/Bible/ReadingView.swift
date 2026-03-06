import SwiftUI

struct ReadingView: View {
    let book: BibleBook
    @State var chapter: BibleChapter
    
    @State private var ttsManager = BibleTTSManager()
    @State private var appeared = false
    @State private var chapterTransition = false
    @Environment(\.dismiss) var dismiss
    
    private let navy = Color(hex: "#1A2B3C")
    private let gold = Color(hex: "#D4AF37")
    private let background = Color(hex: "#F9F9F7")
    
    private var currentChapterIndex: Int {
        book.chapters.firstIndex(where: { $0.number == chapter.number }) ?? 0
    }
    
    private var hasNextChapter: Bool {
        currentChapterIndex < book.chapters.count - 1
    }
    
    private var hasPreviousChapter: Bool {
        currentChapterIndex > 0
    }
    
    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            
            // Ambient blurs
            GeometryReader { geo in
                Circle()
                    .fill(gold.opacity(0.04))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .position(x: geo.size.width * 0.85, y: 120)
            }
            .ignoresSafeArea()
            
            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Chapter Header
                        chapterHeader
                            .id("top")
                        
                        // Verses
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(Array(chapter.verses.enumerated()), id: \.element.id) { index, verse in
                                VerseRow(verse: verse, index: index, appeared: appeared)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                        
                        // Next Chapter CTA at the bottom
                        if hasNextChapter {
                            nextChapterBanner
                                .padding(.bottom, 120)
                        }
                    }
                }
                .onChange(of: chapter.number) { _ in
                    withAnimation {
                        scrollProxy.scrollTo("top", anchor: .top)
                    }
                }
            }
            
            // Compact Audio Controls — right side
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    CompactAudioControl(ttsManager: ttsManager, chapter: chapter)
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(book.name) \(chapter.number)")
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundColor(navy)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if hasNextChapter {
                    Button {
                        goToNextChapter()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Cap. \(book.chapters[currentChapterIndex + 1].number)")
                                .font(.system(size: 13, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(gold)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
        .onDisappear {
            ttsManager.stop()
        }
    }
    
    // MARK: - Chapter Header
    
    private var chapterHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Chapter number badge
            HStack(spacing: 12) {
                Text("CAPITOLO")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(gold.opacity(0.6))
                    .tracking(2)
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(gold.opacity(0.2))
                    .frame(height: 1)
            }
            .padding(.bottom, 4)
            
            Text("\(chapter.number)")
                .font(.system(size: 64, weight: .bold, design: .serif))
                .foregroundColor(navy)
            
            // Divider
            RoundedRectangle(cornerRadius: 2)
                .fill(
                    LinearGradient(
                        colors: [gold.opacity(0.6), gold.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 3)
                .frame(maxWidth: 120)
                .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 32)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .opacity(chapterTransition ? 0 : 1)
    }
    
    // MARK: - Next Chapter Banner
    
    private var nextChapterBanner: some View {
        Button {
            goToNextChapter()
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prossimo capitolo")
                        .font(.system(size: 13))
                        .foregroundColor(navy.opacity(0.5))
                    Text("Capitolo \(book.chapters[currentChapterIndex + 1].number)")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(navy)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(gold)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
            )
            .padding(.horizontal, 24)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Navigation
    
    private func goToNextChapter() {
        guard hasNextChapter else { return }
        ttsManager.stop()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        withAnimation(.easeOut(duration: 0.2)) {
            chapterTransition = true
            appeared = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            chapter = book.chapters[currentChapterIndex + 1]
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                chapterTransition = false
                appeared = true
            }
        }
    }
}

// MARK: - Verse Row

private struct VerseRow: View {
    let verse: BibleVerse
    let index: Int
    let appeared: Bool
    
    private let navy = Color(hex: "#1A2B3C")
    private let gold = Color(hex: "#D4AF37")
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(verse.number)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(gold)
                .frame(width: 24, alignment: .trailing)
                .padding(.top, 4)
            
            Text(verse.text)
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundColor(navy)
                .lineSpacing(8)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8)
                .delay(Double(min(index, 10)) * 0.04),
            value: appeared
        )
    }
}

// MARK: - Compact Audio Control (FAB, right-aligned)

struct CompactAudioControl: View {
    @Bindable var ttsManager: BibleTTSManager
    let chapter: BibleChapter
    
    @State private var pulseScale: CGFloat = 1.0
    
    private let navy = Color(hex: "#1A2B3C")
    private let gold = Color(hex: "#D4AF37")
    
    var body: some View {
        VStack(spacing: 10) {
            // Stop button (only when playing/paused)
            if ttsManager.isPlaying {
                Button {
                    ttsManager.stop()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(navy.opacity(0.6))
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                        )
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            // Play/Pause button
            Button {
                if ttsManager.isPlaying {
                    ttsManager.pause()
                } else {
                    let allText = chapter.verses.map { $0.text }.joined(separator: " ")
                    ttsManager.speak(text: allText)
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                ZStack {
                    // Pulse ring when playing
                    if ttsManager.isPlaying {
                        Circle()
                            .stroke(gold.opacity(0.3), lineWidth: 2)
                            .frame(width: 52, height: 52)
                            .scaleEffect(pulseScale)
                            .opacity(2 - pulseScale)
                    }
                    
                    Image(systemName: ttsManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(navy)
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(gold)
                                .shadow(color: gold.opacity(0.4), radius: 10, x: 0, y: 4)
                        )
                        .scaleEffect(ttsManager.isPlaying ? 1.05 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: ttsManager.isPlaying)
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: ttsManager.isPlaying)
        .onChange(of: ttsManager.isPlaying) { isPlaying in
            if isPlaying {
                startPulse()
            } else {
                pulseScale = 1.0
            }
        }
    }
    
    private func startPulse() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
            pulseScale = 1.8
        }
    }
}

#Preview {
    let sampleVerse = BibleVerse(chapterId: "genesis-1", number: 1, text: "In the beginning God created the heavens and the earth.")
    let sampleChapter = BibleChapter(bookId: "genesis", number: 1, verses: [sampleVerse])
    let sampleBook = BibleBook(id: "genesis", name: "Genesis", testament: .old, chapters: [sampleChapter])
    NavigationStack {
        ReadingView(book: sampleBook, chapter: sampleChapter)
    }
}
