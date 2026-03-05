import SwiftUI

struct PaywallTrustElementsView: View {
    let onRestore: () -> Void
    let onTerms: () -> Void
    let onPrivacy: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: onRestore) {
                Text("Restore Purchases")
            }
            
            Text("•")
            
            Button(action: onTerms) {
                Text("Terms of Service")
            }
            
            Text("•")
            
            Button(action: onPrivacy) {
                Text("Privacy Policy")
            }
        }
        .font(.system(size: 10))
        .foregroundColor(.gray)
        .padding(.bottom, 8)
    }
}

#Preview {
    ZStack {
        Color.paywallOffWhite.ignoresSafeArea()
        PaywallTrustElementsView(onRestore: {}, onTerms: {}, onPrivacy: {})
    }
}
