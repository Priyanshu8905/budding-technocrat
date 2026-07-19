// HyperpureAppShortcuts.swift
// Shortcuts provider mapping Siri voice phrases to app intents.

import Foundation
import AppIntents

public struct HyperpureAppShortcuts: AppShortcutsProvider {
    public static var shortcutTileColor: ShortcutTileColor = .pink
    
    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchCatalogueIntent(),
            phrases: [
                "Search \(.applicationName)",
                "Find products on \(.applicationName)"
            ],
            shortTitle: "Search Catalog",
            systemImageName: "magnifyingglass"
        )
        
        AppShortcut(
            intent: BrowseCategoryIntent(),
            phrases: [
                "Open \(\.$category) in \(.applicationName)",
                "Browse \(\.$category) on \(.applicationName)"
            ],
            shortTitle: "Browse Category",
            systemImageName: "square.grid.2x2.fill"
        )
        
        AppShortcut(
            intent: AddToCartIntent(),
            phrases: [
                "Add \(\.$product) to my \(.applicationName) cart",
                "Put \(\.$product) in my \(.applicationName) cart"
            ],
            shortTitle: "Add to Cart",
            systemImageName: "cart.badge.plus"
        )
        
        AppShortcut(
            intent: UpdateCartQuantityIntent(),
            phrases: [
                "Set \(\.$product) quantity on \(.applicationName)"
            ],
            shortTitle: "Change Quantity",
            systemImageName: "number"
        )
        
        AppShortcut(
            intent: RemoveFromCartIntent(),
            phrases: [
                "Remove \(\.$product) from my \(.applicationName) cart"
            ],
            shortTitle: "Remove from Cart",
            systemImageName: "cart.badge.minus"
        )
        
        AppShortcut(
            intent: GetCartTotalIntent(),
            phrases: [
                "What's my \(.applicationName) cart total"
            ],
            shortTitle: "Check Cart Total",
            systemImageName: "indianrupeesign.circle"
        )
        
        AppShortcut(
            intent: PlaceProcurementOrderIntent(),
            phrases: [
                "Place my \(.applicationName) order using \(\.$paymentMethod)"
            ],
            shortTitle: "Place Order",
            systemImageName: "checkmark.seal"
        )
        
        AppShortcut(
            intent: TrackOrderIntent(),
            phrases: [
                "What's the status of my last \(.applicationName) order"
            ],
            shortTitle: "Track Order",
            systemImageName: "box.truck"
        )
        
        AppShortcut(
            intent: SaveToListIntent(),
            phrases: [
                "Save \(\.$product) to my \(.applicationName) list"
            ],
            shortTitle: "Save to List",
            systemImageName: "heart.fill"
        )
        
        AppShortcut(
            intent: QueryAccountOrAppIntent(),
            phrases: [
                "Show my \(.applicationName) \(\.$topic)",
                "Ask \(.applicationName) about \(\.$topic)"
            ],
            shortTitle: "Query Account",
            systemImageName: "person.crop.circle"
        )
    }
}
