import SwiftUI

struct BibleTabView: View {
    @State private var loadedBible: BibleTranslation?
    @State private var selectedTestament: Testament = .old
    @State private var downloadManager = BibleDownloadManager()
    
    // Convert BibleTranslationModels.Book → BibleBook for navigation
    private func toBibleBook(_ book: Book, in bible: BibleTranslation) -> BibleBook {
        BibleBook(
            id: book.name.lowercased().replacingOccurrences(of: " ", with: "-"),
            name: book.name,
            testament: book.number < 40 ? .old : .new,
            chapters: book.chapters.map { ch in
                BibleChapter(
                    bookId: book.name.lowercased(),
                    number: ch.number,
                    verses: ch.verses.map { v in
                        BibleVerse(
                            chapterId: "\(book.name.lowercased())-\(ch.number)",
                            number: v.number,
                            text: v.text
                        )
                    }
                )
            }
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F9F9F7").ignoresSafeArea()
                
                if let bible = loadedBible {
                    // ── Bible is loaded: show book list ────────────
                    VStack(spacing: 0) {
                        CustomSegmentedControl(selectedItem: $selectedTestament)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(.bottom, 16)
                        
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(bible.books.enumerated()), id: \.element.id) { i, book in
                                    let isOld = i < 39
                                    let show  = (selectedTestament == .old && isOld) || (selectedTestament == .new && !isOld)
                                    if show {
                                        let converted = toBibleBook(book, in: bible)
                                        NavigationLink(destination: ChapterSelectionView(book: converted)) {
                                            BibleBookRow(book: converted)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    // ── No Bible yet: full-screen welcome ──────────
                    BibleWelcomeView(loadedBible: $loadedBible)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
            }
            .navigationTitle(loadedBible == nil ? "" : "La Bibbia")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color(hex: "#F9F9F7"), for: .navigationBar)
            .toolbar {
                if loadedBible != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: TranslationsView()) {
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(Color(hex: "#1A2B3C"))
                        }
                    }
                }
            }
        }
        .tint(Color(hex: "#1A2B3C"))
        .animation(.easeInOut(duration: 0.5), value: loadedBible == nil)
        .task {
            if loadedBible == nil {
                autoLoadLocalBible()
            }
        }
    }
    
    private func autoLoadLocalBible() {
        // 1. Try last used translation
        if let lastId = UserDefaults.standard.string(forKey: "lastUsedBibleId") {
            if let bible = try? downloadManager.loadLocalBible(translationID: lastId) {
                print("Auto-loaded last used Bible: \(lastId)")
                self.loadedBible = bible
                return
            }
        }
        
        // 2. Try any downloaded translation from sync list
        if let downloadedIds = UserDefaults.standard.stringArray(forKey: "downloadedBibleIds") {
            for id in downloadedIds {
                if let bible = try? downloadManager.loadLocalBible(translationID: id) {
                    print("Auto-loaded available Bible from sync: \(id)")
                    self.loadedBible = bible
                    UserDefaults.standard.set(id, forKey: "lastUsedBibleId")
                    return
                }
            }
        }
        
        // 3. Last resort: check common IDs locally (fallback if sync list fails)
        let commonIds = ["kjv", "diodati", "asv"]
        for id in commonIds {
            if let bible = try? downloadManager.loadLocalBible(translationID: id) {
                print("Auto-loaded common Bible fallback: \(id)")
                self.loadedBible = bible
                UserDefaults.standard.set(id, forKey: "lastUsedBibleId")
                return
            }
        }
    }
}

// MARK: - Segmented Control (unchanged)

struct CustomSegmentedControl: View {
    @Binding var selectedItem: Testament
    
    let options: [Testament] = [.old, .new]
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedItem = option
                    }
                } label: {
                    Text(option.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundColor(selectedItem == option
                                         ? Color(hex: "#F9F9F7")
                                         : Color(hex: "#1A2B3C").opacity(0.6))
                        .background {
                            if selectedItem == option {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "#1A2B3C"))
                                    .matchedGeometryEffect(id: "Tab", in: namespace)
                            }
                        }
                }
            }
        }
        .padding(4)
        .background(Color(hex: "#1A2B3C").opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Book Row (unchanged)

struct BibleBookRow: View {
    let book: BibleBook
    
    var body: some View {
        HStack {
            Text(book.name)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "#1A2B3C"))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "#D4AF37"))
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
