// WeatherIntelligenceView.swift
// Interactive weather forecasting and automated inventory order volume optimization dashboard.

import SwiftUI
import Charts

struct WeatherIntelligenceView: View {
    @State private var viewModel = WeatherIntelligenceViewModel.shared
    @Environment(CartViewModel.self) private var cartViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Simulate Regional Weather")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Theme.textSecondary)
                    
                    Picker("Weather Condition", selection: $viewModel.currentState) {
                        ForEach(WeatherState.allCases) { state in
                            Text(state.rawValue).tag(state)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(16)
                .cardStyle()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "cpu")
                            .foregroundColor(Theme.primary)
                            .font(.title3)
                        
                        Text("Local AI Supply Briefing")
                            .font(.headline.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                        
                        Spacer()
                        
                        Text("On-Device LLM")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Theme.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Theme.primaryBg)
                            .clipShape(Capsule())
                    }
                    
                    Text(viewModel.generateAIBriefing())
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .cardStyle()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("7-Day Weather Demand Outlook")
                        .font(.headline.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Projected overall restaurant inventory demand fluctuation relative to typical weekly baseline.")
                        .font(.caption)
                        .foregroundColor(Theme.textMuted)
                    
                    Chart {
                        ForEach(viewModel.forecastData) { day in
                            BarMark(
                                x: .value("Day", day.dayName),
                                y: .value("Surge", day.projectedDemandSurge * 100)
                            )
                            .foregroundStyle(chartBarColor(day.projectedDemandSurge))
                            .cornerRadius(4)
                        }
                    }
                    .frame(height: 180)
                    .padding(.vertical, 8)
                }
                .padding(16)
                .cardStyle()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Cart Volume Optimization")
                        .font(.headline.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    if cartViewModel.items.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "cart.badge.questionmark")
                                .font(.system(size: 40))
                                .foregroundColor(Theme.textMuted)
                            
                            Text("Your Cart is Empty")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("Add items to your cart from the catalogue to simulate real-time weather ordering recommendations.")
                                .font(.caption)
                                .foregroundColor(Theme.textMuted)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(cartViewModel.items) { item in
                                let optimized = viewModel.optimizeQuantity(product: item.product, originalQuantity: item.quantity)
                                let factor = viewModel.optimizationFactor(for: item.product)
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.product.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundColor(Theme.textPrimary)
                                            .lineLimit(1)
                                        Text(item.product.category.replacingOccurrences(of: "-", with: " ").capitalized)
                                            .font(.caption2)
                                            .foregroundColor(Theme.textMuted)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 16) {
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text("Std: \(item.quantity)")
                                                .font(.caption)
                                                .foregroundColor(Theme.textSecondary)
                                            Text("Opt: \(optimized)")
                                                .font(.caption.weight(.bold))
                                                .foregroundColor(optimizedColor(factor))
                                        }
                                        
                                        if factor != 0 {
                                            Text(String(format: "%+.0f%%", factor * 100))
                                                .font(.caption2.weight(.bold))
                                                .foregroundColor(factor > 0 ? Theme.success : Theme.primary)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 3)
                                                .background(factor > 0 ? Theme.successLight : Theme.primaryBg)
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                        } else {
                                            Text("0%")
                                                .font(.caption2)
                                                .foregroundColor(Theme.textMuted)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 3)
                                                .background(Color.gray.opacity(0.1))
                                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                        }
                                    }
                                }
                                .padding(.vertical, 6)
                                
                                if item.id != cartViewModel.items.last?.id {
                                    Divider()
                                }
                            }
                            
                            Button {
                                applyOptimizations()
                            } label: {
                                Text("Apply Weather Optimization")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Theme.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                .padding(16)
                .cardStyle()
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Weather Intelligence")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func applyOptimizations() {
        for item in cartViewModel.items {
            let optimized = viewModel.optimizeQuantity(product: item.product, originalQuantity: item.quantity)
            cartViewModel.updateQuantity(for: item.product, quantity: optimized)
        }
        dismiss()
    }
    
    private func chartBarColor(_ surge: Double) -> Color {
        if surge > 0 {
            return Theme.success
        } else if surge < 0 {
            return Theme.primary
        }
        return Color.gray.opacity(0.4)
    }
    
    private func optimizedColor(_ factor: Double) -> Color {
        if factor > 0 {
            return Theme.success
        } else if factor < 0 {
            return Theme.primary
        }
        return Theme.textPrimary
    }
}
