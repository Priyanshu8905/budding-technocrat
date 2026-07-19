// MyListViewModel.swift
// ViewModel managing the user's custom favorite items list using SwiftData.

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
public final class MyListViewModel {
    public static let shared = MyListViewModel()
    
    public private(set) var items: [Product] = []
    public var hasNewItems: Bool = false
    
    private init() {
        fetchFavorites()
        if items.isEmpty {
            seedInitialFavorites()
        }
    }
    
    public func fetchFavorites() {
        let descriptor = FetchDescriptor<SavedListItem>(sortBy: [SortDescriptor(\.savedAt, order: .reverse)])
        let savedItems = (try? Database.shared.context.fetch(descriptor)) ?? []
        self.items = savedItems.compactMap { $0.product }
    }
    
    public func isFavorite(_ product: Product) -> Bool {
        items.contains(where: { $0.id == product.id })
    }
    
    public func toggleFavorite(_ product: Product) {
        if isFavorite(product) {
            removeFavorite(product)
        } else {
            addFavorite(product)
        }
    }
    
    public func addFavorite(_ product: Product) {
        let context = Database.shared.context
        if !isFavorite(product) {
            let productId = product.id
            let prodDescriptor = FetchDescriptor<Product>(predicate: #Predicate { $0.id == productId })
            let dbProduct = (try? context.fetch(prodDescriptor))?.first ?? product
            
            let newItem = SavedListItem(product: dbProduct)
            context.insert(newItem)
            try? context.save()
            fetchFavorites()
            hasNewItems = true
        }
    }
    
    public func removeFavorite(_ product: Product) {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<SavedListItem>()
        if let savedItems = try? context.fetch(descriptor),
           let target = savedItems.first(where: { $0.product?.id == product.id }) {
            context.delete(target)
            try? context.save()
            fetchFavorites()
        }
    }
    
    public func createSmartListFromLastOrder() {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<Order>(sortBy: [SortDescriptor(\.placedAt, order: .reverse)])
        if let lastOrder = (try? context.fetch(descriptor))?.first {
            for item in lastOrder.lineItems {
                if let prod = item.product {
                    addFavorite(prod)
                }
            }
        }
    }
    
    public func markAsSeen() {
        hasNewItems = false
    }
    
    private func seedInitialFavorites() {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<Product>()
        if let allProducts = try? context.fetch(descriptor), allProducts.count >= 3 {
            let initialSeeds = [allProducts[0], allProducts[1], allProducts[2]]
            for prod in initialSeeds {
                let newItem = SavedListItem(product: prod)
                context.insert(newItem)
            }
            try? context.save()
            fetchFavorites()
        }
    }
}
