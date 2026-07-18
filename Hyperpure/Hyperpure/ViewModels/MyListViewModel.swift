// MyListViewModel.swift
// ViewModel managing the user's custom favorite items list.

import Foundation
import Observation

@MainActor
@Observable
final class MyListViewModel {
    static let shared = MyListViewModel()
    
    private(set) var items: [Product] = []
    
    /// Becomes true when a new item is added; cleared when the user visits My List tab.
    var hasNewItems: Bool = false
    
    init() {
        // Pre-populate with a few popular products from mock data
        let allProducts = MockProducts.products
        if allProducts.count >= 15 {
            items = [
                allProducts[0],  // Eggs
                allProducts[1],  // Chicken Breast
                allProducts[3]   // McCain French Fries
            ]
        }
        // Don't flag pre-populated items as "new"
    }
    
    func isFavorite(_ product: Product) -> Bool {
        items.contains(where: { $0.id == product.id })
    }
    
    func toggleFavorite(_ product: Product) {
        if isFavorite(product) {
            removeFavorite(product)
        } else {
            addFavorite(product)
        }
    }
    
    func addFavorite(_ product: Product) {
        if !isFavorite(product) {
            items.append(product)
            hasNewItems = true
        }
    }
    
    func removeFavorite(_ product: Product) {
        items.removeAll(where: { $0.id == product.id })
    }
    
    /// Call when the user views the My List tab to dismiss the "NEW" badge.
    func markAsSeen() {
        hasNewItems = false
    }
}
