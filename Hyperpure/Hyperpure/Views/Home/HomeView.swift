import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var searchText: String = ""
    @State private var weatherViewModel = WeatherIntelligenceViewModel.shared
    @State private var isCategoriesSheetPresented = false
    @Environment(CartViewModel.self) private var cartViewModel
    @Query private var pantryItems: [PantryItem]
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
                            
                            weatherIntelligenceCard
                            
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

    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
    
    // MARK: - Weather Intelligence Card
    
    private var weatherCardColor: Color {
        switch weatherViewModel.currentState {
        case .normal: return Color.green
        case .monsoon: return Color.blue
        case .heatwave: return Color.orange
        case .winterCold: return Color.cyan
        }
    }
    
    private var weatherIconName: String {
        switch weatherViewModel.currentState {
        case .normal: return "sun.max.fill"
        case .monsoon: return "cloud.rain.fill"
        case .heatwave: return "thermometer.sun.fill"
        case .winterCold: return "snowflake"
        }
    }
    
    private var weatherDescription: String {
        switch weatherViewModel.currentState {
        case .normal:
            return "Weather is stable. Standard replenishment recommended."
        case .monsoon:
            return "Monsoon warning active. Warm comfort foods are recommended."
        case .heatwave:
            return "Extreme heat active. Spoilage risk is high, cooling items recommended."
        case .winterCold:
            return "Cold wave active. Warm beverages and comfort foods recommended."
        }
    }
    
    private func isProductInStockInPantry(_ product: Product) -> Bool {
        pantryItems.contains { item in
            let itemName = item.name.lowercased()
            let prodName = product.name.lowercased()
            let isMatch = itemName.contains(prodName) || prodName.contains(itemName)
            return isMatch && item.calculatedQuantity > 0 && item.status != "Critical"
        }
    }
    
    private var productsToSuggest: [Product] {
        let weatherState = weatherViewModel.currentState
        let weatherSuggestedProducts: [Product]
        switch weatherState {
        case .normal:
            weatherSuggestedProducts = MockProducts.products.filter { [1, 301, 402].contains($0.id) }
        case .monsoon:
            weatherSuggestedProducts = MockProducts.products.filter { [11, 12, 13].contains($0.id) }
        case .heatwave:
            weatherSuggestedProducts = MockProducts.products.filter { [102, 402, 203].contains($0.id) }
        case .winterCold:
            weatherSuggestedProducts = MockProducts.products.filter { [801, 401, 11].contains($0.id) }
        }
        
        return weatherSuggestedProducts.filter { !isProductInStockInPantry($0) }
    }
    
    @ViewBuilder
    private var weatherIntelligenceCard: some View {
        let suggested = productsToSuggest
        if suggested.isEmpty {
            EmptyView()
        } else {
            NavigationLink(destination: WeatherIntelligenceView()) {
                HStack(spacing: 12) {
                    Image(systemName: weatherIconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [weatherCardColor, weatherCardColor.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: weatherCardColor.opacity(0.2), radius: 3, x: 0, y: 1.5)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text("\(weatherViewModel.currentState.rawValue) · \(Int(weatherViewModel.temperature))°C")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("ALERT")
                                .font(.system(size: 8, weight: .black))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(Theme.primary.opacity(0.12))
                                .foregroundColor(Theme.primary)
                                .clipShape(Capsule())
                        }
                        
                        Text("\(suggested.count) suggested restock item\(suggested.count > 1 ? "s" : "") missing in pantry based on current weather condition.")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.textMuted)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.95))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [weatherCardColor.opacity(0.3), weatherCardColor.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 16)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    HomeView()
        .environment(CartViewModel())
}
