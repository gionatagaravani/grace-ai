import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeDashboardView(selectedTab: $selectedTab)
            }
            Tab("Diario", systemImage: "book.fill", value: 1) {
                JournalView()
            }
            Tab("Bibbia", systemImage: "text.book.closed.fill", value: 2) {
                BibleTabView()
            }
            Tab("Percorso", systemImage: "flame.fill", value: 3) {
                JourneyView()
            }
        }
        .tint(appGold)
    }
}
