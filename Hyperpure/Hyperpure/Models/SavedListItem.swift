// SavedListItem.swift
// SwiftData model representing a saved favorite item.

import Foundation
import SwiftData

@Model
public final class SavedListItem {
    @Attribute(.unique) public var id: String
    @Relationship public var product: Product?
    public var savedAt: Date
    
    public init(id: String = UUID().uuidString, product: Product? = nil, savedAt: Date = Date()) {
        self.id = id
        self.product = product
        self.savedAt = savedAt
    }
}
