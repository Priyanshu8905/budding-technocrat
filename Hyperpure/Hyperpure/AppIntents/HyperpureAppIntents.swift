// HyperpureAppIntents.swift
// Siri App Intents and matching Premium Snippet Views for the hands-free kitchen voice operations.

import Foundation
import AppIntents
import SwiftUI
import SwiftData

struct SearchCatalogueIntent: AppIntent {
    static var title: LocalizedStringResource = "Search Hyperpure Catalog"
    static var description = IntentDescription("Searches the Hyperpure catalog for a specific product.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Search Term")
    var searchTerm: String
    
    init() {}
    init(searchTerm: String) {
        self.searchTerm = searchTerm
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let results = CatalogueViewModel.shared.filteredProducts.filter {
            $0.name.localizedCaseInsensitiveContains(searchTerm) ||
            $0.productDescription.localizedCaseInsensitiveContains(searchTerm)
        }
        if results.isEmpty {
            return .result(dialog: IntentDialog("No products matching '\(searchTerm)' were found in the catalog."))
        }
        let dialog = IntentDialog("Found \(results.count) items matching '\(searchTerm)' in the catalog.")
        return .result(dialog: dialog, view: SearchResultsSnippetView(products: results, query: searchTerm))
    }
}

struct BrowseCategoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Browse Category"
    static var description = IntentDescription("Opens a category view in the Hyperpure catalog.")
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Category")
    var category: CategoryEntity
    
    init() {}
    init(category: CategoryEntity) {
        self.category = category
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        CatalogueViewModel.shared.selectCategory(category.id)
        AppState.shared.selectedTab = 1
        return .result(dialog: IntentDialog("Opening \(category.name) category in Hyperpure."))
    }
}

struct AddToCartIntent: AppIntent {
    static var title: LocalizedStringResource = "Add to Cart"
    static var description = IntentDescription("Adds a product to the Hyperpure shopping cart.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Product")
    var product: ProductEntity
    
    init() {}
    init(product: ProductEntity) {
        self.product = product
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let context = Database.shared.context
        let id = product.id
        let descriptor = FetchDescriptor<Product>(predicate: #Predicate { $0.id == id })
        guard let dbProduct = (try? context.fetch(descriptor))?.first else {
            return .result(dialog: IntentDialog("Could not find product in catalog."))
        }
        
        CartViewModel.shared.add(product: dbProduct)
        
        let dialog = IntentDialog("Added \(dbProduct.name) to your cart.")
        return .result(dialog: dialog, view: CartUpdatedSnippetView(product: dbProduct, quantity: CartViewModel.shared.quantity(for: dbProduct)))
    }
}

struct UpdateCartQuantityIntent: AppIntent {
    static var title: LocalizedStringResource = "Change Cart Quantity"
    static var description = IntentDescription("Changes the quantity of an item in the Hyperpure cart.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Product")
    var product: ProductEntity
    
    @Parameter(title: "Quantity")
    var quantity: Int
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let context = Database.shared.context
        let id = product.id
        let descriptor = FetchDescriptor<Product>(predicate: #Predicate { $0.id == id })
        guard let dbProduct = (try? context.fetch(descriptor))?.first else {
            return .result(dialog: IntentDialog("Could not find product in catalog."))
        }
        
        CartViewModel.shared.updateQuantity(for: dbProduct, quantity: quantity)
        let dialog = IntentDialog("Set \(dbProduct.name) quantity to \(quantity) in your cart.")
        return .result(dialog: dialog, view: CartUpdatedSnippetView(product: dbProduct, quantity: quantity))
    }
}

struct RemoveFromCartIntent: AppIntent {
    static var title: LocalizedStringResource = "Remove from Cart"
    static var description = IntentDescription("Removes a product from the Hyperpure cart.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Product")
    var product: ProductEntity
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = Database.shared.context
        let id = product.id
        let descriptor = FetchDescriptor<Product>(predicate: #Predicate { $0.id == id })
        guard let dbProduct = (try? context.fetch(descriptor))?.first else {
            return .result(dialog: IntentDialog("Could not find product in catalog."))
        }
        
        CartViewModel.shared.remove(product: dbProduct)
        return .result(dialog: IntentDialog("Removed \(dbProduct.name) from your Hyperpure cart."))
    }
}

struct GetCartTotalIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Cart Total"
    static var description = IntentDescription("Returns the subtotal and total cost of items currently in the cart.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let cart = CartViewModel.shared
        if cart.items.isEmpty {
            return .result(dialog: IntentDialog("Your Hyperpure cart is empty."))
        }
        let dialog = IntentDialog("Your cart total is \(cart.grandTotal) rupees, including \(cart.items.count) items.")
        return .result(dialog: dialog, view: CartTotalSnippetView())
    }
}

