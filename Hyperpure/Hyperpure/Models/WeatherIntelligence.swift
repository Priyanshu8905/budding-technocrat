import Foundation

/// Defines how weather impacts product decay and demand dynamics.
struct WeatherSensitivityProfile: Codable, Sendable {
    /// Coefficient representing sensitivity to heat & humidity/moisture (0.0 = impervious, 1.0 = highly perishable).
    let decayCoefficient: Double
    /// Elasticity of consumer demand against inclement weather (negative = drops in rain, positive = surges).
    let demandElasticity: Double
    /// Optimal ambient storage temperature in Celsius (used to trigger temperature variance alerts).
    let ambientOptimalTemp: Double
}

/// A structured suggestion optimized by on-device math equations.
struct WeatherAdjustedSuggestion: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let productID: Int
    let productName: String
    let category: String
    let baseQuantity: Double
    let adjustedQuantity: Double
    let percentageChange: Double
    let explanation: String
    let reasonType: AdjustmentReason
    
    enum AdjustmentReason: String, Codable {
        case decayPrevention // Monsoon / Humidity rot risk
        case demandSurge     // Rainy day comfort food surge
        case normal          // Low deviation, standard baseline
    }
}

extension Product {
    /// Maps category & product keywords to realistic weather-demand sensitivity profiles.
    var weatherSensitivity: WeatherSensitivityProfile {
        switch category {
        case "fruits-vegetables":
            let lowerName = name.lowercased()
            if lowerName.contains("spinach") || lowerName.contains("coriander") || lowerName.contains("mint") || lowerName.contains("greens") || lowerName.contains("leaf") || lowerName.contains("herbs") {
                return WeatherSensitivityProfile(decayCoefficient: 0.85, demandElasticity: -0.45, ambientOptimalTemp: 8.0)
            }
            return WeatherSensitivityProfile(decayCoefficient: 0.45, demandElasticity: -0.15, ambientOptimalTemp: 14.0)
            
        case "dairy":
            return WeatherSensitivityProfile(decayCoefficient: 0.75, demandElasticity: 0.1, ambientOptimalTemp: 4.0)
            
        case "chicken-eggs":
            return WeatherSensitivityProfile(decayCoefficient: 0.65, demandElasticity: 0.25, ambientOptimalTemp: 4.0)
            
        case "frozen":
            // Frozen snacks & instant food surge in rain
            return WeatherSensitivityProfile(decayCoefficient: 0.05, demandElasticity: 0.55, ambientOptimalTemp: -18.0)
            
        case "beverages":
            let lowerName = name.lowercased()
            if lowerName.contains("tea") || lowerName.contains("coffee") || lowerName.contains("cocoa") || lowerName.contains("mix") {
                return WeatherSensitivityProfile(decayCoefficient: 0.05, demandElasticity: 0.65, ambientOptimalTemp: 25.0)
            }
            // Cold beverages drop during heavy rain/cold weather
            return WeatherSensitivityProfile(decayCoefficient: 0.1, demandElasticity: -0.35, ambientOptimalTemp: 18.0)
            
        case "bakery":
            return WeatherSensitivityProfile(decayCoefficient: 0.35, demandElasticity: 0.2, ambientOptimalTemp: 20.0)
            
        default:
            // Packaging, cleaning, canned items have minimal weather impact
            return WeatherSensitivityProfile(decayCoefficient: 0.02, demandElasticity: 0.0, ambientOptimalTemp: 25.0)
        }
    }
}
