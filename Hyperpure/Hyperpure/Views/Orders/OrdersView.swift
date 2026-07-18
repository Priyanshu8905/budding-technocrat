import SwiftUI

struct OrdersView: View {
    @State private var selectedFilter = 0
    var onStartShopping: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Native Segmented Control
                Picker("Orders Filter", selection: $selectedFilter) {
                    Text("Active Orders").tag(0)
                    Text("Past Orders").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Theme.primaryBg)
                            .frame(width: 90, height: 90)
                        Image(systemName: "bag.fill")
                            .font(.system(size: 40))
                            .foregroundColor(Theme.primary)
                    }
                    
                    Text("No Orders Yet")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Your past and active order invoices will appear here.")
                        .font(.subheadline)
                        .foregroundColor(Theme.textMuted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button {
                        onStartShopping?()
                    } label: {
                        Text("Browse Catalogue")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(Theme.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .overlay(
                                Capsule().stroke(Theme.primary, lineWidth: 1.5)
                            )
                    }
                    .padding(.top, 8)
                }
                
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
