//
//  HyperPureSiriIntents.swift
//  Hyperpure
//
//  Created by Kaushiki Rai on 18/07/26.
//

import Foundation
// HyperpureSiriIntents.swift
// Siri and App Intents integration for catalog searching and cart management.

import AppIntents
import SwiftUI

struct ProductEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Hyperpure product"
    static var defaultQuery = ProductEntityQuery()

    var id: Int
    var name: String
    var priceText: String
    var categoryId: String

    init(product: Product) {
        self.id = product.id
        self.name = product.name
        self.priceText = product.formattedPrice
        self.categoryId = product.category
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(priceText)")
    }

    var underlyingProduct: Product? {
        MockProducts.products.first(where: { $0.id == id })
    }
}

struct ProductEntityQuery: EntityQuery, EntityStringQuery {
    func entities(for identifiers: [Int]) async throws -> [ProductEntity] {
        MockProducts.products
            .filter { identifiers.contains($0.id) }
            .map(ProductEntity.init)
    }

    func entities(matching string: String) async throws -> [ProductEntity] {
        let lowered = string.lowercased()
        return MockProducts.products
            .filter {
                $0.name.lowercased().contains(lowered) ||
                $0.subcategory.lowercased().contains(lowered)
            }
            .prefix(10)
            .map(ProductEntity.init)
    }

    func suggestedEntities() async throws -> [ProductEntity] {
        MockProducts.products
            .filter(\.isPopular)
            .prefix(5)
            .map(ProductEntity.init)
    }
}

struct CategoryEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Hyperpure category"
    static var defaultQuery = CategoryEntityQuery()

    var id: String
    var name: String

    init(category: Category) {
        self.id = category.id
        self.name = category.name
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct CategoryEntityQuery: EntityQuery, EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [CategoryEntity] {
        MockCategories.categories
            .filter { identifiers.contains($0.id) }
            .map(CategoryEntity.init)
    }

    func entities(matching string: String) async throws -> [CategoryEntity] {
        let lowered = string.lowercased()
        return MockCategories.categories
            .filter { $0.name.lowercased().contains(lowered) }
            .map(CategoryEntity.init)
    }

    func suggestedEntities() async throws -> [CategoryEntity] {
        Array(MockCategories.categories.prefix(6)).map(CategoryEntity.init)
    }
}

struct SearchHyperpureCatalogueIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Hyperpure catalogue"
    static var description = IntentDescription(
        "Searches Hyperpure products by name or category, hands-free."
    )
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Search term")
    var searchTerm: String

    static var parameterSummary: some ParameterSummary {
        Summary("Search Hyperpure for \(\.$searchTerm)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let lowered = searchTerm.lowercased()
        let matches = MockProducts.products.filter {
            $0.name.lowercased().contains(lowered) || $0.subcategory.lowercased().contains(lowered)
        }
        let topMatches = Array(matches.prefix(5))

        let dialog: IntentDialog
        if topMatches.isEmpty {
            dialog = IntentDialog("No Hyperpure products matched \"\(searchTerm)\".")
        } else {
            dialog = IntentDialog(
                "Found \(matches.count) products for \"\(searchTerm)\". Here are the top matches."
            )
        }

        return .result(
            dialog: dialog,
            view: ProductSearchSnippetView(products: topMatches)
        )
    }
}

struct AddToHyperpureCartIntent: AppIntent {
    static var title: LocalizedStringResource = "Add item to Hyperpure cart"
    static var description = IntentDescription(
        "Adds a product to your Hyperpure cart hands-free."
    )
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Product")
    var product: ProductEntity

    @Parameter(title: "Quantity", default: 1)
    var quantity: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$quantity) of \(\.$product) to my Hyperpure cart")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        guard let resolvedProduct = product.underlyingProduct else {
            return .result(
                dialog: IntentDialog("I couldn't find that product in the Hyperpure catalogue anymore."),
                view: EmptyCartSnippetView()
            )
        }

        let safeQuantity = max(1, quantity)
        let currentQuantity = CartViewModel.shared.quantity(for: resolvedProduct)
        CartViewModel.shared.updateQuantity(for: resolvedProduct, quantity: currentQuantity + safeQuantity)

        let dialog = IntentDialog(
            "Added \(safeQuantity) \(resolvedProduct.name) to your Hyperpure cart. You now have \(CartViewModel.shared.totalItems) items totalling ₹\(CartViewModel.shared.grandTotal)."
        )

        return .result(
            dialog: dialog,
            view: CartSummarySnippetView()
        )
    }
}

