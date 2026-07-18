import SwiftUI

struct HeaderView: View {
    @State private var isExpressSelected: Bool = true
    @State private var searchText: String = ""
    @Environment(CartViewModel.self) private var cartViewModel
    var onOpenSmartLists: (() -> Void)?
    var onOpenCart: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Liquid Glass Search Bar Pill (with embedded Cart & Smart List icons)
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .semibold))
                
                TextField("Search 'Clamshell' or items...", text: $searchText)
                    .font(.subheadline)
                    .autocorrectionDisabled()
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.textMuted)
                            .font(.system(size: 15))
                    }
                }
                
                Divider()
                    .frame(height: 20)
                    .padding(.horizontal, 2)
                
                // Embedded Action Icons: Cart & Smart List (Matching Screenshot)
                HStack(spacing: 14) {
                    // Cart Icon Button with Badge
                    Button {
                        onOpenCart?()
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.black)
                            
                            if cartViewModel.totalItems > 0 {
                                Text("\(cartViewModel.totalItems)")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(3)
                                    .background(Theme.primary)
                                    .clipShape(Circle())
                                    .offset(x: 7, y: -6)
                            }
                        }
                    }
                    
                    // Smart List Icon Button
                    Button {
                        onOpenSmartLists?()
                    } label: {
                        Image(systemName: "doc.plaintext")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.black)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.regularMaterial)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
            )
            .overlay(
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.8), .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    HeaderView()
        .environment(CartViewModel())
}
