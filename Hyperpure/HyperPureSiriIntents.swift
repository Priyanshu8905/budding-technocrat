// HyperPureSiriIntents.swift
// Siri and App Intents integration for catalog searching, cart macros, and stock audits.

import Foundation
import AppIntents
import SwiftUI
import SwiftData

struct ProductEntity: AppEntity, Identifiable {

    static func mapVoiceQueryToCatalogProduct(_ query: String) -> Product? {
        let cleanQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        let mapping: [String: String] = [
            "chicken": "chicken",
            "egg": "eggs",
            "milk": "milkmaid",
            "flour": "sheets",
            "atta": "sheets",
            "wheat": "sheets",
            "onion": "patty",
            "tomato": "mayonnaise",
            "ketchup": "mayonnaise",
            "sauce": "mayonnaise",
            "patty": "patty",
            "paneer": "paneer",
            "fries": "fries",
            "potato": "fries",
            "pasta": "pasta",
            "crumbs": "crumbs",
            "straw": "straws",
            "napkin": "napkin",
            "serviette": "serviettes",
            "chocolate": "chocolate"
        ]
        
        for (keyword, catalogKeyword) in mapping {
            if cleanQuery.contains(keyword) {
                return MockProducts.products.first(where: { $0.name.lowercased().contains(catalogKeyword) })
            }
        }
        
        return MockProducts.products.first(where: { 
            $0.name.lowercased().contains(cleanQuery) || 
            cleanQuery.contains($0.name.lowercased()) 
        })
    }
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
                "Check my \(.applicationName) cart total",
                "Show my \(.applicationName) cart",
                "Check cart on \(.applicationName)",
                "Cart status on \(.applicationName)"
            ],
            shortTitle: "Check cart",
            systemImageName: "cart.fill"
        )


        AppShortcut(
            intent: AuditLowStockPantryIntent(),
            phrases: [
                "Audit low stock items on \(.applicationName)",
                "Audit low stock on \(.applicationName)",
                "What's running low in the kitchen on \(.applicationName)",
                "Check pantry inventory on \(.applicationName)",
                "Pantry stock audit on \(.applicationName)",
                "Check low stock on \(.applicationName)"
            ],
            shortTitle: "Audit low stock",
            systemImageName: "exclamationmark.triangle.fill"
        )

        AppShortcut(
            intent: AddBulkItemsToCartVoiceIntent(),
            phrases: [
                "Add item list inside \(.applicationName)"
            ],
            shortTitle: "Voice bulk cart",
            systemImageName: "cart.badge.plus"
        )

        AppShortcut(
            intent: AddToPantryInventoryVoiceIntent(),
            phrases: [
                "Log these ingredients using \(.applicationName)",
                "Update kitchen stock levels in \(.applicationName)"
            ],
            shortTitle: "Add pantry item",
            systemImageName: "plus.square.on.square"
        )

        AppShortcut(
            intent: NavigateToKitchenDashboardIntent(),
            phrases: [
                "Examine layout records inside \(.applicationName)",
                "Show my active pantry logs in \(.applicationName)"
            ],
            shortTitle: "Show kitchen dashboard",
            systemImageName: "chart.bar.doc.horizontal"
        )

        AppShortcut(
            intent: ExecuteVoiceProcurementIntent(),
            phrases: [
                "Process my kitchen order inside \(.applicationName)",
                "Run voice procurement using \(.applicationName)",
                "Restock ingredients via \(.applicationName)"
            ],
            shortTitle: "Voice procurement",
            systemImageName: "chefhat"
        )

        AppShortcut(
            intent: ApplyWeatherOptimizationIntent(),
            phrases: [
                "Prepare for the weather today in \(.applicationName)",
                "Apply seasonal optimization changes using \(.applicationName)",
                "Check custom menu recommendations inside \(.applicationName)"
            ],
            shortTitle: "Weather optimization",
            systemImageName: "cloud.sun.fill"
        )

        AppShortcut(
            intent: InitiateCheckoutWorkflowIntent(),
            phrases: [
                "Checkout my cart inside \(.applicationName)",
                "Start checkout workflow in \(.applicationName)",
                "Checkout my Hyperpure cart using \(.applicationName)"
            ],
            shortTitle: "Checkout cart",
            systemImageName: "cart.fill"
        )
    }
}

