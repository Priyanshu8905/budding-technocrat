import SwiftUI

struct HeaderView: View {
    @State private var isExpressSelected: Bool = true
    @State private var searchText: String = ""
    @Environment(CartViewModel.self) private var cartViewModel
    var onOpenSmartLists: (() -> Void)?
    var onOpenCart: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            // Delivery & Outlet Row
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Text("⚡ Delivery in 2 hours")
                        .font(.headline.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(Theme.primary)
                        .font(.caption)
                    Text("Guest Outlet:")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    Text("Delhi, India")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Image(systemName: "chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(Theme.primary)
                }
            }
            .padding(.top, 4)
            
            // Wholesale / Express Toggle (Dark Navy Segmented Control)
            HStack(spacing: 0) {
                Button {
                    isExpressSelected = false
                } label: {
                    Text("Wholesale")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(isExpressSelected ? Theme.textPrimary : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isExpressSelected ? Color.clear : Theme.navyDark)
                        .clipShape(Capsule())
                }
                
                Button {
                    isExpressSelected = true
                } label: {
                    Text("Express")
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(isExpressSelected ? .white : Theme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isExpressSelected ? Theme.navyDark : Color.clear)
                        .clipShape(Capsule())
                }
            }
            .padding(3)
            .background(Color(uiColor: .tertiarySystemGroupedBackground))
            .clipShape(Capsule())
            .padding(.horizontal, 4)
            
            // Search Bar Row with Smart List shortcut & Cart button
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Theme.primary)
                        .font(.body.weight(.bold))
                    
                    TextField("Search 'Clamshell'", text: $searchText)
                        .font(.subheadline)
                    
                    Divider()
                        .frame(height: 20)
                    
                    Button {
                        onOpenSmartLists?()
                    } label: {
                        Image(systemName: "doc.plaintext")
                            .font(.body)
                            .foregroundColor(Theme.primary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                
                // Cart Icon Button
                Button {
                    onOpenCart?()
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        Image(systemName: "cart")
                            .font(.body.weight(.semibold))
                            .foregroundColor(Theme.textPrimary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        if cartViewModel.totalItems > 0 {
                            Text("\(cartViewModel.totalItems)")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Theme.primary)
                                .clipShape(Circle())
                                .offset(x: 4, y: -4)
                        }
                    }
                }
                .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color.white)
    }
}

#Preview {
    HeaderView()
        .environment(CartViewModel())
}
