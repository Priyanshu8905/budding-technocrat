import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var searchText: String = ""
    @State private var weatherViewModel = WeatherIntelligenceViewModel.shared
    @State private var isCategoriesSheetPresented = false
    @Environment(CartViewModel.self) private var cartViewModel
    var onNavigateToCategory: ((String) -> Void)?
    var onOpenSmartLists: (() -> Void)?
    var onOpenCart: (() -> Void)?
    var onOpenAccount: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        VStack(spacing: 18) {
                            HeaderView(
                                onOpenSmartLists: onOpenSmartLists,
                                onOpenCart: onOpenCart
                            )
                            
                            BannerView { categoryId in
                                onNavigateToCategory?(categoryId)
                            }
                            
                            CategoryGridView(
                                categories: viewModel.categories,
                                onOpenAllCategories: {
                                    isCategoriesSheetPresented = true
                                },
                                onSelectCategory: { categoryId in
                                    onNavigateToCategory?(categoryId)
                                }
                            )
                            
                            // Rail 1: Chicken & Eggs
                            ProductRailView(
                                categoryName: "Chicken & Eggs",
                                categorySubtitle: "sourced locally",
                                products: MockProducts.products.filter { $0.category == "chicken-eggs" },
                                onSeeAll: { onNavigateToCategory?("chicken-eggs") }
                            )
                            
                            // Rail 2: Frozen & Instant Food
                            ProductRailView(
                                categoryName: "Frozen & Instant Food",
                                categorySubtitle: "ready to cook & eat",
                                products: MockProducts.products.filter { $0.category == "frozen" },
                                onSeeAll: { onNavigateToCategory?("frozen") }
                            )
                            
                            // Rail 3: Sauces & Seasoning
                            ProductRailView(
                                categoryName: "Sauces & Seasoning",
                                categorySubtitle: "flavour enhancers",
                                products: MockProducts.products.filter { $0.category == "sauces-seasoning" },
                                onSeeAll: { onNavigateToCategory?("sauces-seasoning") }
                            )
                            
                            // Rail 4: Canned & Imported Items
                            ProductRailView(
                                categoryName: "Canned & Imported Items",
                                categorySubtitle: "for your gourmet needs",
                                products: MockProducts.products.filter { $0.category == "canned-imported" },
                                onSeeAll: { onNavigateToCategory?("canned-imported") }
                            )
                            
                            // Rail 5: Packaging Material
                            ProductRailView(
                                categoryName: "Packaging Material",
                                categorySubtitle: "all packaging essentials",
                                products: MockProducts.products.filter { $0.category == "packaging" },
                                onSeeAll: { onNavigateToCategory?("packaging") }
                            )
                            
                            // Rail 6: Bakery & Chocolates
                            ProductRailView(
                                categoryName: "Bakery & Chocolates",
                                categorySubtitle: "bakery & chocolates",
                                products: MockProducts.products.filter { $0.category == "bakery" },
                                onSeeAll: { onNavigateToCategory?("bakery") }
                            )
                        }
                        .padding(.bottom, 24)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                }
            }
            .navigationTitle("Shop")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onOpenAccount?()
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Theme.textPrimary)                       
                    }
                }
            }
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