struct CheckHyperpureCartIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Hyperpure cart"
    static var description = IntentDescription(
        "Reports your current Hyperpure cart total hands-free."
    )
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let dialog: IntentDialog
        if CartViewModel.shared.items.isEmpty {
            dialog = IntentDialog("Your Hyperpure cart is empty right now.")
        } else {
            dialog = IntentDialog(
                "Your Hyperpure cart has \(CartViewModel.shared.totalItems) items, totalling ₹\(CartViewModel.shared.grandTotal) after tax and delivery."
            )
        }

        return .result(dialog: dialog, view: CartSummarySnippetView())
    }
}

struct ProductSearchSnippetView: View {
    let products: [Product]
    
    private let layoutPadding: CGFloat = 20
    private let strokeOpacity: Double = 0.25
    private let strokeWidth: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Hyperpure catalogue", systemImage: "basket.fill")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            if products.isEmpty {
                Text("No matching products found.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                ForEach(products) { product in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(product.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                                .lineLimit(1)
                            Text(product.weight)
                                .font(.caption)
                                .foregroundStyle(Theme.textMuted)
                        }

                        Spacer()

                        Text(product.formattedPrice)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .padding(.vertical, 4)

                    if product.id != products.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(layoutPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.radiusLg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusLg, style: .continuous)
                .strokeBorder(Color.white.opacity(strokeOpacity), lineWidth: strokeWidth)
        )
        .padding(.horizontal, 4)
    }
}

struct CartSummarySnippetView: View {
    private let layoutPadding: CGFloat = 20
    private let strokeOpacity: Double = 0.25
    private let strokeWidth: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Hyperpure cart", systemImage: "cart.fill")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)

            if CartViewModel.shared.items.isEmpty {
                Text("Your cart is empty.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                ForEach(CartViewModel.shared.items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.product.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                                .lineLimit(1)
                            Text("Qty \(item.quantity)")
                                .font(.caption)
                                .foregroundStyle(Theme.textMuted)
                        }

                        Spacer()

                        Text("₹\(item.subtotal)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                    .padding(.vertical, 4)

                    if item.id != CartViewModel.shared.items.last?.id {
                        Divider()
                    }
                }

                Divider()

                HStack {
                    Text("Total")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("₹\(CartViewModel.shared.grandTotal)")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Theme.primary)
                }
            }
        }
        .padding(layoutPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.radiusLg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusLg, style: .continuous)
                .strokeBorder(Color.white.opacity(strokeOpacity), lineWidth: strokeWidth)
        )
        .padding(.horizontal, 4)
    }
}

struct EmptyCartSnippetView: View {
    private let layoutPadding: CGFloat = 20
    private let strokeOpacity: Double = 0.25
    private let strokeWidth: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Hyperpure cart", systemImage: "cart.badge.questionmark")
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            Text("That product could not be found.")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(layoutPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.radiusLg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.radiusLg, style: .continuous)
                .strokeBorder(Color.white.opacity(strokeOpacity), lineWidth: strokeWidth)
        )
        .padding(.horizontal, 4)
    }
}

struct HyperpureAppShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .red

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchHyperpureCatalogueIntent(),
            phrases: [
                "Search \(.applicationName) catalogue",
                "Find products on \(.applicationName)"
            ],
            shortTitle: "Search catalogue",
            systemImageName: "magnifyingglass"
        )

        AppShortcut(
            intent: AddToHyperpureCartIntent(),
            phrases: [
                "Add \(\.$product) to my \(.applicationName) cart",
                "Order \(\.$product) on \(.applicationName)"
            ],
            shortTitle: "Add to cart",
            systemImageName: "cart.badge.plus"
        )

        AppShortcut(
            intent: CheckHyperpureCartIntent(),
            phrases: [
                "What's in my \(.applicationName) cart",
                "Check my \(.applicationName) cart total"
            ],
            shortTitle: "Check cart",
            systemImageName: "cart.fill"
        )
    }
}

#Preview("Product Search Snippet") {
    ProductSearchSnippetView(products: Array(MockProducts.products.prefix(3)))
}

#Preview("Cart Summary Snippet") {
    let viewModel = CartViewModel.shared
    viewModel.clear()
    if let product1 = MockProducts.products.first {
        viewModel.add(product: product1)
    }
    if MockProducts.products.count > 1 {
        viewModel.add(product: MockProducts.products[1])
    }
    return CartSummarySnippetView()
        .environment(viewModel)
}

#Preview("Empty Cart Snippet") {
    EmptyCartSnippetView()
}
