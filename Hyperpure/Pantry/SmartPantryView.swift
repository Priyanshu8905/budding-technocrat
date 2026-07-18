// SmartPantryView.swift
// Screen presenting real-time ingredient status, decay projections, and replenishment controls.

import SwiftUI
import SwiftData
import Charts

struct DepletionPoint: Identifiable {
    let id = UUID()
    let day: Int
    let quantity: Double
}

struct SmartPantryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(CartViewModel.self) private var cartViewModel
    
    @State private var viewModel = PantryViewModel()
    @State private var isShowingAddSheet = false
    @State private var selectedItem: PantryItem?
    @State private var aiPredictionText = "Select an item to view AI depletion analysis."
    @State private var isCalculatingAI = false
    @State private var searchText = ""
    @State private var selectedFilter: PantryFilter = .all
    
    enum PantryFilter: String, CaseIterable {
        case all = "All"
        case critical = "Critical"
        case warning = "Low Stock"
        case healthy = "Healthy"
    }
    
    private var filteredItems: [PantryItem] {
        var items = viewModel.pantryItems
        
        // Apply status filter
        switch selectedFilter {
        case .all: break
        case .critical: items = items.filter { $0.status == "Critical" }
        case .warning: items = items.filter { $0.status == "Warning" }
        case .healthy: items = items.filter { $0.status == "Healthy" }
        }
        
        // Apply search
        if !searchText.isEmpty {
            items = items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return items
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 12) {
                        // Custom Capsule Search Bar (matches Shop & My List tabs)
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.textPrimary)
                            
                            TextField("Search pantry items...", text: $searchText)
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
                        
                        // Filter Pills (below search bar)
                        filterPillsRow
                        
                        // Kitchen Status Card
                        healthHeaderCard
                        
                        // Depletion Chart (if item selected)
                        if let item = selectedItem {
                            depletionChartCard(for: item)
                        }
                        
                        // Pantry Items List
                        pantryItemsList
                        
                        // Replenishment Section
                        replenishmentCard
                    }
                    .padding(.bottom, 24)
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
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
                    if let first = viewModel.pantryItems.first {
                        updateSelected(first)
                    }
                }
                .presentationDragIndicator(.visible)
            }
            .onAppear {
                viewModel.setup(with: modelContext)
                if selectedItem == nil, let first = viewModel.pantryItems.first {
                    updateSelected(first)
                }
                Task {
                    await viewModel.generateReplenishmentDraft()
                }
            }
        }
    }
    
    // MARK: - Kitchen Status Card
    
    private var healthHeaderCard: some View {
        let total = viewModel.pantryItems.count
        let critical = viewModel.pantryItems.filter { $0.status == "Critical" }.count
        let warning = viewModel.pantryItems.filter { $0.status == "Warning" }.count
        let healthy = viewModel.pantryItems.filter { $0.status == "Healthy" }.count
        
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: critical > 0 ? "exclamationmark.triangle.fill" : "checkmark.shield.fill")
                        .font(.caption)
                        .foregroundColor(critical > 0 ? Theme.primary : Theme.success)
                    Text("Kitchen Status")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.textMuted)
                }
                Text(critical > 0 ? "Shortage Risk" : "Inventory Stable")
                    .font(.headline.weight(.bold))
                    .foregroundColor(critical > 0 ? Theme.primary : Theme.success)
            }
            
            Spacer()
            
            HStack(spacing: 14) {
                StatusPill(value: total, label: "Total", color: Theme.textPrimary)
                StatusPill(value: healthy, label: "Good", color: Theme.success)
                StatusPill(value: warning, label: "Low", color: Theme.offer)
                StatusPill(value: critical, label: "Critical", color: Theme.primary)
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Filter Pills
    
    private var filterPillsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PantryFilter.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        HStack(spacing: 4) {
                            if filter != .all {
                                Circle()
                                    .fill(filterColor(filter))
                                    .frame(width: 6, height: 6)
                            }
                            Text(filter.rawValue)
                        }
                        .font(.caption.weight(.bold))
                        .foregroundColor(selectedFilter == filter ? .white : Theme.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(selectedFilter == filter ? Theme.navyDark : Color.white)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.gray.opacity(0.15), lineWidth: selectedFilter == filter ? 0 : 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Depletion Chart Card
    
    private func depletionChartCard(for item: PantryItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)
                    Text("Stock depletion over time (\(item.unit))")
                        .font(.caption)
                        .foregroundColor(Theme.textMuted)
                }
                Spacer()
                Text(item.status)
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: item.status).opacity(0.12))
                    .foregroundColor(statusColor(for: item.status))
                    .clipShape(Capsule())
            }
            
            let points = projectionPoints(for: item)
            
            Chart(points) { pt in
                AreaMark(
                    x: .value("Day", pt.day),
                    y: .value("Qty", pt.quantity)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [statusColor(for: item.status).opacity(0.2), statusColor(for: item.status).opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Day", pt.day),
                    y: .value("Qty", pt.quantity)
                )
                .foregroundStyle(statusColor(for: item.status))
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
            }
            .frame(height: 130)
            .chartXScale(domain: 0...max(7, item.shelfLifeDays))
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color.gray.opacity(0.2))
                    AxisValueLabel {
                        if let day = value.as(Int.self) {
                            Text("D\(day)")
                                .font(.system(size: 9))
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color.gray.opacity(0.2))
                    AxisValueLabel {
                        if let qty = value.as(Double.self) {
                            Text("\(Int(qty))")
                                .font(.system(size: 9))
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                }
            }
            
            Divider()
            
            // AI Analysis
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "cpu.fill")
                    .font(.caption)
                    .foregroundColor(Theme.primary)
                    .frame(width: 24, height: 24)
                    .background(Theme.primary.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Local AI Analysis")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.primary)
                    
                    if isCalculatingAI {
                        HStack(spacing: 6) {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Analyzing...")
                                .font(.caption)
                                .foregroundColor(Theme.textMuted)
                        }
                    } else {
                        Text(aiPredictionText)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Pantry Items List
    
    private var pantryItemsList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Ingredient Inventory")
                    .font(.headline.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text("\(filteredItems.count) items")
                    .font(.caption)
                    .foregroundColor(Theme.textMuted)
            }
            .padding(.horizontal, 16)
            
            if filteredItems.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 36))
                        .foregroundColor(Theme.textMuted)
                    Text("No items match your filter")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(filteredItems) { item in
                        PantryRowItem(
                            item: item,
                            isSelected: selectedItem?.id == item.id,
                            onTap: { updateSelected(item) },
                            onDelete: {
                                viewModel.deleteItem(item)
                                if selectedItem?.id == item.id {
                                    selectedItem = viewModel.pantryItems.first
                                    if let s = selectedItem { updateSelected(s) }
                                }
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
    
    // MARK: - Replenishment Card
    
    private var replenishmentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(Theme.primary)
                
                Text("Auto Replenishment")
                    .font(.headline.weight(.bold))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                if viewModel.isGeneratingReplenishment {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .padding(.horizontal, 16)
            
            if viewModel.replenishmentDraft.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(Theme.success)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("All stocked up!")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Theme.textPrimary)
                        Text("Inventory levels are stable. No restocking needed.")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.replenishmentDraft.enumerated()), id: \.element.id) { index, product in
                        HStack(spacing: 12) {
                            Text(categoryEmoji(for: product.category))
                                .font(.system(size: 28))
                                .frame(width: 44, height: 44)
                                .background(Color(uiColor: .secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(Theme.textPrimary)
                                    .lineLimit(1)
                                Text(product.weight)
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                            }
                            
                            Spacer()
                            
                            Text(product.formattedPrice)
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        
                        if index < viewModel.replenishmentDraft.count - 1 {
                            Divider()
                                .padding(.leading, 70)
                        }
                    }
                    
                    Divider()
                        .padding(.top, 4)
                    
                    Button {
                        for product in viewModel.replenishmentDraft {
                            cartViewModel.add(product: product)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "cart.badge.plus")
                            Text("Add All to Cart")
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .padding(14)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func updateSelected(_ item: PantryItem) {
        selectedItem = item
        Task {
            isCalculatingAI = true
            aiPredictionText = await PantryAIProcessor.generateAIPrediction(for: item)
            isCalculatingAI = false
        }
    }
    
    private func projectionPoints(for item: PantryItem) -> [DepletionPoint] {
        var points: [DepletionPoint] = []
        let startingQty = item.currentQuantity
        let rate = item.dailyDepletionRate
        let limit = item.shelfLifeDays
        for d in 0...limit {
            let qty = max(0.0, startingQty - (rate * Double(d)))
            points.append(DepletionPoint(day: d, quantity: qty))
            if qty <= 0.0 { break }
        }
        return points
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Critical": return Theme.primary
        case "Warning": return Theme.offer
        default: return Theme.success
        }
    }
    
    private func filterColor(_ filter: PantryFilter) -> Color {
        switch filter {
        case .all: return .clear
        case .critical: return Theme.primary
        case .warning: return Theme.offer
        case .healthy: return Theme.success
        }
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
}

// MARK: - Pantry Row Item (consistent card style with other tabs)

struct PantryRowItem: View {
    let item: PantryItem
    let isSelected: Bool
    var onTap: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Category Emoji
                Text(categoryEmoji(for: item.category))
                    .font(.system(size: 28))
                    .frame(width: 48, height: 48)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                    )
                
                // Item Info
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)
                    
                    Text("\(String(format: "%.1f", item.calculatedQuantity)) \(item.unit) remaining")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                // Status & Days
                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(item.remainingShelfLifeDays)d left")
                        .font(.caption.weight(.bold))
                        .foregroundColor(item.remainingShelfLifeDays <= 2 ? Theme.primary : Theme.textSecondary)
                    
                    Text(item.status)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusColor(for: item.status).opacity(0.12))
                        .foregroundColor(statusColor(for: item.status))
                        .clipShape(Capsule())
                }
            }
            .padding(12)
            .background(isSelected ? statusColor(for: item.status).opacity(0.04) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isSelected ? statusColor(for: item.status).opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Remove from Pantry", systemImage: "trash")
            }
        }
    }
    
    private func statusColor(for status: String) -> Color {
        switch status {
        case "Critical": return Theme.primary
        case "Warning": return Theme.offer
        default: return Theme.success
        }
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
}

// MARK: - Status Pill (replaces StatusMetric)

struct StatusPill: View {
    let value: Int
    let label: String
    var color: Color = Theme.textPrimary
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.subheadline.weight(.bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(Theme.textMuted)
        }
    }
}

#Preview {
    SmartPantryView()
        .environment(CartViewModel.shared)
        .modelContainer(for: PantryItem.self, inMemory: true)
}
