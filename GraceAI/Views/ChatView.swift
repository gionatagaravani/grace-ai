import SwiftUI
import SwiftData

struct ChatDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \ChatMessage.timestamp) private var messages: [ChatMessage]
    @State private var aiService = AIService()
    @State private var inputText: String = ""
    @State private var selectedStyle: ConversationStyle = .empathetic
    @State private var showSettings: Bool = false
    @State private var animatedMessageIDs: Set<UUID> = []
    
    var initialPrompt: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            stylePicker
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)

            Divider().opacity(0.3)

            chatContent

            Divider().opacity(0.3)

            inputBar
        }
        .background(colorScheme == .dark ? appNavy : appCream)
        .navigationTitle("Grace AI")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Impostazioni", systemImage: "gearshape") {
                    showSettings = true
                }
                .foregroundStyle(appGold)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            if let prompt = initialPrompt, !prompt.isEmpty {
                inputText = prompt
            }
        }
    }

    private var stylePicker: some View {
        Picker("Stile", selection: $selectedStyle) {
            ForEach(ConversationStyle.allCases, id: \.self) { style in
                Text(style.rawValue).tag(style)
            }
        }
        .pickerStyle(.segmented)
    }

    private var chatContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    if messages.isEmpty {
                        emptyStateView
                            .padding(.top, 60)
                    }

                    ForEach(messages) { message in
                        ChatBubbleView(
                            message: message,
                            isVisible: animatedMessageIDs.contains(message.id)
                        )
                        .id(message.id)
                        .onAppear {
                            if !animatedMessageIDs.contains(message.id) {
                                withAnimation(.easeIn(duration: 0.4)) {
                                    animatedMessageIDs.insert(message.id)
                                }
                            }
                        }
                    }

                    if aiService.isGenerating {
                        TypingIndicatorView()
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: messages.count) { _, _ in
                if let last = messages.last {
                    withAnimation(.smooth) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: aiService.isGenerating) { _, isGenerating in
                if isGenerating {
                    withAnimation(.smooth) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
            .onAppear {
                animatedMessageIDs = Set(messages.map(\.id))
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(appGold)

            Text("Il tuo Mentore Spirituale")
                .font(.system(.title3, design: .serif, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? appCream : appNavy)

            Text("Condividi i tuoi pensieri, le tue domande\no ciò che hai sul cuore.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Scrivi un messaggio...", text: $inputText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white)
                .clipShape(.rect(cornerRadius: 20))

            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.4) : appGold)
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || aiService.isGenerating)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(colorScheme == .dark ? appNavy : appCream)
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let userMessage = ChatMessage(content: text, isFromUser: true, conversationStyle: selectedStyle.rawValue)
        modelContext.insert(userMessage)
        inputText = ""

        Task {
            let response = await aiService.generateChatResponse(for: text, style: selectedStyle)
            let aiMessage = ChatMessage(content: response, isFromUser: false, conversationStyle: selectedStyle.rawValue)
            modelContext.insert(aiMessage)
        }
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    let isVisible: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            if message.isFromUser { Spacer(minLength: 48) }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(message.isFromUser ? .body : .system(.body, design: .serif))
                    .foregroundStyle(message.isFromUser ? .white : (colorScheme == .dark ? appCream : appNavy))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        message.isFromUser
                            ? AnyShapeStyle(appGold.gradient)
                            : AnyShapeStyle(colorScheme == .dark ? Color.white.opacity(0.08) : Color.white)
                    )
                    .clipShape(.rect(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
            }

            if !message.isFromUser { Spacer(minLength: 48) }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
    }
}

struct TypingIndicatorView: View {
    @State private var dotPhase: Int = 0

    var body: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(appGold.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(dotPhase == index ? 1.3 : 0.7)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.15),
                            value: dotPhase
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 20, style: .continuous))

            Spacer()
        }
        .onAppear { dotPhase = 2 }
    }
}