struct SelectDeliverySlotIntent: AppIntent {
    static var title: LocalizedStringResource = "Schedule Delivery Slot"
    static var description = IntentDescription("Selects a delivery slot for your Hyperpure order.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Delivery Slot")
    var deliverySlot: DeliverySlotEnum
    
    static var parameterSummary: some ParameterSummary {
        Summary("Schedule my delivery for \(\.$deliverySlot)")
    }
    
    init() {}
    init(deliverySlot: DeliverySlotEnum) {
        self.deliverySlot = deliverySlot
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let displayStr: String
        switch deliverySlot {
        case .morning: displayStr = "morning (9 AM - 1 PM)"
        case .afternoon: displayStr = "afternoon (1 PM - 5 PM)"
        case .evening: displayStr = "evening (5 PM - 9 PM)"
        }
        CartViewModel.shared.updateDeliverySlot(displayStr)
        return .result(dialog: IntentDialog("Scheduled your Hyperpure delivery slot to: \(displayStr)."))
    }
}

struct TrackOrderIntent: AppIntent {
    static var title: LocalizedStringResource = "Track Last Order"
    static var description = IntentDescription("Returns the status of your last active or past order.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let mgr = CheckoutManager.shared
        let context = Database.shared.context
        let descriptor = FetchDescriptor<Order>(sortBy: [SortDescriptor(\.placedAt, order: .reverse)])
        let lastOrder = (try? context.fetch(descriptor))?.first
        
        let dialog: IntentDialog
        if mgr.state != .idle {
            dialog = IntentDialog("Here is the tracking status of your active delivery.")
        } else if let last = lastOrder {
            dialog = IntentDialog("The status of your last order, placed at \(last.placedAt.formatted(date: .abbreviated, time: .shortened)), is \(last.status.rawValue).")
        } else {
            dialog = IntentDialog("You don't have any active deliveries or past orders on Hyperpure.")
        }
        
        return .result(dialog: dialog, view: TrackOrderSnippetView(order: lastOrder, activeState: mgr.state))
    }
}

struct TrackOrderSnippetView: View {
    let order: Order?
    let activeState: CheckoutManager.CheckoutState
    
    var body: some View {
        if activeState != .idle {
            SiriActiveDeliverySnippetView()
        } else if let order = order {
            PastOrderTrackingSnippetView(order: order)
        } else {
            EmptyDeliverySnippetView()
        }
    }
}

struct SaveToListIntent: AppIntent {
    static var title: LocalizedStringResource = "Save Product to List"
    static var description = IntentDescription("Saves a product to your favorited Hyperpure shopping list.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Product")
    var product: ProductEntity
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = Database.shared.context
        let id = product.id
        let descriptor = FetchDescriptor<Product>(predicate: #Predicate { $0.id == id })
        guard let dbProduct = (try? context.fetch(descriptor))?.first else {
            return .result(dialog: IntentDialog("Could not find product in catalog."))
        }
        
        MyListViewModel.shared.addFavorite(dbProduct)
        return .result(dialog: IntentDialog("Saved \(dbProduct.name) to your Hyperpure list."))
    }
}

struct ViewSavedListIntent: AppIntent {
    static var title: LocalizedStringResource = "View Saved List"
    static var description = IntentDescription("Opens the saved custom order guide list in Hyperpure.")
    static var openAppWhenRun: Bool = true
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        AppState.shared.selectedTab = 2
        return .result(dialog: IntentDialog("Showing your saved list in Hyperpure."))
    }
}

