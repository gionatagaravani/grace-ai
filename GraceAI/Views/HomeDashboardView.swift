import SwiftUI

struct HomeDashboardView: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("userName") private var userName: String = "Amico"
    @AppStorage("currentStreak") private var currentStreak: Int = 3
    @State private var showSettings: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerArea
                    heroCard
                    verseOfTheDay
                    exploreByTopic
                }
                .padding(.vertical, 20)
            }
            .background(colorScheme == .dark ? appNavy : appCream)
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
    
    private var headerArea: some View {
        HStack {
            Text("Buongiorno, \(userName)")
                .font(.system(.title2, design: .serif, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? appCream : appNavy)
            
            Spacer()
            
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                showSettings = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.white)
                        .font(.caption)
                    Text("\(currentStreak) Giorni")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(appGold)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("La tua Azione Quotidiana")
                .font(.system(.title3, design: .serif, weight: .bold))
                .foregroundStyle(appNavy)
            
            Text("Prenditi 2 minuti per coltivare la tua gratitudine oggi.")
                .font(.subheadline)
                .foregroundStyle(appNavy.opacity(0.8))
            
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                selectedTab = 1 // Switch to Diary
            } label: {
                Text("Scrivi nel Diario")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(appNavy)
                    .foregroundStyle(appCream)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [appGold.opacity(0.3), appCream],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    private var verseOfTheDay: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Verso del Giorno")
                .font(.caption.weight(.bold))
                .foregroundStyle(appGold)
                .textCase(.uppercase)
            
            Text("\"Non temere, perché io sono con te; non ti smarrire, perché io sono il tuo Dio; io ti fortifico, io ti soccorro, io ti sostengo con la destra della mia giustizia.\"\n- Isaia 41:10")
                .font(.system(.body, design: .serif, weight: .medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
            
            Button {
                let impactLight = UIImpactFeedbackGenerator(style: .light)
                impactLight.impactOccurred()
                // Action is handled by NavigationLink but we can wrap it if needed or use simultaneousGesture
            } label: {
                NavigationLink {
                    ChatDetailView(initialPrompt: "Ho letto Isaia 41:10 oggi. Puoi aiutarmi a riflettere su questo versetto?")
                } label: {
                    HStack {
                        Text("✨ Discuti con l'AI")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.bold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.15))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
        }
        .padding(24)
        .background(
            appNavy
                .opacity(0.95)
        )
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    private var exploreByTopic: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Esplora la Parola")
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundStyle(colorScheme == .dark ? appCream : appNavy)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    topicCard(title: "Gestire l'Ansia", icon: "wind", prompt: "Vorrei uno studio ed una riflessione su come gestire l'ansia attraverso la Bibbia.", delay: 0)
                    topicCard(title: "Trovare la Pace", icon: "leaf.fill", prompt: "Vorrei esplorare il tema del trovare la pace interiore secondo le scritture.", delay: 0.1)
                    topicCard(title: "Leadership", icon: "star.fill", prompt: "Quali sono i principi di leadership che possiamo imparare dalla Bibbia?", delay: 0.2)
                    topicCard(title: "Perdono", icon: "heart.fill", prompt: "Aiutami a comprendere e praticare il perdono secondo gli insegnamenti biblici.", delay: 0.3)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func topicCard(title: String, icon: String, prompt: String, delay: Double) -> some View {
        Button {
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
        } label: {
            NavigationLink {
                ChatDetailView(initialPrompt: prompt)
            } label: {
                VStack(alignment: .leading, spacing: 12) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(appGold)
                    
                    Spacer()
                    
                    Text(title)
                        .font(.system(.headline, design: .serif, weight: .semibold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding(20)
                .frame(width: 150, height: 160, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(appNavy)
                )
                .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.05), radius: 10, x: 0, y: 5)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
