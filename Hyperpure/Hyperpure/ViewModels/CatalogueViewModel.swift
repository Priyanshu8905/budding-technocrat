import Foundation
import Observation

enum SortOption: String, CaseIterable, Identifiable {
    case relevance = "Relevance"
    case priceLowToHigh = "Price: Low to High"
    case priceHighToLow = "Price: High to Low"
    case discount = "Highest Discount"
    
    var id: String { rawValue }
}

@Observable
final class CatalogueViewModel {
    var selectedCategoryId: String? = nil
    var searchQuery: String = ""
    var selectedSort: SortOption = .relevance
    
    private(set) var allProducts: [Product] = MockProducts.products
    private(set) var allCategories: [Category] = MockCategories.categories
    
    var filteredProducts: [Product] {
        var results = allProducts
        
        if let categoryId = selectedCategoryId {
            results = results.filter { $0.category == categoryId }
        }
        
        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let q = searchQuery.lowercased()
            results = results.filter {
                $0.name.lowercased().contains(q) ||
                $0.subcategory.lowercased().contains(q) ||
                $0.description.lowercased().contains(q)
            }
        }
        
        switch selectedSort {
        case .relevance:
            return results
        case .priceLowToHigh:
            return results.sorted { $0.price < $1.price }
        case .priceHighToLow:
            return results.sorted { $0.price > $1.price }
        case .discount:
            return results.sorted { $0.discountPercent > $1.discountPercent }
        }
    }
    
    func productCount(for categoryId: String?) -> Int {
        guard let categoryId = categoryId else { return allProducts.count }
        return allProducts.filter { $0.category == categoryId }.count
    }
    
    func selectCategory(_ id: String?) {
        selectedCategoryId = id
    }
}
