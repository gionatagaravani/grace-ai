import SwiftUI

struct ChapterSelectionView: View {
    let book: BibleBook
    @Environment(\.dismiss) var dismiss
    
    @State private var appeared = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 72, maximum: 90), spacing: 14)
    ]
    
    private let navy = Color(hex: "#1A2B3C")
    private let gold = Color(hex: "#D4AF37")
    private let background = Color(hex: "#F9F9F7")
    
    // Derive testament type from book position
    private var isOldTestament: Bool {
        book.testament == .old
    }
    
    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            
            // Ambient gradient blobs
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(gold.opacity(0.06))
                        .frame(width: 320, height: 320)
                        .blur(radius: 70)
                        .position(x: geo.size.width * 0.85, y: 100)
                    
                    Circle()
                        .fill(navy.opacity(0.04))
                        .frame(width: 280, height: 280)
                        .blur(radius: 60)
                        .position(x: geo.size.width * 0.05, y: geo.size.height * 0.6)
                    
                    Circle()
                        .fill(gold.opacity(0.03))
                        .frame(width: 200, height: 200)
                        .blur(radius: 50)
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.9)
                }
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Rich Header ──────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        // Testament badge
                        Text(isOldTestament ? "ANTICO TESTAMENTO" : "NUOVO TESTAMENTO")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(gold.opacity(0.7))
                            .tracking(2)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(gold.opacity(0.08))
                            )
                        
                        Text(book.name)
                            .font(.system(size: 38, weight: .bold, design: .serif))
                            .foregroundColor(navy)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "book.pages")
                                .font(.system(size: 14))
                                .foregroundColor(gold)
                            
                            Text("\(book.chapters.count) capitoli")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(navy.opacity(0.45))
                        }
                        
                        // Decorative divider
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [gold.opacity(0.5), gold.opacity(0.05)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 2.5)
                            .frame(maxWidth: 140)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 25)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: appeared)
                    
                    // ── Chapter Grid ─────────────────────
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(Array(book.chapters.enumerated()), id: \.element.id) { index, chapter in
                            ChapterCell(
                                book: book,
                                chapter: chapter,
                                index: index,
                                appeared: appeared,
                                totalChapters: book.chapters.count
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(book.name)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundColor(navy)
            }
        }
        .onAppear {
            guard !appeared else { return }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

// MARK: - Chapter Cell

private struct ChapterCell: View {
    let book: BibleBook
    let chapter: BibleChapter
    let index: Int
    let appeared: Bool
    let totalChapters: Int
    
    @State private var isPressed = false
    
    private let navy = Color(hex: "#1A2B3C")
    private let gold = Color(hex: "#D4AF37")
    
    // Subtle color variation per row
    private var cellAccent: Color {
        let row = index / 4
        return row.isMultiple(of: 2) ? navy : gold
    }
    
    var body: some View {
        NavigationLink(destination: ReadingView(book: book, chapter: chapter)) {
            ZStack {
                // Card background
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                
                // Subtle top accent line
                VStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    cellAccent.opacity(isPressed ? 0.25 : 0.08),
                                    cellAccent.opacity(0.01)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 30)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                // Border
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        isPressed ? gold.opacity(0.4) : navy.opacity(0.06),
                        lineWidth: isPressed ? 1.5 : 1
                    )
                
                // Content
                VStack(spacing: 4) {
                    Text("\(chapter.number)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(navy)
                    
                    // Small dots indicator for chapters with many verses
                    HStack(spacing: 2) {
                        ForEach(0..<min(chapter.verses.count, 3), id: \.self) { _ in
                            Circle()
                                .fill(gold.opacity(0.4))
                                .frame(width: 3, height: 3)
                        }
                        if chapter.verses.count > 3 {
                            Circle()
                                .fill(gold.opacity(0.2))
                                .frame(width: 3, height: 3)
                        }
                    }
                }
            }
            .frame(height: 76)
            .shadow(
                color: isPressed ? gold.opacity(0.15) : Color.black.opacity(0.03),
                radius: isPressed ? 12 : 8,
                x: 0,
                y: isPressed ? 6 : 3
            )
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(ChapterPressStyle(isPressed: $isPressed))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 25)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.78)
                .delay(Double(min(index, 20)) * 0.025),
            value: appeared
        )
    }
}

// MARK: - Press Style with Haptic

private struct ChapterPressStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
                if newValue {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            }
    }
}

#Preview {
    NavigationStack {
        ChapterSelectionView(book: BibleDataService.shared.getBooks().first!)
    }
}
