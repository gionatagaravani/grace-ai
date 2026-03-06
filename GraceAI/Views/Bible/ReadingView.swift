import SwiftUI

struct ReadingView: View {
    let book: BibleBook
    let chapter: BibleChapter
    
    @State private var ttsManager = BibleTTSManager()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#F9F9F7") // Cream background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(chapter.verses) { verse in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(verse.number)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "#D4AF37")) // Gold
                                .baselineOffset(2)
                            
                            Text(verse.text)
                                .font(.system(size: 18, weight: .regular, design: .serif))
                                .foregroundColor(Color(hex: "#1A2B3C")) // Navy
                                .lineSpacing(6)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 120) // Space for bottom bar
            }
            
            // Player Bottom Bar
            PlayerBottomBar(ttsManager: ttsManager, chapter: chapter)
        }
        .navigationTitle("\(book.name) \(chapter.number)")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            ttsManager.stop()
        }
    }
}

struct PlayerBottomBar: View {
    var ttsManager: BibleTTSManager
    let chapter: BibleChapter
    
    var body: some View {
        HStack(spacing: 24) {
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if ttsManager.isPlaying {
                        ttsManager.pause()
                    } else {
                        let allText = chapter.verses.map { $0.text }.joined(separator: " ")
                        ttsManager.speak(text: allText)
                    }
                }
                
                // Add Haptic Feedback
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }) {
                Image(systemName: ttsManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: "#1A2B3C"))
                    .frame(width: 64, height: 64)
                    .background(Circle().fill(Color(hex: "#D4AF37")))
                    .shadow(color: Color(hex: "#D4AF37").opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    ttsManager.stop()
                }
                
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#1A2B3C").opacity(0.6))
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.white.opacity(0.5)))
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.white.opacity(0.75))
                .shadow(color: Color.black.opacity(0.04), radius: 10, y: 5)
                .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40))
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

#Preview {
    NavigationView {
        ReadingView(book: BibleDataService.shared.getBooks().first!, chapter: BibleDataService.shared.getBooks().first!.chapters.first!)
    }
}
