import Foundation
import Observation

@Observable
final class CartViewModel {
    private(set) var items: [CartItem] = []
    
    var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Int {
        items.reduce(0) { $0 + $1.subtotal }
    }
    
    var totalMrp: Int {
        items.reduce(0) { $0 + $1.totalMrp }
    }
    
    var totalSavings: Int {
        totalMrp - subtotal
    }
    
    var deliveryFee: Int {
        subtotal > 500 || items.isEmpty ? 0 : 49
    }
    
    var tax: Int {
        Int(round(Double(subtotal) * 0.05))
    }
    
    var grandTotal: Int {
        items.isEmpty ? 0 : (subtotal + deliveryFee + tax)
    }
    
    var isWeatherOptimizedApplied = false
    private var originalItems: [CartItem] = []
    
    func applyWeatherAdjustments(suggestions: [WeatherAdjustedSuggestion]) {
        if !isWeatherOptimizedApplied {
            originalItems = items
        }
        
        for suggestion in suggestions {
            if let index = items.firstIndex(where: { $0.product.id == suggestion.productID }) {
                let newQty = Int(round(suggestion.adjustedQuantity))
                if newQty <= 0 {
                    items.remove(at: index)
                } else {
                    items[index].quantity = newQty
                }
            }
        }
        isWeatherOptimizedApplied = true
    }
    
    func removeWeatherAdjustments() {
        guard isWeatherOptimizedApplied else { return }
        items = originalItems
        isWeatherOptimizedApplied = false
        originalItems.removeAll()
    }

    func quantity(for product: Product) -> Int {
        items.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }
    
    func add(product: Product) {
        isWeatherOptimizedApplied = false
        originalItems.removeAll()
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }
    
    func remove(product: Product) {
        isWeatherOptimizedApplied = false
        originalItems.removeAll()
        items.removeAll(where: { $0.product.id == product.id })
    }
    
    func updateQuantity(for product: Product, quantity: Int) {
        isWeatherOptimizedApplied = false
        originalItems.removeAll()
        if quantity <= 0 {
            remove(product: product)
        } else if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity = quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
    }
    
    func clear() {
        isWeatherOptimizedApplied = false
        originalItems.removeAll()
        items.removeAll()
    }
}
