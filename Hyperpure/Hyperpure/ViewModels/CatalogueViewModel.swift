import SwiftUI
import Observation

enum SortOption: String, CaseIterable, Identifiable {
    case popular = "Popularity"
    case priceLowToHigh = "Price: Low to High"
    case priceHighToLow = "Price: High to Low"
    case rating = "Customer Rating"
    
    var id: String { rawValue }
}

@Observable
final class CatalogueViewModel {
    var categories: [Category] = MockCategories.categories
    var products: [Product] = MockProducts.products
    var selectedCategoryId: String? = nil
    var searchQuery: String = ""
    var selectedSort: SortOption = .popular
    var isLoading: Bool = false
    
    var allCategories: [Category] { categories }
    
    init(initialCategoryId: String? = nil) {
        self.selectedCategoryId = initialCategoryId
        loadInitialData()
    }
    
    func loadInitialData() {
        self.categories = MockCategories.categories
        self.products = MockProducts.products
    }
    
    func selectCategory(_ categoryId: String?) {
        selectedCategoryId = categoryId
    }
    
    func productCount(for categoryId: String?) -> Int {
        guard let categoryId = categoryId else { return products.count }
        return products.filter { $0.category == categoryId }.count
    }
    
    var filteredProducts: [Product] {
        var result = products
        
        if let catId = selectedCategoryId {
            result = result.filter { $0.category == catId }
        }
        
        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lower = searchQuery.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(lower) ||
                $0.category.lowercased().contains(lower) ||
                $0.description.lowercased().contains(lower)
            }
        }
        
        switch selectedSort {
        case .popular:
            result.sort { $0.isPopular && !$1.isPopular }
        case .priceLowToHigh:
            result.sort { $0.price < $1.price }
        case .priceHighToLow:
            result.sort { $0.price > $1.price }
        case .rating:
            result.sort { $0.rating > $1.rating }
        }
        
        return result
    }
}
