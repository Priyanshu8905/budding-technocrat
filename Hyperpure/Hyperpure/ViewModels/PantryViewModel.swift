// PantryViewModel.swift
// ViewModel managing pantry item operations, decay calculations, and replenishment.

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class PantryViewModel {
    private var modelContext: ModelContext?
    var pantryItems: [PantryItem] = []
    var replenishmentDraft: [Product] = []
    var isGeneratingReplenishment = false
    
    func setup(with context: ModelContext) {
        self.modelContext = context
        fetchItems()
        if pantryItems.isEmpty {
            seedInitialPantryItems()
        }
    }
    
    func fetchItems() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<PantryItem>(sortBy: [SortDescriptor(\.name)])
        do {
            pantryItems = try context.fetch(descriptor)
        } catch {
            pantryItems = []
        }
    }
    
    func addItem(name: String, category: String, quantity: Double, unit: String, shelfLife: Int, depletionRate: Double) {
        guard let context = modelContext else { return }
        let newItem = PantryItem(
            name: name,
            category: category,
            currentQuantity: quantity,
            unit: unit,
            purchasedDate: Date(),
            dailyDepletionRate: depletionRate,
            shelfLifeDays: shelfLife
        )
        context.insert(newItem)
        try? context.save()
        fetchItems()
    }
    
    func deleteItem(_ item: PantryItem) {
        guard let context = modelContext else { return }
        context.delete(item)
        try? context.save()
        fetchItems()
    }
    
    func seedInitialPantryItems() {
        guard let context = modelContext else { return }
        
        let initialItems = [
            PantryItem(name: "Fresh Chicken Breast", category: "chicken-eggs", currentQuantity: 15.0, unit: "kg", purchasedDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, dailyDepletionRate: 3.5, shelfLifeDays: 5),
            PantryItem(name: "Whole Eggs (Pack of 30)", category: "chicken-eggs", currentQuantity: 10.0, unit: "packs", purchasedDate: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, dailyDepletionRate: 1.5, shelfLifeDays: 14),
            PantryItem(name: "Frozen French Fries", category: "frozen", currentQuantity: 8.0, unit: "packs", purchasedDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, dailyDepletionRate: 2.0, shelfLifeDays: 30),
            PantryItem(name: "Tomato Ketchup", category: "sauces-seasoning", currentQuantity: 5.0, unit: "litres", purchasedDate: Calendar.current.date(byAdding: .day, value: -12, to: Date())!, dailyDepletionRate: 0.3, shelfLifeDays: 90),
            PantryItem(name: "Biodegradable Meal Boxes", category: "packaging", currentQuantity: 500.0, unit: "pcs", purchasedDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, dailyDepletionRate: 85.0, shelfLifeDays: 365)
        ]
        
        for item in initialItems {
            context.insert(item)
        }
        try? context.save()
        fetchItems()
    }
    
    func generateReplenishmentDraft() async {
        isGeneratingReplenishment = true
        try? await Task.sleep(for: .seconds(1.5))
        
        let criticalItems = pantryItems.filter { $0.status == "Critical" || $0.status == "Warning" }
        var drafts: [Product] = []
        
        for item in criticalItems {
            if let matchedProduct = MockProducts.products.first(where: { $0.name.lowercased().contains(item.name.lowercased()) || item.name.lowercased().contains($0.name.lowercased()) }) {
                drafts.append(matchedProduct)
            }
        }
        
        replenishmentDraft = drafts
        isGeneratingReplenishment = false
    }
}
