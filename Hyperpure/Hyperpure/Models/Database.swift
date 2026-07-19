// Database.swift
// Global persistent SwiftData container provider and database seeder.

import Foundation
import SwiftData

public final class Database {
    public static let shared = Database()
    
    public let container: ModelContainer
    
    @MainActor
    public var context: ModelContext {
        container.mainContext
    }
    
    private init() {
        do {
            let schema = Schema([
                Product.self,
                Category.self,
                CartLineItem.self,
                Order.self,
                SavedListItem.self,
                AccountProfile.self,
                PantryItem.self
            ])
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
            
            // Seed initial database synchronously
            let context = ModelContext(container)
            try seedData(in: context)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }
    
    private func seedData(in context: ModelContext) throws {
        let categoryCount = try context.fetchCount(FetchDescriptor<Category>())
        if categoryCount == 0 {
            for cat in MockCategories.categories {
                context.insert(cat)
            }
        }
        
        let productCount = try context.fetchCount(FetchDescriptor<Product>())
        if productCount == 0 {
            for prod in MockProducts.products {
                context.insert(prod)
            }
        }
        
        let profileCount = try context.fetchCount(FetchDescriptor<AccountProfile>())
        if profileCount == 0 {
            let profile = AccountProfile(walletBalance: 25000.0, isVegModeOn: false)
            context.insert(profile)
        }
        
        try? context.save()
    }
}
