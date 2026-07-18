import SwiftUI
import Charts

struct WeatherDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CartViewModel.self) private var cartViewModel
    
    let weatherViewModel: WeatherViewModel
    
    // State to show toast success feedback
    @State private var showSuccessToast = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Weather Status Header Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Active Climatic Engine")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white.opacity(0.8))
                                .tracking(1.5)
                            
                            Text(weatherViewModel.currentPreset.rawValue)
                                .font(.title2.weight(.black))
                                .foregroundColor(.white)
                            
                            Text("The optimization formula has recalibrated quantities based on on-device historical decay risks and demand shifts.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.top, 4)
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(
                                colors: [Theme.navyDark, Color(red: 38/255, green: 48/255, blue: 85/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                        
                        // Swift Charts comparison
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Quantity Optimization Comparison (kg / units)")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Chart {
                                ForEach(weatherViewModel.suggestions) { item in
                                    BarMark(
                                        x: .value("Product", abbreviate(item.productName)),
                                        y: .value("Baseline", item.baseQuantity)
                                    )
                                    .foregroundStyle(Color.gray.opacity(0.25))
                                    .position(by: .value("Type", "Baseline"))
                                    
                                    BarMark(
                                        x: .value("Product", abbreviate(item.productName)),
                                        y: .value("Weather Shield", item.adjustedQuantity)
                                    )
                                    .foregroundStyle(item.percentageChange < 0 ? Theme.primary : Theme.success)
                                    .position(by: .value("Type", "Optimized"))
                                }
                            }
                            .frame(height: 180)
                            .padding(.top, 8)
                            
                            // Legend
                            HStack(spacing: 16) {
                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 14, height: 14)
                                    Text("Base Order")
                                        .font(.caption2)
                                        .foregroundColor(Theme.textSecondary)
                                }
                                
                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Theme.primary)
                                        .frame(width: 14, height: 14)
                                    Text("Reduced (Decay prevention)")
                                        .font(.caption2)
                                        .foregroundColor(Theme.textSecondary)
                                }
                                
                                HStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Theme.success)
                                        .frame(width: 14, height: 14)
                                    Text("Increased (Surge demand)")
                                        .font(.caption2)
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.radiusMd)
                                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                        )
                        
                        // Recommendations list Header
                        Text("Optimized Order Suggestions")
                            .font(.headline.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                            .padding(.top, 8)
                        
                        // Detailed rows
                        VStack(spacing: 12) {
                            ForEach(weatherViewModel.suggestions) { item in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.productName)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundColor(Theme.textPrimary)
                                            
                                            // Badge for categorization
                                            reasonBadge(for: item.reasonType)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 2) {
                                            HStack(spacing: 6) {
                                                Text("\(Int(item.baseQuantity))")
                                                    .font(.caption)
                                                    .foregroundColor(Theme.textMuted)
                                                    .strikethrough()
                                                
                                                Text("\(Int(item.adjustedQuantity)) kg")
                                                    .font(.subheadline.weight(.bold))
                                                    .foregroundColor(Theme.textPrimary)
                                            }
                                            
                                            HStack(spacing: 2) {
                                                Image(systemName: item.percentageChange < 0 ? "arrow.down" : (item.percentageChange > 0 ? "arrow.up" : "minus"))
                                                Text(String(format: "%.0f%%", abs(item.percentageChange)))
                                            }
                                            .font(.caption2.weight(.bold))
                                            .foregroundColor(item.percentageChange < 0 ? Theme.primary : (item.percentageChange > 0 ? Theme.success : Theme.textMuted))
                                        }
                                    }
                                    
                                    if !item.explanation.isEmpty {
                                        Text(item.explanation)
                                            .font(.caption)
                                            .foregroundColor(Theme.textSecondary)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Theme.bgSecondary)
                                            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSm))
                                    }
                                }
                                .padding(12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.radiusMd)
                                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.bottom, 100) // extra padding to avoid overlapping the floating button
                    }
                    .padding(16)
                }
                .background(Color(uiColor: .systemGroupedBackground))
                
                // Floating Action Button to apply optimization to cart
                VStack {
                    Spacer()
                    Button {
                        // Apply all weather suggestions to cart
                        withAnimation {
                            // First, make sure items are added to cart if not present
                            addSuggestionsToCart()
                            cartViewModel.applyWeatherAdjustments(suggestions: weatherViewModel.suggestions)
                            showSuccessToast = true
                        }
                        
                        // Hide toast and dismiss sheet after short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            showSuccessToast = false
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.shield.fill")
                            Text("Apply Weather Shield to Cart")
                                .font(.subheadline.weight(.bold))
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .background(Theme.primary)
                        .clipShape(Capsule())
                        .shadow(color: Theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
                
                // Success Toast Overlay
                if showSuccessToast {
                    VStack {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                            Text("Cart successfully optimized!")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Theme.navyDark)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationTitle("Weather Shield Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Theme.primary)
                    .font(.subheadline.weight(.bold))
                }
            }
        }
    }
    
    private func addSuggestionsToCart() {
        // Look up corresponding products from MockProducts and add them to the cart first if they aren't already there
        for suggestion in weatherViewModel.suggestions {
            if let product = MockProducts.products.first(where: { $0.id == suggestion.productID }) {
                // If quantity is 0 in cart, insert it
                if cartViewModel.quantity(for: product) == 0 {
                    cartViewModel.updateQuantity(for: product, quantity: Int(suggestion.baseQuantity))
                }
            }
        }
    }
    
    private func abbreviate(_ name: String) -> String {
        let clean = name.replacingOccurrences(of: "Boneless Cleaned", with: "")
                        .replacingOccurrences(of: "(30 Pcs/Tray)", with: "")
                        .replacingOccurrences(of: "(9 mm)", with: "")
                        .replacingOccurrences(of: "Eggless Mayonnaise Professional", with: "Mayo")
                        .replacingOccurrences(of: ", 2.5 Kg", with: "")
                        .replacingOccurrences(of: " gm", with: "")
                        .replacingOccurrences(of: " gm", with: "")
        
        let components = clean.components(separatedBy: " - ")
        let primaryName = components.last ?? clean
        
        let words = primaryName.split(separator: " ")
        if words.count > 2 {
            return "\(words[0]) \(words[1])..."
        }
        return primaryName
    }
    
    @ViewBuilder
    private func reasonBadge(for reason: WeatherAdjustedSuggestion.AdjustmentReason) -> some View {
        switch reason {
        case .decayPrevention:
            Text("Decay Mitigation")
                .font(.system(size: 9, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Theme.primaryBg)
                .foregroundColor(Theme.primary)
                .clipShape(Capsule())
            
        case .demandSurge:
            Text("Demand Expansion")
                .font(.system(size: 9, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Theme.successLight)
                .foregroundColor(Theme.success)
                .clipShape(Capsule())
            
        case .normal:
            EmptyView()
        }
    }
}

#Preview {
    WeatherDetailView(weatherViewModel: WeatherViewModel())
        .environment(CartViewModel())
}
