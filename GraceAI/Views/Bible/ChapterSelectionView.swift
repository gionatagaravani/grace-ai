import SwiftUI

struct ChapterSelectionView: View {
    let book: BibleBook
    @Environment(\.dismiss) var dismiss
    
    @State private var appeared = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 70, maximum: 90), spacing: 12)
    ]
    
    private let navy = Color(hex: "#1A2B3C")
    private let gold = Color(hex: "#D4AF37")
    private let background = Color(hex: "#F9F9F7")
    
    var body: some View {
        ZStack {
            background.ignoresSafeArea()
            
            // Subtle ambient blurs for a premium feel
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .fill(gold.opacity(0.05))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .position(x: geo.size.width * 0.8, y: geo.size.height * 0.2)
                    
                    Circle()
                        .fill(navy.opacity(0.03))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .position(x: geo.size.width * 0.1, y: geo.size.height * 0.7)
                }
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Custom Header since we hide the standard one for better control
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.name)
                            .font(.system(size: 34, weight: .bold, design: .serif))
                            .foregroundColor(navy)
                        
                        Text("\(book.chapters.count) capitoli disponibili")
                            .font(.system(size: 16))
                            .foregroundColor(navy.opacity(0.5))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(Array(book.chapters.enumerated()), id: \.element.id) { index, chapter in
                            ChapterButton(
                                book: book,
                                chapter: chapter,
                                index: index,
                                appeared: appeared
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(book.name)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundColor(navy)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

// MARK: - Chapter Button Component

private struct ChapterButton: View {
    let book: BibleBook
    let chapter: BibleChapter
    let index: Int
    let appeared: Bool
    
    @State private var isPressed = false
    
    private let navy = Color(hex: "#1A2B3C")
    private let gold = Color(hex: "#D4AF37")
    
    var body: some View {
        NavigationLink(destination: ReadingView(book: book, chapter: chapter)) {
            ZStack {
                // Glass-like background
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                
                // Border/Outline
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isPressed ? gold.opacity(0.5) : Color.white, lineWidth: 1.5)
                
                VStack(spacing: 2) {
                    Text("\(chapter.number)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(navy)
                    
                    Text("CAP.")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(navy.opacity(0.3))
                }
            }
            .frame(height: 80)
            .scaleEffect(isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PressButtonStyle(isPressed: $isPressed))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        // Staggered animation
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.03), value: appeared)
    }
}

// MARK: - Button Style Helper

private struct PressButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
                if newValue {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}

#Preview {
    NavigationStack {
        ChapterSelectionView(book: BibleDataService.shared.getBooks().first!)
    }
}
