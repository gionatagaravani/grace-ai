import SwiftUI

struct ChapterSelectionView: View {
    let book: BibleBook
    
    let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color(hex: "#F9F9F7") // Cream background
                .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(book.chapters) { chapter in
                        NavigationLink(destination: ReadingView(book: book, chapter: chapter)) {
                            Text("\(chapter.number)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "#D4AF37")) // Gold text
                                .frame(width: 60, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(hex: "#1A2B3C")) // Navy background
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
        .navigationTitle(book.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView {
        ChapterSelectionView(book: BibleDataService.shared.getBooks().first!)
    }
}
