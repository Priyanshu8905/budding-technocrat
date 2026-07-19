import SwiftUI

struct CatalogueView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var viewModel = CatalogueViewModel.shared
    @Environment(CartViewModel.self) private var cartViewModel
    
    init(initialCategoryId: String? = nil) {
        if let initialCategoryId = initialCategoryId {
            CatalogueViewModel.shared.selectedCategoryId = initialCategoryId
        }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Scrollable Native Segmented Category Picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            let isAllSelected = viewModel.selectedCategoryId == nil
                            Button {
                                viewModel.selectCategory(nil)
                            } label: {
                                HStack(spacing: 4) {
                                    Text("All")
                                        .font(.subheadline.weight(.semibold))
                                    Text("(\(viewModel.productCount(for: nil)))")
                                        .font(.caption2.weight(.medium))
                                        .opacity(0.8)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(isAllSelected ? Color(uiColor: .label) : Color(uiColor: .tertiarySystemFill))
                                .foregroundColor(isAllSelected ? Color(uiColor: .systemBackground) : Theme.textPrimary)
                                .clipShape(Capsule())
                                .shadow(color: isAllSelected ? Color.black.opacity(0.12) : Color.clear, radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            .sensoryFeedback(.impact(weight: .light), trigger: isAllSelected)
                            
                            ForEach(viewModel.allCategories) { cat in
                                let isSelected = viewModel.selectedCategoryId == cat.id
                                Button {
                                    viewModel.selectCategory(cat.id)
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(cat.shortName)
                                            .font(.subheadline.weight(.semibold))
                                        Text("(\(viewModel.productCount(for: cat.id)))")
                                            .font(.caption2.weight(.medium))
                                            .opacity(0.8)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(isSelected ? Color(uiColor: .label) : Color(uiColor: .tertiarySystemFill))
                                    .foregroundColor(isSelected ? Color(uiColor: .systemBackground) : Theme.textPrimary)
                                    .clipShape(Capsule())
                                    .shadow(color: isSelected ? Color.black.opacity(0.12) : Color.clear, radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(.plain)
                                .sensoryFeedback(.impact(weight: .light), trigger: isSelected)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    
                    // Products Grid Header & Content
                    HStack {
                        Text("\(viewModel.filteredProducts.count) Items")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(Theme.textMuted)
                        Spacer()
                        
                        Menu {
                            Picker("Sort By", selection: $viewModel.selectedSort) {
                                ForEach(SortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.selectedSort.rawValue)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(Theme.primary)
                                Image(systemName: "chevron.down")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(Theme.primary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.filteredProducts) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductCardView(product: product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .navigationTitle("Browse Catalogue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(uiColor: .systemGroupedBackground), for: .navigationBar)
            .searchable(text: $viewModel.searchQuery, prompt: "Search items or categories...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                    }
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

struct CategoryPill: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                Text("(\(count))")
                    .font(.caption2)
                    .opacity(0.8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Theme.primary : Color(uiColor: .secondarySystemGroupedBackground))
            .foregroundColor(isSelected ? .white : Theme.textPrimary)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    CatalogueView()
        .environment(CartViewModel())
}
