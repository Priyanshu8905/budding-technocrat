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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    healthHeaderBlock
                    
                    if let item = selectedItem {
                        depletionChartBlock(for: item)
                    }
                    
                    pantryListBlock
                    
                    replenishmentBasketBlock
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Pantry Intelligence")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isShowingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
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
    
    private var healthHeaderBlock: some View {
        HStack(spacing: 12) {
            let total = viewModel.pantryItems.count
            let critical = viewModel.pantryItems.filter { $0.status == "Critical" }.count
            let warning = viewModel.pantryItems.filter { $0.status == "Warning" }.count
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Kitchen Status")
                    .font(.caption.weight(.bold))
                    .foregroundColor(Theme.textMuted)
                Text(critical > 0 ? "Shortage Risk" : "Inventory Stable")
                    .font(.headline.weight(.bold))
                    .foregroundColor(critical > 0 ? Theme.primary : Theme.success)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                StatusMetric(value: total, label: "Total")
                StatusMetric(value: warning, label: "Low", color: Theme.offer)
                StatusMetric(value: critical, label: "Critical", color: Theme.primary)
            }
        }
        .padding(16)
        .cardStyle()
    }
    
    private func depletionChartBlock(for item: PantryItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    Text("Stock depletion over time (\(item.unit))")
                        .font(.caption)
                        .foregroundColor(Theme.textMuted)
                }
                Spacer()
                Text(item.status)
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: item.status).opacity(0.1))
                    .foregroundColor(statusColor(for: item.status))
                    .clipShape(Capsule())
            }
            
            let points = projectionPoints(for: item)
            
            Chart(points) { pt in
                AreaMark(
                    x: .value("Day", pt.day),
                    y: .value("Qty", pt.quantity)
                )
                .foregroundStyle(statusColor(for: item.status).opacity(0.12))
                
                LineMark(
                    x: .value("Day", pt.day),
                    y: .value("Qty", pt.quantity)
                )
                .foregroundStyle(statusColor(for: item.status))
                .lineStyle(StrokeStyle(lineWidth: 3))
            }
            .frame(height: 140)
            .chartXScale(domain: 0...max(7, item.shelfLifeDays))
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                Label("Local AI Analysis", systemImage: "cpu.fill")
                    .font(.caption.weight(.bold))
                    .foregroundColor(Theme.primary)
                
                if isCalculatingAI {
                    ProgressView()
                        .padding(.vertical, 4)
                } else {
                    Text(aiPredictionText)
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .padding(16)
        .cardStyle()
    }
    
    private var pantryListBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingredient Decay Logs")
                .font(.headline.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            
            VStack(spacing: 8) {
                ForEach(viewModel.pantryItems) { item in
                    Button {
                        updateSelected(item)
                    } label: {
                        HStack(spacing: 12) {
                            Text(categoryEmoji(for: item.category))
                                .font(.title3)
                                .frame(width: 40, height: 40)
                                .background(Color(uiColor: .tertiarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSm))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(Theme.textPrimary)
                                Text("Remaining: \(String(format: "%.1f", item.calculatedQuantity)) \(item.unit)")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(item.remainingShelfLifeDays)d left")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(item.remainingShelfLifeDays <= 2 ? Theme.primary : Theme.textSecondary)
                                
                                Text(item.status)
                                    .font(.system(size: 10).weight(.bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(statusColor(for: item.status).opacity(0.1))
                                    .foregroundColor(statusColor(for: item.status))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(10)
                        .background(selectedItem?.id == item.id ? statusColor(for: item.status).opacity(0.05) : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusMd)
                                .stroke(selectedItem?.id == item.id ? statusColor(for: item.status).opacity(0.3) : Color.gray.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var replenishmentBasketBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Auto-Drafted Replenishment")
                .font(.headline.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            
            if viewModel.replenishmentDraft.isEmpty {
                VStack(spacing: 8) {
                    Text("Inventory levels are stable. No restocking needed.")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(14)
                .cardStyle()
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.replenishmentDraft) { product in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(Theme.textPrimary)
                                Text(product.weight)
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                            }
                            Spacer()
                            Text(product.formattedPrice)
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                        }
                        Divider()
                    }
                    
                    Button {
                        for product in viewModel.replenishmentDraft {
                            cartViewModel.add(product: product)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "cart.badge.plus")
                            Text("Add Draft to Cart")
                        }
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                    }
                }
                .padding(14)
                .cardStyle()
            }
        }
    }
    
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
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
}

struct StatusMetric: View {
    let value: Int
    let label: String
    var color: Color = Theme.textPrimary
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.title3.weight(.bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(Theme.textMuted)
        }
    }
}

#Preview {
    SmartPantryView()
        .environment(CartViewModel.shared)
        .modelContainer(for: PantryItem.self, inMemory: true)
}
