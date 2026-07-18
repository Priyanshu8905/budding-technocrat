// WeatherIntelligenceView.swift
// Screen showing today's weather condition and recommended restock items based on pantry status.

import SwiftUI
import Charts
import SwiftData

struct WeatherIntelligenceView: View {
    @State private var viewModel = WeatherIntelligenceViewModel.shared
    @Environment(CartViewModel.self) private var cartViewModel
    @Environment(\.dismiss) private var dismiss
    @Query private var pantryItems: [PantryItem]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 1. Today's Weather Header Card
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TODAY'S WEATHER")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(Theme.textMuted)
                            
                            Text(viewModel.currentState.rawValue)
                                .font(.title2.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: weatherIconName)
                            .font(.system(size: 40))
                            .foregroundColor(weatherCardColor)
                            .shadow(color: weatherCardColor.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    
                    Divider()
                    
                    HStack(spacing: 20) {
                        WeatherMetricView(icon: "thermometer.medium", value: "\(Int(viewModel.temperature))°C", label: "Temp")
                        WeatherMetricView(icon: "cloud.rain.fill", value: "\(Int(viewModel.precipitationProbability * 100))%", label: "Rain Prob")
                        WeatherMetricView(icon: "humidity.fill", value: "\(Int(viewModel.humidity * 100))%", label: "Humidity")
                    }
                    
                    if let warning = viewModel.activeWarning {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(Theme.primary)
                            Text(warning)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Theme.primary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Theme.primary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                
                // 2. Restock Suggestions Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundColor(weatherCardColor)
                        Text("Recommended Restocks")
                            .font(.headline.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                    }
                    
                    if productsToSuggest.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(Theme.success)
                            Text("All items fully stocked!")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            Text("Your pantry has sufficient stock for current weather conditions.")
                                .font(.caption)
                                .foregroundColor(Theme.textMuted)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    } else {
                        Text("These items are recommended to be restocked based on today's weather condition.")
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                        
                        VStack(spacing: 10) {
                            ForEach(productsToSuggest) { product in
                                HStack(spacing: 12) {
                                    Text(categoryEmoji(for: product.category))
                                        .font(.system(size: 24))
                                        .frame(width: 40, height: 40)
                                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(product.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(Theme.textPrimary)
                                            .lineLimit(1)
                                        
                                        HStack(spacing: 6) {
                                            Text(product.formattedPrice)
                                                .font(.caption.weight(.bold))
                                                .foregroundColor(Theme.textSecondary)
                                            
                                            let pantryItem = pantryItems.first { item in
                                                let itemName = item.name.lowercased()
                                                let prodName = product.name.lowercased()
                                                return itemName.contains(prodName) || prodName.contains(itemName)
                                            }
                                            
                                            if let item = pantryItem {
                                                Text(item.calculatedQuantity <= 0 ? "Out of Stock" : "Low Stock")
                                                    .font(.system(size: 8, weight: .bold))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Theme.primary.opacity(0.12))
                                                    .foregroundColor(Theme.primary)
                                                    .clipShape(Capsule())
                                            } else {
                                                Text("Not in Pantry")
                                                    .font(.system(size: 8, weight: .bold))
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(Theme.bestRateBlue.opacity(0.12))
                                                    .foregroundColor(Theme.bestRateBlue)
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    let qty = cartViewModel.quantity(for: product)
                                    if qty > 0 {
                                        HStack(spacing: 8) {
                                            Button {
                                                cartViewModel.updateQuantity(for: product, quantity: qty - 1)
                                            } label: {
                                                Image(systemName: "minus")
                                                    .font(.caption2.weight(.bold))
                                                    .foregroundColor(Theme.primary)
                                            }
                                            
                                            Text("\(qty)")
                                                .font(.caption.weight(.bold))
                                            
                                            Button {
                                                cartViewModel.updateQuantity(for: product, quantity: qty + 1)
                                            } label: {
                                                Image(systemName: "plus")
                                                    .font(.caption2.weight(.bold))
                                                    .foregroundColor(Theme.primary)
                                            }
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(.regularMaterial)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Theme.primary.opacity(0.3), lineWidth: 1)
                                        )
                                    } else {
                                        Button {
                                            cartViewModel.add(product: product)
                                        } label: {
                                            Text("ADD")
                                                .font(.caption2.weight(.bold))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(Theme.primary)
                                                .foregroundColor(.white)
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        }
                        
                        Button {
                            for product in productsToSuggest {
                                if cartViewModel.quantity(for: product) == 0 {
                                    cartViewModel.add(product: product)
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "cart.badge.plus")
                                Text("Add All to Cart")
                            }
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.primary)
                            .clipShape(Capsule())
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(18)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Weather Predictions")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Weather Restock Helpers
    
    private var weatherCardColor: Color {
        switch viewModel.currentState {
        case .normal: return Color.green
        case .monsoon: return Color.blue
        case .heatwave: return Color.orange
        case .winterCold: return Color.cyan
        }
    }
    
    private var weatherIconName: String {
        switch viewModel.currentState {
        case .normal: return "sun.max.fill"
        case .monsoon: return "cloud.rain.fill"
        case .heatwave: return "thermometer.sun.fill"
        case .winterCold: return "snowflake"
        }
    }
    
    private func categoryEmoji(for categoryId: String) -> String {
        MockCategories.categories.first(where: { $0.id == categoryId })?.icon ?? "📦"
    }
    
    private func isProductInStockInPantry(_ product: Product) -> Bool {
        pantryItems.contains { item in
            let itemName = item.name.lowercased()
            let prodName = product.name.lowercased()
            let isMatch = itemName.contains(prodName) || prodName.contains(itemName)
            return isMatch && item.calculatedQuantity > 0 && item.status != "Critical"
        }
    }
    
    private var productsToSuggest: [Product] {
        let weatherState = viewModel.currentState
        let weatherSuggestedProducts: [Product]
        switch weatherState {
        case .normal:
            weatherSuggestedProducts = MockProducts.products.filter { [1, 301, 402].contains($0.id) }
        case .monsoon:
            weatherSuggestedProducts = MockProducts.products.filter { [11, 12, 13].contains($0.id) }
        case .heatwave:
            weatherSuggestedProducts = MockProducts.products.filter { [102, 402, 203].contains($0.id) }
        case .winterCold:
            weatherSuggestedProducts = MockProducts.products.filter { [801, 401, 11].contains($0.id) }
        }
        
        return weatherSuggestedProducts.filter { !isProductInStockInPantry($0) }
    }
}

struct WeatherMetricView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
}
