import Foundation

@Observable
@MainActor
class AIService {
    var isGenerating = false

    private let biblicalReflections: [String] = [
        "\"Rendete grazie al Signore, perché egli è buono, perché la sua misericordia dura in eterno.\" — Salmo 136:1\n\nLa tua gratitudine riflette un cuore che riconosce la bontà di Dio nelle piccole cose. Continua a coltivare questo sguardo di meraviglia.",
        "\"Ogni buon regalo e ogni dono perfetto viene dall'alto.\" — Giacomo 1:17\n\nQuello che hai condiviso è un dono prezioso. Dio intreccia benedizioni nella trama ordinaria dei nostri giorni.",
        "\"Il Signore è il mio pastore, non mancherò di nulla.\" — Salmo 23:1\n\nNella tua esperienza si vede la mano del Pastore che provvede. Anche nei dettagli, Lui è presente.",
        "\"Siate sempre gioiosi, pregate senza cessare, in ogni cosa rendete grazie.\" — 1 Tessalonicesi 5:16-18\n\nLa gratitudine che esprimi è una preghiera vivente. Ogni momento di riconoscenza apre il cuore alla gioia.",
        "\"Io sono con voi tutti i giorni, fino alla fine del mondo.\" — Matteo 28:20\n\nCiò che hai vissuto mostra che non sei mai solo. La Sua presenza si manifesta attraverso le persone e i momenti che apprezzi.",
        "\"Tutte le cose cooperano al bene di coloro che amano Dio.\" — Romani 8:28\n\nLa tua riflessione rivela come Dio trasformi anche l'ordinario in straordinario. Fidati del Suo disegno.",
        "\"Il Signore ti benedica e ti custodisca.\" — Numeri 6:24\n\nOgni momento di gratitudine è un segno della Sua benedizione. Custodisci questi ricordi nel cuore.",
        "\"Non temere, perché io sono con te.\" — Isaia 41:10\n\nLa tua esperienza ci ricorda che la gratitudine fiorisce anche quando scegliamo di vedere la luce nel quotidiano.",
        "\"L'amore è paziente, l'amore è benigno.\" — 1 Corinzi 13:4\n\nCiò per cui sei grato riflette l'amore di Dio in azione. Riconoscerlo è il primo passo verso una vita piena.",
        "\"Cercate il Signore e la sua forza, cercate sempre il suo volto.\" — Salmo 105:4\n\nNella tua gratitudine c'è una ricerca silenziosa del volto di Dio. Continua a cercarlo in ogni momento.",
    ]

    private let chatResponses: [String: [String]] = [
        "Empatico": [
            "Capisco quello che senti, e voglio che tu sappia che non sei solo in questo. La Bibbia ci ricorda: \"Getta sul Signore il tuo peso ed egli ti sosterrà\" (Salmo 55:22). Qualunque cosa tu stia attraversando, c'è uno spazio sicuro nella preghiera dove puoi portare tutto.",
            "Grazie per aver condiviso questo con me. Il tuo cuore è prezioso agli occhi di Dio. Come dice il Salmo 34:18: \"Il Signore è vicino a chi ha il cuore spezzato.\" Prenditi il tempo di cui hai bisogno per elaborare ciò che senti.",
            "Quello che condividi tocca il cuore. Ricorda che \"quelli che sperano nel Signore acquistano nuove forze\" (Isaia 40:31). La tua vulnerabilità è una forma di coraggio.",
            "Ti ascolto con tutto il cuore. Le tue emozioni sono valide e importanti. Come Maria custodiva le cose nel suo cuore (Luca 2:19), anche tu puoi prenderti questo spazio di riflessione.",
            "C'è tanta bellezza nella tua onestà. \"La verità vi farà liberi\" (Giovanni 8:32) — e questo include essere onesti con noi stessi e con Dio su come ci sentiamo.",
        ],
        "Teologico": [
            "La tua domanda tocca un tema profondo della teologia cristiana. Sant'Agostino scriveva che \"il nostro cuore è inquieto finché non riposa in Te.\" La Scrittura ci invita a cercare la sapienza come un tesoro nascosto (Proverbi 2:4-5).",
            "Questo tema è al centro del messaggio evangelico. San Paolo ci ricorda che \"per grazia siete stati salvati, mediante la fede\" (Efesini 2:8). La grazia non è qualcosa che guadagniamo, ma un dono che accogliamo.",
            "La tradizione cristiana ha sempre riflettuto su questo. San Tommaso d'Aquino insegnava che la fede e la ragione sono complementari. Come dice il Salmo 111:10: \"Il timore del Signore è il principio della sapienza.\"",
            "Nella Lettera ai Romani, Paolo esplora questa tensione con grande profondità. \"La speranza non delude, perché l'amore di Dio è stato riversato nei nostri cuori\" (Romani 5:5). Questo amore è il fondamento di ogni riflessione teologica.",
            "I Padri della Chiesa ci insegnano che la contemplazione è il cuore della vita spirituale. \"Fermatevi e sappiate che io sono Dio\" (Salmo 46:10) non è solo un invito alla quiete, ma alla conoscenza profonda.",
        ],
        "Motivazionale": [
            "Sei stato creato per qualcosa di straordinario! \"Io conosco i pensieri che ho per voi, dice il Signore: pensieri di pace e non di male\" (Geremia 29:11). Dio ha un piano meraviglioso per la tua vita — non arrenderti!",
            "Oggi è un nuovo giorno pieno di possibilità! Come Giosuè, che sentì: \"Sii forte e coraggioso\" (Giosuè 1:9), anche tu hai dentro una forza che viene dall'alto. Alzati e cammina nella fiducia!",
            "Non dimenticare mai chi sei agli occhi di Dio! \"Tu sei prezioso ai miei occhi\" (Isaia 43:4). Ogni sfida è un'opportunità per crescere nella fede e nella forza interiore.",
            "Ricorda: i giganti di oggi sono le vittorie di domani! Davide affrontò Golia con una fionda e la fede in Dio (1 Samuele 17). Anche tu hai tutto ciò che serve per vincere le tue battaglie.",
            "La tua storia non è finita — il meglio deve ancora venire! \"Chi ha cominciato in voi un'opera buona, la condurrà a compimento\" (Filippesi 1:6). Continua a camminare con coraggio!",
        ],
    ]

    func generateReflection(for gratitudeText: String) async -> String {
        isGenerating = true
        defer { isGenerating = false }

        try? await Task.sleep(for: .seconds(Double.random(in: 1.5...2.5)))
        return biblicalReflections.randomElement() ?? biblicalReflections[0]
    }

    func generateChatResponse(for message: String, style: ConversationStyle) async -> String {
        isGenerating = true
        defer { isGenerating = false }

        try? await Task.sleep(for: .seconds(Double.random(in: 1.0...2.0)))
        let responses = chatResponses[style.rawValue] ?? chatResponses["Empatico"]!
        return responses.randomElement() ?? responses[0]
    }
}
