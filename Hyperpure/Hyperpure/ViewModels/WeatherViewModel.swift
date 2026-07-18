import Foundation
import CoreLocation
import Observation

#if canImport(WeatherKit)
import WeatherKit
#endif

/// Presets to allow testing the Weather Intelligence optimization formula under various climatic extremes.
enum WeatherPreset: String, CaseIterable, Identifiable, Sendable {
    case normal = "Sunny / Clear"
    case monsoon = "Monsoon Heavy Rain"
    case heatwave = "Summer Heatwave"
    case coldWave = "Cold Wave"
    
    var id: String { self.rawValue }
    
    var temperature: Double {
        switch self {
        case .normal: return 24.0
        case .monsoon: return 28.0
        case .heatwave: return 41.0
        case .coldWave: return 7.0
        }
    }
    
    var precipitationChance: Double {
        switch self {
        case .normal: return 0.05
        case .monsoon: return 0.92
        case .heatwave: return 0.00
        case .coldWave: return 0.65
        }
    }
    
    var weatherAlert: String? {
        switch self {
        case .normal: return nil
        case .monsoon: return "Heavy Monsoon Warning: Severe Flooding & Rot Risks"
        case .heatwave: return "FSSAI Safety Alert: Ambient Temp >40°C. Cold Chain Mandatory"
        case .coldWave: return "Cold Wave Advisory: Localized transport delays expected"
        }
    }
}

@Observable
final class WeatherViewModel {
    // Current Weather State
    var currentPreset: WeatherPreset = .normal
    var temperature: Double = WeatherPreset.normal.temperature
    var precipitationChance: Double = WeatherPreset.normal.precipitationChance
    var weatherAlert: String? = nil
    
    var suggestions: [WeatherAdjustedSuggestion] = []
    var isProcessing = false
    var useLiveWeatherKit = false
    
    init() {
        applyPreset(.normal, for: MockProducts.products)
    }
    
    /// Applies a preset weather condition and recalculates optimized orders for the given baseline products
    func applyPreset(_ preset: WeatherPreset, for products: [Product]) {
        self.currentPreset = preset
        self.temperature = preset.temperature
        self.precipitationChance = preset.precipitationChance
        self.weatherAlert = preset.weatherAlert
        
        recalculateSuggestions(for: products)
    }
    
    /// Recalculates ordering recommendations using the on-device optimization formula.
    func recalculateSuggestions(for products: [Product]) {
        isProcessing = true
        defer { isProcessing = false }
        
        // Define monsoon/rain decay discount factor (delta) and temp decay scale (alpha)
        let delta = 0.38
        let alpha = 0.06
        let gamma = 0.04 // demand temperature multiplier
        
        // Severe weather multiplier
        let hasSevereAlert = weatherAlert != nil
        let alertMultiplier = hasSevereAlert ? 1.15 : 1.0
        
        var newSuggestions: [WeatherAdjustedSuggestion] = []
        
        // Filter out a standard set of products for comparison (e.g. popular items or first 10 items)
        let targetProducts = products.prefix(12)
        
        for product in targetProducts {
            let sensitivity = product.weatherSensitivity
            let baseQty = Double(MockQuantity(for: product))
            
            // 1. Spoilage decay delta calculation
            let tempDiff = max(0.0, temperature - sensitivity.ambientOptimalTemp)
            let deltaDecay = delta * sensitivity.decayCoefficient * precipitationChance * (1.0 + alpha * tempDiff)
            
            // 2. Demand elasticity delta calculation
            // If positive elasticity, rain increases demand. If negative, rain drops demand.
            let deltaDemand = sensitivity.demandElasticity * precipitationChance * (1.0 + gamma * abs(temperature - 22.0))
            
            // 3. Mathematical Optimization Integration
            let factor = 1.0 + deltaDemand - deltaDecay
            let rawAdjusted = baseQty * factor * alertMultiplier
            let adjustedQty = max(0.0, round(rawAdjusted * 10) / 10) // round to 1 decimal
            
            let percentChange = baseQty > 0 ? ((adjustedQty - baseQty) / baseQty) * 100 : 0.0
            
            // Map reason code
            let reason: WeatherAdjustedSuggestion.AdjustmentReason
            if percentChange < -6.0 && sensitivity.decayCoefficient > 0.4 {
                reason = .decayPrevention
            } else if percentChange > 6.0 && sensitivity.demandElasticity > 0.2 {
                reason = .demandSurge
            } else {
                reason = .normal
            }
            
            // Build custom local explanation
            let explanation = buildExplanation(
                productName: product.name,
                percentChange: percentChange,
                reason: reason,
                preset: currentPreset
            )
            
            newSuggestions.append(
                WeatherAdjustedSuggestion(
                    id: UUID(),
                    productID: product.id,
                    productName: product.name,
                    category: product.category,
                    baseQuantity: baseQty,
                    adjustedQuantity: adjustedQty,
                    percentageChange: percentChange,
                    explanation: explanation,
                    reasonType: reason
                )
            )
        }
        
        self.suggestions = newSuggestions
    }
    
    private func buildExplanation(
        productName: String,
        percentChange: Double,
        reason: WeatherAdjustedSuggestion.AdjustmentReason,
        preset: WeatherPreset
    ) -> String {
        let pct = String(format: "%.0f%%", abs(percentChange))
        
        switch reason {
        case .decayPrevention:
            if preset == .heatwave {
                return "Ambient rot risk due to extreme heatwave. Safeguarding fresh stock quality."
            }
            return "Humidity decay threat detected. Suggested reduction of \(pct) to avoid spoilage waste."
            
        case .demandSurge:
            return "Comfort foods surge expected. Suggesting \(pct) volume expansion for rainy weather demand."
            
        case .normal:
            return "Standard order levels recommended. Weather conditions within normal safety margins."
        }
    }
    
    private func MockQuantity(for product: Product) -> Int {
        // Return a mock default quantity based on product characteristics
        switch product.category {
        case "fruits-vegetables": return 25
        case "dairy": return 15
        case "chicken-eggs": return 30
        case "frozen": return 20
        case "beverages": return 40
        default: return 10
        }
    }
    
    /// Requests live data from Apple WeatherKit (requires setup & provisioning)
    func fetchLiveWeather(for location: CLLocation, baselineProducts: [Product]) async {
        #if canImport(WeatherKit)
        guard useLiveWeatherKit else { return }
        
        await MainActor.run {
            self.isProcessing = true
        }
        
        do {
            let weather = try await WeatherService.shared.weather(for: location)
            let daily = weather.dailyForecast.first
            let precipChance = daily?.precipitationChance ?? 0.0
            let tempVal = daily?.highTemperature.converted(to: .celsius).value ?? 25.0
            let alertMsg = weather.weatherAlerts.first?.summary
            
            await MainActor.run {
                self.temperature = tempVal
                self.precipitationChance = precipChance
                self.weatherAlert = alertMsg
                self.recalculateSuggestions(for: baselineProducts)
            }
        } catch {
            print("WeatherKit Error: \(error.localizedDescription)")
        }
        #endif
    }
}
