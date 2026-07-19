// CatalogueViewModel.swift
// ViewModel managing the product catalog and categories using SwiftData.

import SwiftUI
import Observation
import SwiftData

public enum SortOption: String, CaseIterable, Identifiable {
    case popular = "Popularity"
    case priceLowToHigh = "Price: Low to High"
    case priceHighToLow = "Price: High to Low"
    case rating = "Customer Rating"
    
    public var id: String { rawValue }
}

@MainActor
@Observable
public final class CatalogueViewModel {
    public static let shared = CatalogueViewModel()
    
    public var selectedCategoryId: String? = nil
    public var searchQuery: String = ""
    public var selectedSort: SortOption = .popular
    public var isLoading: Bool = false
    
    public init(initialCategoryId: String? = nil) {
        self.selectedCategoryId = initialCategoryId
    }
    
    public var allCategories: [Category] {
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        return (try? Database.shared.context.fetch(descriptor)) ?? []
    }
    
    public func selectCategory(_ categoryId: String?) {
        selectedCategoryId = categoryId
    }
    
    public func productCount(for categoryId: String?) -> Int {
        let descriptor = FetchDescriptor<Product>()
        guard let allProds = try? Database.shared.context.fetch(descriptor) else { return 0 }
        guard let categoryId = categoryId else { return allProds.count }
        return allProds.filter { $0.category == categoryId }.count
    }
    
    public var filteredProducts: [Product] {
        let descriptor = FetchDescriptor<Product>()
        guard var result = try? Database.shared.context.fetch(descriptor) else { return [] }
        
        if let catId = selectedCategoryId {
            result = result.filter { $0.category == catId }
        }
        
        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let lower = searchQuery.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(lower) ||
                $0.category.lowercased().contains(lower) ||
                $0.productDescription.lowercased().contains(lower)
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
