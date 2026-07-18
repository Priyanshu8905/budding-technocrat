import SwiftUI

struct OrdersView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "bag.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.primary)
                Text("Your Orders")
                    .font(.title2.weight(.bold))
                Text("All your past and active order invoices will appear here.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Orders")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    OrdersView()
}
