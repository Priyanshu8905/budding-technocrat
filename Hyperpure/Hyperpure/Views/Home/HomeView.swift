import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var isCategoriesSheetPresented = false
    @Environment(CartViewModel.self) private var cartViewModel
    var onNavigateToCategory: ((String) -> Void)?
    var onOpenSmartLists: (() -> Void)?
    var onOpenCart: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 16) {
                        HeaderView(
                            onOpenSmartLists: onOpenSmartLists,
                            onOpenCart: onOpenCart
                        )
                        
                        BannerView()
                        
                        CategoryGridView(categories: viewModel.categories) { categoryId in
                            onNavigateToCategory?(categoryId)
                        }
                        
                        // Rail 1: Chicken & Eggs
                        ProductRailView(
                            categoryName: "Chicken & Eggs",
                            categorySubtitle: "sourced locally",
                            products: MockProducts.products.filter { $0.category == "chicken-eggs" }
                        )
                        
                        // Rail 2: Frozen & Instant Food
                        ProductRailView(
                            categoryName: "Frozen & Instant Food",
                            categorySubtitle: "ready to cook & eat",
                            products: MockProducts.products.filter { $0.category == "frozen" }
                        )
                        
                        // Rail 3: Sauces & Seasoning
                        ProductRailView(
                            categoryName: "Sauces & Seasoning",
                            categorySubtitle: "flavour enhancers",
                            products: MockProducts.products.filter { $0.category == "sauces-seasoning" }
                        )
                        
                        // Rail 4: Canned & Imported Items
                        ProductRailView(
                            categoryName: "Canned & Imported Items",
                            categorySubtitle: "for your gourmet needs",
                            products: MockProducts.products.filter { $0.category == "canned-imported" }
                        )
                        
                        // Rail 5: Packaging Material
                        ProductRailView(
                            categoryName: "Packaging Material",
                            categorySubtitle: "all packaging essentials",
                            products: MockProducts.products.filter { $0.category == "packaging" }
                        )
                        
                        // Rail 6: Bakery & Chocolates
                        ProductRailView(
                            categoryName: "Bakery & Chocolates",
                            categorySubtitle: "bakery & chocolates",
                            products: MockProducts.products.filter { $0.category == "bakery" }
                        )
                    }
                    .padding(.bottom, 80)
                }
                .background(Color(uiColor: .systemGroupedBackground))
                
                // Floating Categories FAB
                Button {
                    isCategoriesSheetPresented = true
                } label: {
                    HStack(spacing: 6) {
                        Text("🥗")
                            .font(.subheadline)
                        Text("Categories")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Theme.navyDark)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isCategoriesSheetPresented) {
                CategoriesSheetView { categoryId in
                    onNavigateToCategory?(categoryId)
                }
                .presentationDetents([.fraction(0.65), .large])
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(CartViewModel())
}
