// PantryItem.swift
// SwiftData model representing a stored pantry ingredient with decay tracking.

import Foundation
import SwiftData

@Model
final class PantryItem {
    @Attribute(.unique) var id: String
    var name: String
    var category: String
    var currentQuantity: Double
    var unit: String
    var purchasedDate: Date
    var dailyDepletionRate: Double
    var shelfLifeDays: Int
    
    init(id: String = UUID().uuidString, name: String, category: String, currentQuantity: Double, unit: String, purchasedDate: Date, dailyDepletionRate: Double, shelfLifeDays: Int) {
        self.id = id
        self.name = name
        self.category = category
        self.currentQuantity = currentQuantity
        self.unit = unit
        self.purchasedDate = purchasedDate
        self.dailyDepletionRate = dailyDepletionRate
        self.shelfLifeDays = shelfLifeDays
    }
    
    var daysElapsed: Int {
        Calendar.current.dateComponents([.day], from: purchasedDate, to: Date()).day ?? 0
    }
    
    var remainingShelfLifeDays: Int {
        max(0, shelfLifeDays - daysElapsed)
    }
    
    var calculatedQuantity: Double {
        max(0.0, currentQuantity - (dailyDepletionRate * Double(daysElapsed)))
    }
    
    var status: String {
        let qty = calculatedQuantity
        let shelfLife = remainingShelfLifeDays
        
        if qty <= 0.0 || shelfLife <= 0 {
            return "Critical"
        } else if qty / currentQuantity <= 0.25 || shelfLife <= 2 {
            return "Critical"
        } else if qty / currentQuantity <= 0.5 {
            return "Warning"
        } else {
            return "Healthy"
        }
    }
}