struct ApplyMonsoonAdjustmentsIntent: AppIntent {
    static var title: LocalizedStringResource = "Apply monsoon cart adjustments"
    static var description = IntentDescription(
        "Increases cart quantities by 20% to safeguard against monsoon logistics delays."
    )
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let cartItems = CartViewModel.shared.items
        
        if cartItems.isEmpty {
            return .result(
                dialog: IntentDialog("Your cart is empty. Please add items before applying monsoon adjustments."),
                view: EmptyCartSnippetView()
            )
        }
        
        for item in cartItems {
            let bufferQty = Int(ceil(Double(item.quantity) * 1.2))
            CartViewModel.shared.updateQuantity(for: item.product, quantity: bufferQty)
        }
        
        let dialog = IntentDialog(
            "Applied monsoon adjustments. All cart item quantities increased by 20% to prevent transit delay issues. New cart total is ₹\(CartViewModel.shared.grandTotal)."
        )
        
        return .result(
            dialog: dialog,
            view: CartSummarySnippetView()
        )
    }
}

struct AuditLowStockPantryIntent: AppIntent {
    static var title: LocalizedStringResource = "Audit low stock items"
    static var description = IntentDescription(
        "Identifies and lists critical or low stock pantry items hands-free."
    )
    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let container = try ModelContainer(for: PantryItem.self)
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<PantryItem>()
        let allItems = try context.fetch(descriptor)
        
        let criticalItems = allItems.filter { $0.status == "Critical" || $0.status == "Warning" }
        
        let dialog: IntentDialog
        if criticalItems.isEmpty {
            dialog = IntentDialog("All pantry ingredients are stable. No low stock items found.")
        } else {
            let names = criticalItems.map { $0.name }.joined(separator: ", ")
            dialog = IntentDialog("You have \(criticalItems.count) critical items: \(names). Consider restocking them.")
        }
        
        return .result(
            dialog: dialog,
            view: PantryAuditSnippetView(criticalItems: criticalItems)
        )
    }
}

struct AddBulkItemsToCartVoiceIntent: AppIntent {
    static var title: LocalizedStringResource = "Add bulk items to cart by voice"
    static var description = IntentDescription("Log multiple items directly into your checkout cart using voice command parsing.")
    
    @Parameter(title: "Items List")
    var itemsList: [String]
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        var successfullyAdded: [String] = []
        
        func parseItem(_ itemString: String) -> (quantity: Int, name: String) {
            let clean = itemString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let pattern = "^(\\d+)\\s*(?:kg|g|liters|l|packs|units|pcs)?\\s+(.+)$"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: clean, range: NSRange(clean.startIndex..., in: clean)) {
                if let qtyRange = Range(match.range(at: 1), in: clean),
                   let nameRange = Range(match.range(at: 2), in: clean),
                   let qty = Int(clean[qtyRange]) {
                    return (qty, String(clean[nameRange]).capitalized)
                }
            }
            return (1, clean.capitalized)
        }
        
        for rawItem in itemsList {
            let (qty, parsedName) = parseItem(rawItem)
            
            if let product = ProductEntity.mapVoiceQueryToCatalogProduct(parsedName) {
                let currentQty = CartViewModel.shared.quantity(for: product)
                CartViewModel.shared.updateQuantity(for: product, quantity: currentQty + qty)
                successfullyAdded.append("\(qty)x \(product.name)")
            }
        }
        
        let dialog: IntentDialog
        if successfullyAdded.isEmpty {
            dialog = IntentDialog("I couldn't find matches in the catalogue. Try calling out products like Fries, Eggs, or Chicken.")
        } else {
            let listString = successfullyAdded.joined(separator: ", ")
            dialog = IntentDialog("Got it! I've added \(listString) to your cart. The current total is ₹\(CartViewModel.shared.grandTotal).")
        }
        
        return .result(
            dialog: dialog,
            view: BulkCartSnippetView(addedItems: successfullyAdded, totalItemsCount: itemsList.count)
        )
    }
}

