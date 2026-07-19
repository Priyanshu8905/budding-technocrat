// WeatherIntelligenceAppIntents.swift
// Apple Intelligence integration for Feature 1: Weather Intelligence Engine.

import Foundation
import AppIntents
import SwiftUI

public enum SimulatedWeatherCondition: String, Codable, CaseIterable, AppEnum {
    case monsoon
    case heatwave
    case optimal
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Simulated Weather Condition"
    }
    
    public static var caseDisplayRepresentations: [SimulatedWeatherCondition: DisplayRepresentation] {
        [
            .monsoon: DisplayRepresentation(
                title: "Monsoon",
                subtitle: "Heavy regional rain and high humidity"
            ),
            .heatwave: DisplayRepresentation(
                title: "Heatwave",
                subtitle: "Extreme temperature and dry climate"
            ),
            .optimal: DisplayRepresentation(
                title: "Optimal",
                subtitle: "Pleasant seasonal conditions"
            )
        ]
    }
}

public struct DishRecommendation: Identifiable, Codable, Sendable {
    public let id: UUID
    public let name: String
    public let category: String
    public let rationale: String
    public let iconName: String
    
    public init(id: UUID = UUID(), name: String, category: String, rationale: String, iconName: String) {
        self.id = id
        self.name = name
        self.rationale = rationale
        self.category = category
        self.iconName = iconName
    }
}

struct ConfirmWeatherAdjustmentIntent: AppIntent {
    static var title: LocalizedStringResource = "Confirm Weather Sourcing Adjustment"
    static var description = IntentDescription("Save and apply optimized weather inventory quantities.")
    static var openAppWhenRun: Bool = false
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        return .result(dialog: IntentDialog("Weather procurement adjustments have been confirmed and applied to your inventory order."))
    }
}

struct ApplyWeatherOptimizationIntent: AppIntent {
    static var title: LocalizedStringResource = "Apply weather inventory optimization"
    static var description = IntentDescription("Optimize your kitchen menu and ingredients based on weather forecasting.")
    static var openAppWhenRun: Bool = false
    
    @Parameter(title: "Weather Condition")
    var condition: SimulatedWeatherCondition
    
    init() {}
    
    init(condition: SimulatedWeatherCondition) {
        self.condition = condition
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        // Map SimulatedWeatherCondition to WeatherState
        let targetState: WeatherState
        switch condition {
        case .monsoon:
            targetState = .monsoon
        case .heatwave:
            targetState = .heatwave
        case .optimal:
            targetState = .normal
        }
        
        // Update Weather ViewModel State (MVVM)
        WeatherIntelligenceViewModel.shared.updateWeatherState(to: targetState)
        
        // Apply optimization on current checkout cart
        let cartItems = CartViewModel.shared.items
        
        for item in cartItems {
            guard let product = item.product else { continue }
            let originalQty = item.quantity
            let optimizedQty: Int
            
            if targetState == .monsoon {
                if product.category == "fruits-vegetables" || product.category == "chicken-eggs" {
                    optimizedQty = max(1, Int(round(Double(originalQty) * 0.80)))
                } else if product.category == "frozen" || product.category == "packaging" {
                    optimizedQty = Int(ceil(Double(originalQty) * 1.15))
                } else {
                    optimizedQty = originalQty
                }
            } else if targetState == .heatwave {
                if product.category == "dairy" || product.category == "chicken-eggs" {
                    optimizedQty = max(1, Int(round(Double(originalQty) * 0.85)))
                } else if product.category == "beverages" {
                    optimizedQty = Int(ceil(Double(originalQty) * 1.30))
                } else {
                    optimizedQty = originalQty
                }
            } else {
                optimizedQty = originalQty
            }
            
            if optimizedQty != originalQty {
                CartViewModel.shared.updateQuantity(for: product, quantity: optimizedQty)
            }
        }
        
        let dialog = IntentDialog("Weather parameters processed. Reviewing recommended seasonal adjustments.")
        
        return .result(
            dialog: dialog,
            view: SiriNativeProcurementSheetView(condition: condition)
        )
    }
}

struct SiriNativeProcurementSheetView: View {
    let condition: SimulatedWeatherCondition
    
    private let layoutPadding: CGFloat = 16
    private let strokeOpacity: Double = 0.1
    private let strokeWidth: CGFloat = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Native Done Row
            HStack {
                Text("Weather Sourcing Ale...")
                    .font(.title2.bold())
                    .foregroundColor(Theme.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                Button(intent: ConfirmWeatherAdjustmentIntent()) {
                    Text("Done")
                        .font(.body.bold())
                        .foregroundColor(Theme.primary)
                }
                .buttonStyle(.plain)
            }
            
            // Content Sub-Card
            VStack(alignment: .leading, spacing: 12) {
                // Brand Header Row
                HStack(spacing: 8) {
                    Image(systemName: "sun.max.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HYPERPURE ENGINE")
                            .font(.system(.caption, design: .rounded).weight(.heavy))
                            .foregroundColor(Theme.primary)
                        Text("Climate-Adaptive Sourcing")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.textMuted)
                    }
                    Spacer()
                }
                
                Divider()
                    .background(Color.primary.opacity(0.1))
                
                // Live Status Statement
                Text("OPTIMAL SYSTEM ACTIVE: Mild seasonal climate. Supply chains are running optimally. Standard ordering baselines recommended.")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .lineSpacing(3)
                    .padding(8)
                    .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
                
                // Dish Recommendation Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recommended Focus Menu:")
                        .font(.caption.bold())
                        .foregroundColor(Theme.primary)
                    
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "circle.hexagongrid.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.primary)
                            .padding(6)
                            .background(Color.primary.opacity(0.08), in: Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("Signature Farmhouse Pizza")
                                    .font(.subheadline.bold())
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Text("Mains")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Theme.primary)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Theme.primaryBg)
                                    .clipShape(Capsule())
                            }
                            Text("Standard menu baseline driving stable margins. Normal weather conditions observed.")
                                .font(.system(size: 11))
                                .foregroundColor(Theme.textMuted)
                                .lineLimit(2)
                        }
                    }
                }
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color.primary.opacity(0.02), Color.primary.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
            )
            
            // Full-Width Red Action Button
            Button(intent: ConfirmWeatherAdjustmentIntent()) {
                Text("Confirm Procurement Adjustment")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(layoutPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(strokeOpacity), lineWidth: strokeWidth)
        )
        .padding(.horizontal, 4)
    }
}

#Preview("Siri Native Procurement Sheet View") {
    SiriNativeProcurementSheetView(condition: .optimal)
}