struct BuildSmartListIntent: AppIntent {
    static var title: LocalizedStringResource = "Build Smart List"
    static var description = IntentDescription("Creates a smart list by favoriting all products from your most recent order.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<Order>(sortBy: [SortDescriptor(\.placedAt, order: .reverse)])
        guard let lastOrder = (try? context.fetch(descriptor))?.first else {
            return .result(dialog: IntentDialog("You don't have any past orders to build a smart list from."))
        }
        
        MyListViewModel.shared.createSmartListFromLastOrder()
        let dialog = IntentDialog("Successfully added all \(lastOrder.items.count) items from your last order to your saved list.")
        return .result(dialog: dialog, view: SmartListCreatedSnippetView(order: lastOrder))
    }
}

struct GetWalletBalanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Wallet Balance"
    static var description = IntentDescription("Returns the remaining balance in your Hyperpure credit wallet.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let balance = AccountViewModel.shared.walletBalance
        let dialog = IntentDialog("Your Hyperpure wallet balance is \(Int(balance)) rupees.")
        return .result(dialog: dialog, view: WalletBalanceSnippetView(balance: balance))
    }
}

struct ToggleVegModeIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Veg Mode"
    static var description = IntentDescription("Turns vegetarian mode filter on or off.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Veg Mode")
    var mode: VegModeState
    
    static var parameterSummary: some ParameterSummary {
        Summary("Turn veg mode \(\.$mode)")
    }
    
    init() {}
    init(mode: VegModeState) {
        self.mode = mode
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let isOn = mode == .on
        AccountViewModel.shared.updateVegMode(isOn)
        let stateStr = isOn ? "enabled" : "disabled"
        return .result(dialog: IntentDialog("Veg mode is now \(stateStr) in Hyperpure."))
    }
}


struct GetQualityInfoIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Quality Info"
    static var description = IntentDescription("Provides copy and details of Hyperpure's food quality standards.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let dialog = IntentDialog("Hyperpure maintains premium quality standards, including temperature-controlled delivery vehicles, ISO 22000 certified hubs, and zero contamination packaging.")
        return .result(dialog: dialog, view: QualityInfoSnippetView())
    }
}

struct GetSustainabilityInfoIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Sustainability Info"
    static var description = IntentDescription("Provides details of Hyperpure's environmental and sustainability initiatives.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let dialog = IntentDialog("Hyperpure is committed to sustainability, employing biodegradable packaging, solar-powered warehouses, and routing algorithms that reduce transport carbon footprints.")
        return .result(dialog: dialog, view: SustainabilityInfoSnippetView())
    }
}

struct ReadLatestBlogPostIntent: AppIntent {
    static var title: LocalizedStringResource = "Read Latest Blog Post"
    static var description = IntentDescription("Fetches and reads the latest post from the Hyperpure sourcing blog.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let post = MockContent.blogs.first ?? BlogPost(id: 1, title: "Sourcing Excellence", excerpt: "How we ensure daily farm fresh delivery.", category: "Sourcing", readTime: "3 min read", date: "July 19, 2026", author: "Hyperpure Team")
        let dialog = IntentDialog("Reading latest post: \(post.title). \(post.excerpt)")
        return .result(dialog: dialog, view: BlogPostSnippetView(post: post))
    }
}

// MARK: - Snippet Views

