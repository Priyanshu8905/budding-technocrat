// CartItem.swift
// SwiftData model representing a shopping cart line item.

import Foundation
import SwiftData

@Model
public final class CartLineItem: Identifiable {
    @Attribute(.unique) public var id: String
    @Relationship public var product: Product?
    public var quantity: Int
    
    public init(id: String = UUID().uuidString, product: Product? = nil, quantity: Int = 1) {
        self.id = id
        self.product = product
        self.quantity = quantity
    }
    
    public var subtotal: Int {
        guard let product = product else { return 0 }
        return Int(round(product.price * Double(quantity)))
    }
    
    public var totalMrp: Int {
        guard let product = product else { return 0 }
        return Int(round(product.mrp * Double(quantity)))
    }
    
    public var totalSavings: Int {
        totalMrp - subtotal
    }
}

public typealias CartItem = CartLineItem