struct AddToPantryInventoryVoiceIntent: AppIntent {
    static var title: LocalizedStringResource = "Add to pantry inventory by voice"
    static var description = IntentDescription("Log raw kitchen ingredients into inventory database hands-free.")
    
    @Parameter(title: "Ingredient Name", requestValueDialog: IntentDialog("What ingredient are we logging?"))
    var name: String
    
    @Parameter(title: "Quantity Amount", requestValueDialog: IntentDialog("How much of it are we storing?"))
    var quantity: Double
    
    @Parameter(title: "Category Section", requestValueDialog: IntentDialog("And which section should I put it in?"))
    var category: String
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let container = try ModelContainer(for: PantryItem.self)
        let context = ModelContext(container)
        
        let normalizedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let newItem = PantryItem(
            name: name.capitalized,
            category: normalizedCategory,
            currentQuantity: quantity,
            unit: "units",
            purchasedDate: Date(),
            dailyDepletionRate: quantity / 10.0,
            shelfLifeDays: 7
        )
        
        context.insert(newItem)
        try context.save()
        
        let dialog = IntentDialog("All set! Stored \(String(format: "%.1f", quantity)) units of \(name.capitalized) in the pantry.")
        
        return .result(
            dialog: dialog,
            view: PantryConfirmationSnippetView(name: name.capitalized, quantity: quantity, category: normalizedCategory)
        )
    }
}

struct NavigateToKitchenDashboardIntent: AppIntent {
    static var title: LocalizedStringResource = "Navigate to kitchen dashboard"
    static var description = IntentDescription("Open the pantry inventory logs in Hyperpure.")
    static var openAppWhenRun: Bool = true
    
    @MainActor
    func perform() async throws -> some IntentResult {
        AppState.shared.selectedTab = 4
        return .result()
    }
}

struct PantryAuditSnippetView: View {
    let criticalItems: [PantryItem]
    
    private let layoutPadding: CGFloat = 20
    private let strokeOpacity: Double = 0.25
    private let strokeWidth: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Pantry Stock Audit", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(Theme.primary)

            if criticalItems.isEmpty {
                Text("All tracked ingredients are at healthy levels.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                ForEach(criticalItems, id: \.id) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Theme.textPrimary)
                            Text("Only \(String(format: "%.1f", item.calculatedQuantity)) \(item.unit) remaining")
                                .font(.caption)
                                .foregroundStyle(Theme.textMuted)
                        }

                        Spacer()

                        Text(item.status)
                            .font(.caption.weight(.bold))
                            .foregroundColor(Theme.primary)
                    }
                    .padding(.vertical, 4)