struct SearchResultsSnippetView: View {
    let products: [Product]
    let query: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Search: '\(query)'")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Text("\(products.count) matches")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Theme.textSecondary)
            }
            Divider().background(Color.primary.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(products.prefix(3)) { product in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(product.name)
                                .font(.subheadline.bold())
                                .foregroundColor(Theme.textPrimary)
                            Text(product.weight)
                                .font(.caption2)
                                .foregroundColor(Theme.textMuted)
                        }
                        Spacer()
                        Text(product.formattedPrice)
                            .font(.subheadline.bold())
                            .foregroundColor(Theme.textPrimary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct CartUpdatedSnippetView: View {
    let product: Product
    let quantity: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Cart Updated")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Image(systemName: "cart.badge.plus")
                    .foregroundColor(Theme.primary)
            }
            Divider().background(Color.primary.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name)
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.textPrimary)
                    Text("Quantity in cart: \(quantity)")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                Spacer()
                Text(product.formattedPrice)
                    .font(.headline.bold())
                    .foregroundColor(Theme.textPrimary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct CartTotalSnippetView: View {
    @State private var cart = CartViewModel.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hyperpure Cart Summary")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Text("\(cart.totalItems) items")
                    .font(.caption2.bold())
                    .foregroundColor(Theme.textSecondary)
            }
            Divider().background(Color.primary.opacity(0.1))
            
            VStack(spacing: 6) {
                HStack {
                    Text("Subtotal")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Spacer()
                    Text("₹\(cart.subtotal)")
                        .font(.caption.bold())
                        .foregroundColor(Theme.textPrimary)
                }
                HStack {
                    Text("Delivery")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Spacer()
                    Text(cart.deliveryFee == 0 ? "FREE" : "₹\(cart.deliveryFee)")
                        .font(.caption.bold())
                        .foregroundColor(Theme.textPrimary)
                }
                HStack {
                    Text("Tax & Cess")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                    Spacer()
                    Text("₹\(cart.tax)")
                        .font(.caption.bold())
                        .foregroundColor(Theme.textPrimary)
                }
                Divider().background(Color.primary.opacity(0.06))
                HStack {
                    Text("Grand Total")
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    Text("₹\(cart.grandTotal)")
                        .font(.headline.bold())
                        .foregroundColor(Theme.primary)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct PastOrderTrackingSnippetView: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Order Status")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Text(order.id.prefix(8).uppercased())
                    .font(.system(.caption, design: .monospaced).bold())
                    .foregroundColor(Theme.textSecondary)
            }
            Divider().background(Color.primary.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.status.rawValue)
                        .font(.subheadline.bold())
                        .foregroundColor(order.status == .cancelled ? Color.red : Theme.success)
                    Text("Placed at \(order.placedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(Theme.textMuted)
                }
                Spacer()
                Text("₹\(order.grandTotal)")
                    .font(.headline.bold())
                    .foregroundColor(Theme.textPrimary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct SmartListCreatedSnippetView: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Smart List Created")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundColor(Theme.primary)
            }
            Divider().background(Color.primary.opacity(0.1))
            
            Text("Imported \(order.lineItems.count) items from Order #\(order.id.prefix(8).uppercased()) into your favorites guide.")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct WalletBalanceSnippetView: View {
    let balance: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hyperpure Wallet")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Image(systemName: "wallet.pass.fill")
                    .foregroundColor(Theme.primary)
            }
            Divider().background(Color.primary.opacity(0.1))
            
            HStack {
                Text("Available Balance")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text("₹\(Int(balance))")
                    .font(.title3.bold())
                    .foregroundColor(Theme.tealBadge)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct QualityInfoSnippetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quality Standards")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(Theme.primary)
            }
            Divider().background(Color.primary.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPoint(icon: "thermometer.snowflake", text: "100% Temperature-Controlled Fleet")
                BulletPoint(icon: "shield.checkerboard", text: "ISO 22000 & FSSAI Certified Hubs")
                BulletPoint(icon: "testtube.2", text: "Rigorous 100+ Parameter Testing")
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct SustainabilityInfoSnippetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Sustainability Initiatives")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Image(systemName: "leaf.fill")
                    .foregroundColor(Theme.success)
            }
            Divider().background(Color.primary.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPoint(icon: "leaf.circle.fill", text: "Biodegradable Meal Boxes & Packaging")
                BulletPoint(icon: "sun.max.fill", text: "Solar-Powered Storage Warehouses")
                BulletPoint(icon: "map.fill", text: "Eco-optimized Sourcing Routing")
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct BlogPostSnippetView: View {
    let post: BlogPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(post.category.uppercased())
                    .font(.system(.caption2, design: .rounded).weight(.black))
                    .foregroundColor(Theme.primary)
                Spacer()
                Text(post.readTime)
                    .font(.caption2)
                    .foregroundColor(Theme.textMuted)
            }
            Divider().background(Color.primary.opacity(0.1))
            
            Text(post.title)
                .font(.subheadline.bold())
                .foregroundColor(Theme.textPrimary)
                .lineLimit(2)
            
            Text(post.excerpt)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                .lineLimit(3)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct BulletPoint: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(Theme.primary)
                .frame(width: 16, height: 16)
            Text(text)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
        }
    }
}

// MARK: - Consolidated Query Sourcing Intent
struct QueryAccountOrAppIntent: AppIntent {
    static var title: LocalizedStringResource = "Query Account or Sourcing Information"
    static var description = IntentDescription("Displays account metrics, veg mode switches, blog logs, or quality guides.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Topic")
    var topic: AccountQueryTopic
    
    static var parameterSummary: some ParameterSummary {
        Summary("Show my \(\.$topic)")
    }
    
    init() {}
    init(topic: AccountQueryTopic) {
        self.topic = topic
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let dialog: IntentDialog
        
        switch topic {
        case .wallet:
            let balance = AccountViewModel.shared.walletBalance
            dialog = IntentDialog("Your Hyperpure wallet balance is ₹\(Int(balance)).")
        case .vegOn:
            AccountViewModel.shared.updateVegMode(true)
            dialog = IntentDialog("Veg mode has been enabled.")
        case .vegOff:
            AccountViewModel.shared.updateVegMode(false)
            dialog = IntentDialog("Veg mode has been disabled.")
        case .quality:
            dialog = IntentDialog("Hyperpure keeps cold-chain delivery vehicles and ISO hubs for safety.")
        case .sustainability:
            dialog = IntentDialog("Hyperpure employs eco-routing algorithms and solar cold storages.")
        case .blog:
            if let post = MockContent.blogs.first {
                dialog = IntentDialog("Reading latest sourcing blog post: \(post.title). \(post.excerpt)")
            } else {
                dialog = IntentDialog("There are no recent blog posts published.")
            }
        case .favorites:
            let context = Database.shared.context
            let count = (try? context.fetch(FetchDescriptor<SavedListItem>()))?.count ?? 0
            dialog = IntentDialog("You have \(count) items saved in your kitchen procurement list.")
        }
        
        return .result(dialog: dialog, view: AccountOrAppSnippetView(topic: topic))
    }
}

// MARK: - Consolidated Snippet Views
struct AccountOrAppSnippetView: View {
    let topic: AccountQueryTopic
    
    var body: some View {
        switch topic {
        case .wallet:
            WalletBalanceSnippetView(balance: AccountViewModel.shared.walletBalance)
        case .vegOn, .vegOff:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "leaf.circle.fill")
                        .foregroundColor(Theme.success)
                        .font(.title)
                    Text("Veg Mode Updated")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                }
                Text("Your catalog filter has been successfully updated to show \(topic == .vegOn ? "only vegetarian" : "all") items.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
        case .quality:
            QualityInfoSnippetView()
        case .sustainability:
            SustainabilityInfoSnippetView()
        case .blog:
            if let post = MockContent.blogs.first {
                BlogPostSnippetView(post: post)
            } else {
                Text("No blog posts available.")
                    .padding(16)
            }
        case .favorites:
            SavedListSnippetView()
        }
    }
}

struct SavedListSnippetView: View {
    @State private var items: [SavedListItem] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Saved Procurement List")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Image(systemName: "heart.text.square.fill")
                    .foregroundColor(Theme.primary)
            }
            Divider().background(Color.primary.opacity(0.1))
            
            if items.isEmpty {
                Text("Your saved list is empty.")
                    .font(.caption)
                    .foregroundColor(Theme.textMuted)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(items.prefix(3)) { item in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(Theme.success)
                            Text(item.product?.name ?? "Unknown Item")
                                .font(.caption)
                                .foregroundColor(Theme.textPrimary)
                        }
                    }
                    if items.count > 3 {
                        Text("+\(items.count - 3) more items")
                            .font(.caption2)
                            .foregroundColor(Theme.textMuted)
                    }
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
        .onAppear {
            let context = Database.shared.context
            let descriptor = FetchDescriptor<SavedListItem>()
            items = (try? context.fetch(descriptor)) ?? []
        }
    }
}
