import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var weatherViewModel = WeatherViewModel()
    @State private var isCategoriesSheetPresented = false
    @State private var isWeatherDetailsPresented = false
    @Environment(CartViewModel.self) private var cartViewModel
    var onNavigateToCategory: ((String) -> Void)?
    var onOpenSmartLists: (() -> Void)?
    var onOpenCart: (() -> Void)?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView(
                        onOpenSmartLists: onOpenSmartLists,
                        onOpenCart: onOpenCart
                    )
                    
                    BannerView()
                    
                    WeatherBannerView(weatherViewModel: weatherViewModel) {
                        isWeatherDetailsPresented = true
                    }
                    
                    CategoryGridView(categories: viewModel.categories) { categoryId in
                        onNavigateToCategory?(categoryId)
                    }
                    
                    // Rail 1: Chicken & Eggs (Screenshot 2)
                    ProductRailView(
                        categoryName: "Chicken & Eggs",
                        categorySubtitle: "sourced locally",
                        products: MockProducts.products.filter { $0.category == "chicken-eggs" }
                    )
                    
                    // Rail 2: Frozen & Instant Food (Screenshot 2)
                    ProductRailView(
                        categoryName: "Frozen & Instant Food",
                        categorySubtitle: "ready to cook & eat",
                        products: MockProducts.products.filter { $0.category == "frozen" }
                    )
                    
                    // Rail 3: Sauces & Seasoning (Screenshot 3)
                    ProductRailView(
                        categoryName: "Sauces & Seasoning",
                        categorySubtitle: "flavour enhancers",
                        products: MockProducts.products.filter { $0.category == "sauces-seasoning" }
                    )
                    
                    // Rail 4: Canned & Imported Items (Screenshot 3)
                    ProductRailView(
                        categoryName: "Canned & Imported Items",
                        categorySubtitle: "for your gourmet needs",
                        products: MockProducts.products.filter { $0.category == "canned-imported" }
                    )
                    
                    // Rail 5: Packaging Material (Screenshot 4)
                    ProductRailView(
                        categoryName: "Packaging Material",
                        categorySubtitle: "all packaging essentials",
                        products: MockProducts.products.filter { $0.category == "packaging" }
                    )
                    
                    // Rail 6: Bakery & Chocolates (Screenshot 4)
                    ProductRailView(
                        categoryName: "Bakery & Chocolates",
                        categorySubtitle: "bakery & chocolates",
                        products: MockProducts.products.filter { $0.category == "bakery" }
                    )
                }
                .padding(.bottom, 80)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            
            // Floating Categories FAB (Opens Categories Modal Sheet - Screenshot 2)
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
        .sheet(isPresented: $isCategoriesSheetPresented) {
            CategoriesSheetView { categoryId in
                onNavigateToCategory?(categoryId)
            }
            .presentationDetents([.fraction(0.65), .large])
        }
        .sheet(isPresented: $isWeatherDetailsPresented) {
            WeatherDetailView(weatherViewModel: weatherViewModel)
        }
    }
}

#Preview {
    HomeView()
        .environment(CartViewModel())
        .environment(AuthViewModel())
}
