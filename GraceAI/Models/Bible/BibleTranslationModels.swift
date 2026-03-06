import Foundation

/// Represents a translation available for download
struct BibleTranslationMeta: Identifiable, Codable {
    let id: String         // e.g. "asv"
    let name: String       // e.g. "American Standard Version"
    let url: URL           // The download URL
}


// MARK: - API Response Models (Parsing the flat JSON)

struct BibleTranslationResponse: Codable {
    let metadata: BibleMetadata
    let verses: [VerseRecord]
}

struct BibleMetadata: Codable {
    let name: String
    let shortname: String
    let module: String
    let year: String?
    let publisher: String?
    let owner: String?
    let description: String?
    let lang: String?
    let langShort: String?
    let copyright: Int?
    let copyrightStatement: String?
    let url: String?
    let citationLimit: Int?
    let restrict: Int?
    let italics: Int?
    let strongs: Int?
    let redLetter: Int?
    let paragraph: Int?
    let official: Int?
    let research: Int?
    let moduleVersion: String?
    
    enum CodingKeys: String, CodingKey {
        case name, shortname, module, year, publisher, owner, description, lang
        case langShort = "lang_short"
        case copyright
        case copyrightStatement = "copyright_statement"
        case url
        case citationLimit = "citation_limit"
        case restrict, italics, strongs
        case redLetter = "red_letter"
        case paragraph, official, research
        case moduleVersion = "module_version"
    }
}

struct VerseRecord: Codable {
    let bookName: String
    let book: Int
    let chapter: Int
    let verse: Int
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case bookName = "book_name"
        case book, chapter, verse, text
    }
}

// MARK: - App Models (Structured UI Hierarchy)

struct BibleTranslation: Identifiable {
    var id: String { metadata.module }
    let metadata: BibleMetadata
    let books: [Book]
}

struct Book: Identifiable {
    var id: Int { number }
    let name: String
    let number: Int
    let chapters: [Chapter]
}

struct Chapter: Identifiable {
    var id: Int { number }
    let number: Int
    let verses: [Verse]
}

struct Verse: Identifiable {
    var id: Int { number }
    let number: Int
    let text: String
}

// MARK: - Conversion Logic

extension BibleTranslationResponse {
    /// Converts the flat array of `VerseRecord` into a nested hierarchical structure (Books -> Chapters -> Verses)
    func toAppModel() -> BibleTranslation {
        var bookDict = [Int: [Int: [Verse]]]()
        var bookNames = [Int: String]()
        
        for record in verses {
            bookNames[record.book] = record.bookName
            
            if bookDict[record.book] == nil {
                bookDict[record.book] = [:]
            }
            if bookDict[record.book]?[record.chapter] == nil {
                bookDict[record.book]?[record.chapter] = []
            }
            
            let verse = Verse(number: record.verse, text: record.text)
            bookDict[record.book]?[record.chapter]?.append(verse)
        }
        
        var books = [Book]()
        for bookNum in bookDict.keys.sorted() {
            guard let chapterDict = bookDict[bookNum], let bName = bookNames[bookNum] else { continue }
            var chapters = [Chapter]()
            
            for chapNum in chapterDict.keys.sorted() {
                guard let versesList = chapterDict[chapNum] else { continue }
                chapters.append(Chapter(
                    number: chapNum,
                    verses: versesList.sorted(by: { $0.number < $1.number })
                ))
            }
            
            books.append(Book(name: bName, number: bookNum, chapters: chapters))
        }
        
        return BibleTranslation(metadata: metadata, books: books)
    }
}
