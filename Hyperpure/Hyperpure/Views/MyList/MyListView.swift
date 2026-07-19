import SwiftUI
import SwiftData

struct MyListView: View {
    var onStartShopping: (() -> Void)?
    var onOpenCart: (() -> Void)?
    
    @State private var myListViewModel = MyListViewModel.shared
    @Environment(CartViewModel.self) private var cartViewModel
    @State private var searchText = ""
    @State private var selectedCategoryId: String? = nil
    @State private var isSmartListSheetPresented = false
    
    // Get unique categories for items currently in the list
    var availableCategories: [Category] {
        let activeCategories = Set(myListViewModel.items.map { $0.category })
        return MockCategories.categories.filter { activeCategories.contains($0.id) }
    }
    
    // Filtered favorites list based on search or category filter
    var filteredFavorites: [Product] {
        let items = myListViewModel.items
        if let categoryId = selectedCategoryId {
            return items.filter { $0.category == categoryId }
        }
        return items
    }
    
    // Global catalog search results
    var searchResults: [Product] {
        if searchText.isEmpty {
            return []
        }
        let descriptor = FetchDescriptor<Product>()
        let products = (try? Database.shared.context.fetch(descriptor)) ?? []
        return products.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.productDescription.localizedCaseInsensitiveContains(searchText) ||
            $0.subcategory.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 12) {
                        // Custom Capsule Search Bar (matches Shop tab search bar)
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                            
                            TextField("Search products...", text: $searchText)
                                .font(.subheadline)
                                .autocorrectionDisabled()
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Theme.textMuted)
                                        .font(.system(size: 15))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(.regularMaterial)
                                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.8), .white.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .padding(.bottom, 4)
                        
                        if !searchText.isEmpty {
                            // Search Results Mode
                            LazyVStack(spacing: 12) {
                                HStack {
                                    Text("Search Results")
                                        .font(.headline)
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                
                                if searchResults.isEmpty {
                                    ContentUnavailableView {
                                        Label("No items found", systemImage: "magnifyingglass")
                                    } description: {
                                        Text("Try searching for something else, like 'eggs' or 'patty'.")
                                    }
                                } else {
                                    ForEach(searchResults) { product in
                                        MyListRowItem(
                                            product: product,
                                            isFavorite: myListViewModel.isFavorite(product),
                                            onToggleFavorite: {
                                                myListViewModel.toggleFavorite(product)
                                            }
                                        )
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                        } else if myListViewModel.items.isEmpty {
                            // Empty Favorites State
                            VStack(spacing: 24) {
                                Spacer(minLength: 40)
                                
                                // Native-looking list/heart graphic
                                ZStack {
                                    Circle()
                                        .fill(Theme.primaryBg)
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "heart.text.square.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(Theme.primary)
                                }
                                
                                VStack(spacing: 8) {
                                    Text("Your List is Empty")
                                        .font(.title2.weight(.bold))
                                        .foregroundColor(Theme.textPrimary)
                                    
                                    Text("Create custom order guides or favorite items to restock your outlet instantly.")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 40)
                                }
                                
                                HStack(spacing: 14) {
                                    Button {
                                        onStartShopping?()
                                    } label: {
                                        Text("Explore Catalogue")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(Theme.primary)
                                            .clipShape(Capsule())
                                    }
                                    
                                    Button {
                                        isSmartListSheetPresented = true
                                    } label: {
                                        Label("Smart List", systemImage: "sparkles")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(Theme.primary)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(Theme.primary.opacity(0.12))
                                            .clipShape(Capsule())
                                    }
                                }
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                
                                // Recommended Section (Popular items to build list)
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Recommended for You")
                                        .font(.headline)
                                        .foregroundColor(Theme.textPrimary)
                                        .padding(.horizontal, 16)
                                    
                                    let descriptor = FetchDescriptor<Product>()
                                    let products = (try? Database.shared.context.fetch(descriptor)) ?? []
                                    let popularProducts = products.filter { $0.isPopular }
                                    LazyVStack(spacing: 12) {
                                        ForEach(popularProducts.prefix(8)) { product in
                                            MyListRowItem(
                                                product: product,
                                                isFavorite: myListViewModel.isFavorite(product),
                                                onToggleFavorite: {
                                                    myListViewModel.toggleFavorite(product)
                                                }
                                            )
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                }
                            }
                        } else {
                            // Category Filter (Segmented control)
                            Picker("Category", selection: $selectedCategoryId) {
                                Text("All").tag(nil as String?)
                                ForEach(availableCategories) { cat in
                                    Text("\(cat.icon) \(cat.shortName)").tag(cat.id as String?)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                            
                            // Summary bar / Quick Actions Card
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(myListViewModel.items.count) Items saved")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(Theme.textPrimary)
                                    Text("Quick restock your kitchen")
                                        .font(.caption)
                                        .foregroundColor(Theme.textSecondary)
                                }
                                
                                Spacer()
                                
                                Button {
                                    for product in myListViewModel.items {
                                        if cartViewModel.quantity(for: product) == 0 {
                                            cartViewModel.add(product: product)
                                        }
                                    }
                                } label: {
                                    Label("Add all", systemImage: "cart.badge.plus")
                                        .font(.caption2.weight(.bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Theme.primary)
                                        .clipShape(Capsule())
                                }
                                
                                Button {
                                    isSmartListSheetPresented = true
                                } label: {
                                    Image(systemName: "sparkles")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(Theme.primary)
                                        .padding(8)
                                        .background(Theme.primary.opacity(0.12))
                                        .clipShape(Circle())
                                }
                                
                                Button {
                                    for product in myListViewModel.items {
                                        myListViewModel.removeFavorite(product)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                        .padding(8)
                                        .background(Color.red.opacity(0.1))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                            
                            // List items
                            LazyVStack(spacing: 12) {
                                ForEach(filteredFavorites) { product in
                                    MyListRowItem(
                                        product: product,
                                        isFavorite: myListViewModel.isFavorite(product),
                                        onToggleFavorite: {
                                            myListViewModel.toggleFavorite(product)
                                        }
                                    )
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .navigationTitle("My List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onOpenCart?()
                    } label: {
                        ZStack {
                            Image(systemName: "cart")
                                .font(.body)
                                .foregroundColor(Theme.textPrimary)
                                .frame(width: 38, height: 38)
                                .background(Circle().fill(Color.white))
                                .overlay(Circle().stroke(Color.gray.opacity(0.15), lineWidth: 1))
                            
                            if cartViewModel.totalItems > 0 {
                                Text("\(cartViewModel.totalItems)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Theme.primary)
                                    .clipShape(Circle())
                                    .offset(x: 12, y: -12)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $isSmartListSheetPresented) {
                SmartListsView()
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct MyListRowItem: View {
    let product: Product
    let isFavorite: Bool
    var onToggleFavorite: () -> Void
    
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Emoji Icon
            Text(categoryEmoji(for: product.category))
                .font(.system(size: 32))
                .frame(width: 52, height: 52)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                
                Text(product.weight)
                    .font(.caption)
                    .foregroundColor(Theme.textMuted)
                
                Text(product.formattedPrice)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
            }
            
            Spacer()
            
            // Add/Edit Cart Controls
            let qty = cartViewModel.quantity(for: product)
            if qty > 0 {
                HStack(spacing: 8) {
                    Button {
                        cartViewModel.updateQuantity(for: product, quantity: qty - 1)
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.primary)
                    }
                    
                    Text("\(qty)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Button {
                        cartViewModel.updateQuantity(for: product, quantity: qty + 1)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.primary)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Theme.primary.opacity(0.3), lineWidth: 1)
                )
            } else {
                Button {
                    cartViewModel.add(product: product)
                } label: {
                    Text("ADD")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(Theme.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Theme.primary.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            
            // Favorite Button
            Button {
                onToggleFavorite()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.body)
                    .foregroundColor(isFavorite ? .red : .gray.opacity(0.6))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
}

#Preview {
    MyListView()
        .environment(CartViewModel.shared)
}
