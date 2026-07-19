// Category.swift
// SwiftData model representing a category.

import Foundation
import SwiftData

@Model
public final class Category: Identifiable {
    @Attribute(.unique) public var id: String
    public var name: String
    public var icon: String
    public var colorHex: String
    public var shortName: String
    
    public init(id: String, name: String, icon: String, colorHex: String, shortName: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.shortName = shortName
    }
}
