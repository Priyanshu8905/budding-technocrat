// HyperpureAppEntities.swift
// SwiftData-backed App Entities and EntityQueries for Siri and App Intents integration.

import Foundation
import AppIntents
import SwiftData

public struct ProductEntity: AppEntity {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Product")
    }
    
    public static var defaultQuery = ProductEntityQuery()
    
    public let id: Int
    public let name: String
    public let category: String
    public let price: Double
    
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "₹\(Int(price)) · \(category.replacingOccurrences(of: "-", with: " ").capitalized)")
    }
    
    public init(product: Product) {
        self.id = product.id
        self.name = product.name
        self.category = product.category
        self.price = product.price
    }
}

public struct ProductEntityQuery: EntityQuery {
    public init() {}
    
    @MainActor
    public func entities(for ids: [Int]) async throws -> [ProductEntity] {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<Product>(predicate: #Predicate { ids.contains($0.id) })
        let products = (try? context.fetch(descriptor)) ?? []
        return products.map { ProductEntity(product: $0) }
    }
    
    @MainActor
    public func suggestedEntities() async throws -> [ProductEntity] {
        let context = Database.shared.context
        var descriptor = FetchDescriptor<Product>()
        descriptor.fetchLimit = 15
        let products = (try? context.fetch(descriptor)) ?? []
        return products.map { ProductEntity(product: $0) }
    }
}

extension ProductEntityQuery: EntityStringQuery {
    @MainActor
    public func entities(matching string: String) async throws -> [ProductEntity] {
        let context = Database.shared.context
        let all = (try? context.fetch(FetchDescriptor<Product>())) ?? []
        let lower = string.lowercased()
        return all.filter {
            $0.name.lowercased().contains(lower) ||
            $0.subcategory.lowercased().contains(lower) ||
            $0.category.lowercased().contains(lower)
        }.map { ProductEntity(product: $0) }
    }
}

public struct CategoryEntity: AppEntity {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Category")
    }
    
    public static var defaultQuery = CategoryEntityQuery()
    
    public let id: String
    public let name: String
    public let icon: String
    
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(icon) \(name)")
    }
    
    public init(category: Category) {
        self.id = category.id
        self.name = category.name
        self.icon = category.icon
    }
}

public struct CategoryEntityQuery: EntityQuery {
    public init() {}
    
    @MainActor
    public func entities(for ids: [String]) async throws -> [CategoryEntity] {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<Category>(predicate: #Predicate { ids.contains($0.id) })
        let categories = (try? context.fetch(descriptor)) ?? []
        return categories.map { CategoryEntity(category: $0) }
    }
    
    @MainActor
    public func suggestedEntities() async throws -> [CategoryEntity] {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        let categories = (try? context.fetch(descriptor)) ?? []
        return categories.map { CategoryEntity(category: $0) }
    }
}

extension CategoryEntityQuery: EntityStringQuery {
    @MainActor
    public func entities(matching string: String) async throws -> [CategoryEntity] {
        let context = Database.shared.context
        let all = (try? context.fetch(FetchDescriptor<Category>())) ?? []
        let lower = string.lowercased()
        return all.filter {
            $0.name.lowercased().contains(lower)
        }.map { CategoryEntity(category: $0) }
    }
}

public struct OrderEntity: AppEntity {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Order")
    }
    
    public static var defaultQuery = OrderEntityQuery()
    
    public let id: String
    public let grandTotal: Int
    public var status: String
    
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "Order #\(id.prefix(8).uppercased())", subtitle: "₹\(grandTotal) · \(status)")
    }
    
    public init(order: Order) {
        self.id = order.id
        self.grandTotal = order.grandTotal
        self.status = order.status.rawValue
    }
}

public struct OrderEntityQuery: EntityQuery {
    public init() {}
    
