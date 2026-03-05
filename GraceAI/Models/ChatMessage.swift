import Foundation
import SwiftData

@Model
class ChatMessage {
    var id: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var conversationStyle: String

    init(content: String, isFromUser: Bool, conversationStyle: String = "Empatico") {
        self.id = UUID()
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.conversationStyle = conversationStyle
    }
}
