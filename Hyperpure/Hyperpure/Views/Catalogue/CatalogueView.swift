import SwiftUI

struct CatalogueView: View {
    @State private var viewModel = CatalogueViewModel()
    @Environment(CartViewModel.self) private var cartViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search & Filter Bar
                VStack(spacing: 8) {
                    SearchBarView(text: $viewModel.searchQuery)
                    
                    // Horizontal Category Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryPill(title: "All", count: viewModel.productCount(for: nil), isSelected: viewModel.selectedCategoryId == nil) {
                                viewModel.selectCategory(nil)
                            }
                            
                            ForEach(viewModel.allCategories) { cat in
                                CategoryPill(title: cat.name, count: viewModel.productCount(for: cat.id), isSelected: viewModel.selectedCategoryId == cat.id) {
                                    viewModel.selectCategory(cat.id)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Theme.bgPrimary)
                
                Divider()
                
                // Products Grid
                ScrollView {
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
        }
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