    @MainActor
    public func entities(for ids: [String]) async throws -> [OrderEntity] {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<Order>(predicate: #Predicate { ids.contains($0.id) })
        let orders = (try? context.fetch(descriptor)) ?? []
        return orders.map { OrderEntity(order: $0) }
    }
    
    @MainActor
    public func suggestedEntities() async throws -> [OrderEntity] {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<Order>(sortBy: [SortDescriptor(\.placedAt, order: .reverse)])
        let orders = (try? context.fetch(descriptor)) ?? []
        return orders.map { OrderEntity(order: $0) }
    }
}

extension OrderEntityQuery: EntityStringQuery {
    @MainActor
    public func entities(matching string: String) async throws -> [OrderEntity] {
        let context = Database.shared.context
        let all = (try? context.fetch(FetchDescriptor<Order>())) ?? []
        let lower = string.lowercased()
        return all.filter {
            $0.id.lowercased().contains(lower) ||
            $0.statusRaw.lowercased().contains(lower)
        }.map { OrderEntity(order: $0) }
    }
}

public struct SavedListEntity: AppEntity {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Saved List Item")
    }
    
    public static var defaultQuery = SavedListEntityQuery()
    
    public let id: String
    public let productName: String
    
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(productName)")
    }
    
    public init(item: SavedListItem) {
        self.id = item.id
        self.productName = item.product?.name ?? "Unknown Item"
    }
}

public struct SavedListEntityQuery: EntityQuery {
    public init() {}
    
    @MainActor
    public func entities(for ids: [String]) async throws -> [SavedListEntity] {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<SavedListItem>(predicate: #Predicate { ids.contains($0.id) })
        let items = (try? context.fetch(descriptor)) ?? []
        return items.map { SavedListEntity(item: $0) }
    }
    
    @MainActor
    public func suggestedEntities() async throws -> [SavedListEntity] {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<SavedListItem>(sortBy: [SortDescriptor(\.savedAt, order: .reverse)])
        let items = (try? context.fetch(descriptor)) ?? []
        return items.map { SavedListEntity(item: $0) }
    }
}

extension SavedListEntityQuery: EntityStringQuery {
    @MainActor
    public func entities(matching string: String) async throws -> [SavedListEntity] {
        let context = Database.shared.context
        let lower = string.lowercased()
        let descriptor = FetchDescriptor<SavedListItem>()
        let items = (try? context.fetch(descriptor)) ?? []
        return items.filter {
            $0.product?.name.localizedCaseInsensitiveContains(lower) ?? false
        }.map { SavedListEntity(item: $0) }
    }
}

// MARK: - Delivery Slot Enum
public enum DeliverySlotEnum: String, Codable, AppEnum {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Delivery Slot"
    }
    
    public static var caseDisplayRepresentations: [DeliverySlotEnum: DisplayRepresentation] {
        [
            .morning: "morning (9 AM - 1 PM)",
            .afternoon: "afternoon (1 PM - 5 PM)",
            .evening: "evening (5 PM - 9 PM)"
        ]
    }
}

// MARK: - Veg Mode State Enum
public enum VegModeState: String, Codable, AppEnum {
    case on = "on"
    case off = "off"
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Veg Mode"
    }
    
    public static var caseDisplayRepresentations: [VegModeState: DisplayRepresentation] {
        [
            .on: "on",
            .off: "off"
        ]
    }
}

// MARK: - Account Query Topic Enum
public enum AccountQueryTopic: String, Codable, AppEnum {
    case wallet = "wallet balance"
    case vegOn = "veg mode on"
    case vegOff = "veg mode off"
    case quality = "quality standards"
    case sustainability = "sustainability"
    case blog = "latest blog post"
    case favorites = "saved list"
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Topic"
    }
    
    public static var caseDisplayRepresentations: [AccountQueryTopic: DisplayRepresentation] {
        [
            .wallet: "wallet balance",
            .vegOn: "veg mode on",
            .vegOff: "veg mode off",
            .quality: "quality standards",
            .sustainability: "sustainability",
            .blog: "latest blog post",
            .favorites: "saved list"
        ]
    }
}
