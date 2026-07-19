// CartViewModel.swift
// ViewModel managing the state and operations of the shopping cart using SwiftData.

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
public final class CartViewModel {
    public static let shared = CartViewModel()
    
    public private(set) var items: [CartLineItem] = []
    public var selectedDeliverySlot: String = "Tomorrow Morning"
    
    public init() {
        fetchItems()
    }
    
    public func updateDeliverySlot(_ slot: String) {
        selectedDeliverySlot = slot
    }
    
    public func fetchItems() {
        let descriptor = FetchDescriptor<CartLineItem>()
        self.items = (try? Database.shared.context.fetch(descriptor)) ?? []
    }
    
    public var totalItems: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    public var subtotal: Int {
        items.reduce(0) { $0 + $1.subtotal }
    }
    
    public var totalMrp: Int {
        items.reduce(0) { $0 + $1.totalMrp }
    }
    
    public var totalSavings: Int {
        totalMrp - subtotal
    }
    
    public var deliveryFee: Int {
        subtotal > 500 || items.isEmpty ? 0 : 49
    }
    
    public var tax: Int {
        Int(round(Double(subtotal) * 0.05))
    }
    
    public var grandTotal: Int {
        items.isEmpty ? 0 : (subtotal + deliveryFee + tax)
    }
    
    public func quantity(for product: Product) -> Int {
        items.first(where: { $0.product?.id == product.id })?.quantity ?? 0
    }
    
    public func add(product: Product) {
        let context = Database.shared.context
        if let existing = items.first(where: { $0.product?.id == product.id }) {
            existing.quantity += 1
        } else {
            let productId = product.id
            let prodDescriptor = FetchDescriptor<Product>(predicate: #Predicate { $0.id == productId })
            let dbProduct = (try? context.fetch(prodDescriptor))?.first ?? product
            
            let newItem = CartLineItem(product: dbProduct, quantity: 1)
            context.insert(newItem)
        }
        try? context.save()
        fetchItems()
    }
    
    public func remove(product: Product) {
        let context = Database.shared.context
        if let existing = items.first(where: { $0.product?.id == product.id }) {
            context.delete(existing)
        }
        try? context.save()
        fetchItems()
    }
    
    public func updateQuantity(for product: Product, quantity: Int) {
        let context = Database.shared.context
        if quantity <= 0 {
            remove(product: product)
        } else if let existing = items.first(where: { $0.product?.id == product.id }) {
            existing.quantity = quantity
            try? context.save()
            fetchItems()
        } else {
            let productId = product.id
            let prodDescriptor = FetchDescriptor<Product>(predicate: #Predicate { $0.id == productId })
            let dbProduct = (try? context.fetch(prodDescriptor))?.first ?? product
            
            let newItem = CartLineItem(product: dbProduct, quantity: quantity)
            context.insert(newItem)
            try? context.save()
            fetchItems()
        }
    }
    
    public func clear() {
        let context = Database.shared.context
        for item in items {
            context.delete(item)
        }
        try? context.save()
        fetchItems()
    }
    
    public func applyWeatherBuffer() {
        let weatherVM = WeatherIntelligenceViewModel.shared
        for item in items {
            if let prod = item.product {
                let optimizedQty = weatherVM.optimizeQuantity(product: prod, originalQuantity: item.quantity)
                item.quantity = optimizedQty
            }
        }
        try? Database.shared.context.save()
        fetchItems()
    }
}
