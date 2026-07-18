// SmartPantryView.swift
// Screen presenting real-time ingredient status in an Apple-styled table format with native segmented control inside ScrollView.

import SwiftUI
import SwiftData

struct SmartPantryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CartViewModel.self) private var cartViewModel
    
    @State private var viewModel = PantryViewModel()
    @State private var isShowingAddSheet = false
    @State private var selectedFilter: PantryFilter = .all
    
    enum PantryFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case critical = "Critical"
        case warning = "Low Stock"
        case healthy = "Healthy"
        
        var id: String { rawValue }
    }
    
    private var filteredItems: [PantryItem] {
        var items = viewModel.pantryItems
        
        switch selectedFilter {
        case .all: break
        case .critical: items = items.filter { $0.status == "Critical" }
        case .warning: items = items.filter { $0.status == "Warning" }
        case .healthy: items = items.filter { $0.status == "Healthy" }
        }
        
        return items
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Native Segmented Control (placed inside ScrollView so it scrolls upward with content)
                    Picker("Pantry Status", selection: $selectedFilter) {
                        ForEach(PantryFilter.allCases) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    if filteredItems.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray.and.arrow.down")
                                .font(.system(size: 44))
                                .foregroundColor(Theme.textMuted)
                            Text("No Items Found")
                                .font(.headline)
                                .foregroundColor(Theme.textPrimary)
                            Text("All ingredients match standard stock level requirements.")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 64)
                    } else {
                        // Apple-styled Table Card
                        VStack(spacing: 0) {
                            // Table Header
                            HStack(spacing: 0) {
                                textHeader("INGREDIENT")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                textHeader("AMOUNT")
                                    .frame(width: 95, alignment: .trailing)
                                
                                textHeader("SHELF LIFE")
                                    .frame(width: 100, alignment: .trailing)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            
                            Divider()
                            
                            ForEach(filteredItems) { item in
                                HStack(spacing: 0) {
                                    // Column 1: Ingredient Info
                                    HStack(spacing: 12) {
                                        Text(categoryEmoji(for: item.category))
                                            .font(.system(size: 26))
                                            .frame(width: 42, height: 42)
                                            .background(Color(uiColor: .systemGroupedBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(Theme.textPrimary)
                                            
                                            Text(item.category.replacingOccurrences(of: "-", with: " ").capitalized)
                                                .font(.system(size: 10).weight(.medium))
                                                .foregroundColor(Theme.textMuted)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // Column 2: Quantity
                                    Text("\(String(format: "%.1f", item.calculatedQuantity)) \(item.unit)")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(Theme.textPrimary)
                                        .frame(width: 95, alignment: .trailing)
                                    
                                    // Column 3: Shelf Life Badge
                                    HStack {
                                        Spacer()
                                        Text("\(item.remainingShelfLifeDays)d left")
                                            .font(.system(size: 11, weight: .bold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(shelfLifeBgColor(for: item))
                                            .foregroundColor(shelfLifeTextColor(for: item))
                                            .clipShape(Capsule())
                                    }
                                    .frame(width: 100)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .contentShape(Rectangle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteItem(item)
                                    } label: {
                                        Label("Remove from Pantry", systemImage: "trash")
                                    }
                                }
                                
                                if item.id != filteredItems.last?.id {
                                    Divider()
                                        .padding(.leading, 74) // Clean Apple-styled alignment (skips icon)
                                }
                            }
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Pantry")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .foregroundColor(Theme.textPrimary)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(Color.white))
                            .overlay(Circle().stroke(Color.gray.opacity(0.15), lineWidth: 1))
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddPantryItemView { name, category, qty, unit, shelfLife, depletionRate in
                    viewModel.addItem(name: name, category: category, quantity: qty, unit: unit, shelfLife: shelfLife, depletionRate: depletionRate)
                }
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                viewModel.setup(with: modelContext)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func textHeader(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.black))
            .foregroundColor(Theme.textMuted)
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
    
    private func shelfLifeBgColor(for item: PantryItem) -> Color {
        let days = item.remainingShelfLifeDays
        if days <= 2 {
            return Theme.primary.opacity(0.12)
        } else if days <= 5 {
            return Theme.offer.opacity(0.12)
        } else {
            return Theme.success.opacity(0.12)
        }
    }
    
    private func shelfLifeTextColor(for item: PantryItem) -> Color {
        let days = item.remainingShelfLifeDays
        if days <= 2 {
            return Theme.primary
        } else if days <= 5 {
            return Theme.offer
        } else {
            return Theme.success
        }
    }
}

#Preview {
    SmartPantryView()
        .environment(CartViewModel.shared)
        .modelContainer(for: PantryItem.self, inMemory: true)
}
