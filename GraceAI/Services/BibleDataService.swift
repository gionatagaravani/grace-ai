import Foundation

class BibleDataService {
    static let shared = BibleDataService()
    
    private init() {}
    
    func getBooks() -> [BibleBook] {
        return [
            BibleBook(
                id: "genesis",
                name: "Genesi",
                testament: .old,
                chapters: [
                    BibleChapter(
                        bookId: "genesis",
                        number: 1,
                        verses: [
                            BibleVerse(chapterId: "genesis-1", number: 1, text: "Nel principio Dio creò i cieli e la terra."),
                            BibleVerse(chapterId: "genesis-1", number: 2, text: "La terra era informe e vuota, le tenebre coprivano la faccia dell'abisso e lo Spirito di Dio aleggiava sulla superficie delle acque."),
                            BibleVerse(chapterId: "genesis-1", number: 3, text: "Dio disse: «Sia luce!» E luce fu."),
                            BibleVerse(chapterId: "genesis-1", number: 4, text: "Dio vide che la luce era buona; e Dio separò la luce dalle tenebre."),
                            BibleVerse(chapterId: "genesis-1", number: 5, text: "Dio chiamò la luce «giorno» e le tenebre «notte». Fu sera, poi fu mattina: primo giorno.")
                        ]
                    ),
                    BibleChapter(
                        bookId: "genesis",
                        number: 2,
                        verses: [
                            BibleVerse(chapterId: "genesis-2", number: 1, text: "Così furono compiuti i cieli e la terra e tutto l'esercito loro."),
                            BibleVerse(chapterId: "genesis-2", number: 2, text: "Il settimo giorno, Dio compì l'opera che aveva fatta, e si riposò il settimo giorno da tutta l'opera che aveva fatta."),
                            BibleVerse(chapterId: "genesis-2", number: 3, text: "Dio benedisse il settimo giorno e lo santificò, perché in esso si riposò da tutta l'opera che aveva creata e fatta.")
                        ]
                    )
                ]
            ),
            BibleBook(
                id: "matthew",
                name: "Matteo",
                testament: .new,
                chapters: [
                    BibleChapter(
                        bookId: "matthew",
                        number: 1,
                        verses: [
                            BibleVerse(chapterId: "matthew-1", number: 1, text: "Genealogia di Gesù Cristo, figlio di Davide, figlio di Abraamo."),
                            BibleVerse(chapterId: "matthew-1", number: 2, text: "Abraamo generò Isacco; Isacco generò Giacobbe; Giacobbe generò Giuda e i suoi fratelli;"),
                            BibleVerse(chapterId: "matthew-1", number: 3, text: "Giuda generò Fares e Zara da Tamar; Fares generò Esrom; Esrom generò Aram;")
                        ]
                    ),
                    BibleChapter(
                        bookId: "matthew",
                        number: 2,
                        verses: [
                            BibleVerse(chapterId: "matthew-2", number: 1, text: "Gesù era nato in Betlemme di Giudea, all'epoca del re Erode. Dei magi d'Oriente arrivarono a Gerusalemme, dicendo:"),
                            BibleVerse(chapterId: "matthew-2", number: 2, text: "«Dov'è il re dei Giudei che è nato? Poiché noi abbiamo visto la sua stella in Oriente e siamo venuti per adorarlo».")
                        ]
                    )
                ]
            )
        ]
    }
}