                    if item.id != criticalItems.last?.id {
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

struct BulkCartSnippetView: View {
    let addedItems: [String]
    let totalItemsCount: Int
    @State private var cartViewModel = CartViewModel.shared
    
    private let layoutPadding: CGFloat = 20
    private let strokeOpacity: Double = 0.25
    private let strokeWidth: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Bulk Cart Intake", systemImage: "cart.badge.plus")
                .font(.headline)
                .foregroundStyle(Theme.primary)

            if addedItems.isEmpty {
                Text("No matching catalog items could be parsed from your voice input.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                Text("Parsed and added \(addedItems.count) of \(totalItemsCount) items:")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
                
                ForEach(addedItems, id: \.self) { item in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Theme.success)
                        Text(item)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("New Cart Total:")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text("₹\(cartViewModel.grandTotal)")
                        .font(.headline)
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

struct PantryConfirmationSnippetView: View {
    let name: String
    let quantity: Double
    let category: String
    
    private let layoutPadding: CGFloat = 20
    private let strokeOpacity: Double = 0.25
    private let strokeWidth: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Added to Pantry", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(Theme.success)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.textPrimary)
                
                HStack {
                    Text("Stock quantity:")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text("\(String(format: "%.1f", quantity)) units")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
                
                HStack {
                    Text("Storage section:")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                    Spacer()
                    Text(category.capitalized)
                        .font(.subheadline.weight(.semibold))
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

#Preview("Pantry Audit Snippet") {
    let item = PantryItem(name: "Fresh Chicken Breast", category: "chicken-eggs", currentQuantity: 15.0, unit: "kg", purchasedDate: Date(), dailyDepletionRate: 3.5, shelfLifeDays: 5)
    PantryAuditSnippetView(criticalItems: [item])
}

#Preview("Bulk Cart Snippet") {
    BulkCartSnippetView(addedItems: ["5x Fresh Chicken Breast", "2x Whole Eggs"], totalItemsCount: 2)
}

#Preview("Pantry Confirmation Snippet") {
    PantryConfirmationSnippetView(name: "Mozzarella Cheese", quantity: 5.0, category: "dairy-bread")
}

struct ExecuteVoiceProcurementIntent: AppIntent {
    static var title: LocalizedStringResource = "Execute voice procurement recipe auto populate"
    static var description = IntentDescription("Auto-populate your cart with ingredients based on recipe templates.")
    
    @Parameter(title: "Target Recipe Selection")
    var targetRecipe: String?
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let activeCartIsEmpty = CartViewModel.shared.items.isEmpty
        
        let resolvedRecipe: String
        if activeCartIsEmpty && targetRecipe == nil {
            resolvedRecipe = try await $targetRecipe.requestValue(
                IntentDialog(LocalizedStringResource("Your cart is empty. Which recipe or station setup should we get ready?"))
            )
        } else {
            resolvedRecipe = targetRecipe ?? "Baseline Restock"
        }
        
        let cleanRecipe = resolvedRecipe.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        var itemsToAdd: [(name: String, quantity: Int)] = []
        if cleanRecipe.contains("pizza") {
            itemsToAdd = [
                ("paneer", 5),
                ("fries", 2),
                ("mayonnaise", 3)
            ]
        } else if cleanRecipe.contains("salad") {
            itemsToAdd = [
                ("eggs", 3),
                ("chicken", 2),
                ("pasta", 4)
            ]
        } else {
            itemsToAdd = [
                ("eggs", 2),
                ("fries", 1)
            ]
        }
        
        var successfullyAdded: [String] = []
        for item in itemsToAdd {
            if let product = ProductEntity.mapVoiceQueryToCatalogProduct(item.name) {
                let currentQty = CartViewModel.shared.quantity(for: product)
                CartViewModel.shared.updateQuantity(for: product, quantity: currentQty + item.quantity)
                successfullyAdded.append("\(item.quantity)x \(product.name)")
            }
        }
        
        let dialog = IntentDialog(
            LocalizedStringResource("Done! Sourced the ingredients for \(resolvedRecipe). Your cart total is now ₹\(CartViewModel.shared.grandTotal).")
        )
        
        return .result(
            dialog: dialog,
            view: RecipeProcurementSnippetView(recipeName: resolvedRecipe.capitalized, addedItems: successfullyAdded)
        )
    }
}

struct RecipeProcurementSnippetView: View {
    let recipeName: String
    let addedItems: [String]
    @State private var cartViewModel = CartViewModel.shared
    
    private let layoutPadding: CGFloat = 20
    private let strokeOpacity: Double = 0.25
    private let strokeWidth: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(LocalizedStringResource("Recipe Sourcing: \(recipeName)"), systemImage: "chefhat")
                .font(.headline)
                .foregroundStyle(Theme.primary)

            Text(LocalizedStringResource("Added recipe ingredients to cart:"))
                .font(.caption)
                .foregroundStyle(Theme.textMuted)
            
            ForEach(addedItems, id: \.self) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.success)
                    Text(item)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.textPrimary)
                }
            }
            
            Divider()
            
            HStack {
                Text(LocalizedStringResource("Procurement Subtotal:"))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("₹\(cartViewModel.grandTotal)")
                    .font(.headline)
                    .foregroundStyle(Theme.primary)
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

#Preview("Recipe Procurement Snippet") {
    RecipeProcurementSnippetView(recipeName: "Pizza Prep", addedItems: ["5x Whole Wheat Atta", "2x Tomato Ketchup"])
}
