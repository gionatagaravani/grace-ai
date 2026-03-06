import Foundation

enum Testament: String, Codable {
    case old = "Antico Testamento"
    case new = "Nuovo Testamento"
}

struct BibleVerse: Identifiable, Codable, Hashable {
    var id: String { "\(chapterId):\(number)" }
    let chapterId: String
    let number: Int
    let text: String
}

struct BibleChapter: Identifiable, Codable, Hashable {
    var id: String { "\(bookId)-\(number)" }
    let bookId: String
    let number: Int
    let verses: [BibleVerse]
}

struct BibleBook: Identifiable, Codable, Hashable {
    let id: String // e.g., "genesis", "matthew"
    let name: String
    let testament: Testament
    let chapters: [BibleChapter]
}
