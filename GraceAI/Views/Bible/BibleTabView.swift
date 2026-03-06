import SwiftUI

struct BibleTabView: View {
    @State private var selectedTestament: Testament = .new
    @State private var books: [BibleBook] = BibleDataService.shared.getBooks()
    
    var filteredBooks: [BibleBook] {
        books.filter { $0.testament == selectedTestament }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F9F9F7") // Cream background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Segmented Control
                    CustomSegmentedControl(selectedItem: $selectedTestament)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, 16)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredBooks) { book in
                                NavigationLink(destination: ChapterSelectionView(book: book)) {
                                    BibleBookRow(book: book)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("La Bibbia")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(hex: "#F9F9F7"), for: .navigationBar)
        }
        .tint(Color(hex: "#1A2B3C")) // Navy tint for NavigationLink backs
    }
}

struct CustomSegmentedControl: View {
    @Binding var selectedItem: Testament
    
    let options: [Testament] = [.old, .new]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedItem = option
                    }
                }) {
                    Text(option.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundColor(selectedItem == option ? Color(hex: "#F9F9F7") : Color(hex: "#1A2B3C").opacity(0.6))
                        .background(
                            ZStack {
                                if selectedItem == option {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(hex: "#1A2B3C")) // Navy selected background
                                        .matchedGeometryEffect(id: "Tab", in: namespace)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(Color(hex: "#1A2B3C").opacity(0.05))
        .cornerRadius(16)
    }
    
    @Namespace private var namespace
}

struct BibleBookRow: View {
    let book: BibleBook
    
    var body: some View {
        HStack {
            Text(book.name)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "#1A2B3C")) // Navy text
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "#D4AF37")) // Gold accent
                .font(.system(size: 14, weight: .bold))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    BibleTabView()
}
