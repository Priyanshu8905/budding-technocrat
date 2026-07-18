// WeatherIntelligenceViewModel.swift
// ViewModel managing simulated weather metrics, demand predictions, optimization formulas, and cart integrations.

import Foundation
import Observation

@Observable
@MainActor
final class WeatherIntelligenceViewModel {
    var currentState: WeatherState = .normal
    
    var temperature: Double {
        switch currentState {
        case .normal: return 28.0
        case .monsoon: return 24.0
        case .heatwave: return 41.0
        case .winterCold: return 12.0
        }
    }
    
    var precipitationProbability: Double {
        switch currentState {
        case .normal: return 0.05
        case .monsoon: return 0.95
        case .heatwave: return 0.02
        case .winterCold: return 0.10
        }
    }
    
    var humidity: Double {
        switch currentState {
        case .normal: return 0.55
        case .monsoon: return 0.92
        case .heatwave: return 0.25
        case .winterCold: return 0.40
        }
    }
    
    var activeWarning: String? {
        switch currentState {
        case .normal:
            return nil
        case .monsoon:
            return "Severe Rain Warning - Monsoon Active"
        case .heatwave:
            return "Extreme Heat Alert - High Spoilage Risk"
        case .winterCold:
            return "Cold Wave Advisory - Demand Shift"
        }
    }
    
    var weatherSnapshot: WeatherSnapshot {
        WeatherSnapshot(
            state: currentState,
            temperature: temperature,
            precipitationProbability: precipitationProbability,
            humidity: humidity,
            activeWarning: activeWarning
        )
    }
    
    var forecastData: [WeatherForecastDay] {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        switch currentState {
        case .normal:
            return days.map { WeatherForecastDay(dayName: $0, projectedDemandSurge: Double.random(in: -0.02...0.02), weatherIcon: "sun.max.fill") }
        case .monsoon:
            let surges = [0.10, 0.25, 0.30, 0.22, 0.15, 0.08, 0.02]
            return zip(days, surges).map { WeatherForecastDay(dayName: $0.0, projectedDemandSurge: $0.1, weatherIcon: "cloud.rain.fill") }
        case .heatwave:
            let surges = [0.05, 0.15, 0.35, 0.40, 0.30, 0.20, 0.10]
            return zip(days, surges).map { WeatherForecastDay(dayName: $0.0, projectedDemandSurge: $0.1, weatherIcon: "thermometer.sun.fill") }
        case .winterCold:
            let surges = [0.12, 0.20, 0.25, 0.22, 0.18, 0.15, 0.08]
            return zip(days, surges).map { WeatherForecastDay(dayName: $0.0, projectedDemandSurge: $0.1, weatherIcon: "snowflake") }
        }
    }
    
    func updateWeatherState(to state: WeatherState) {
        currentState = state
    }
    
    func optimizationFactor(for product: Product) -> Double {
        switch currentState {
        case .normal:
            return 0.0
        case .monsoon:
            if isDelicateGreen(product) {
                return -0.30
            } else if isComfortFood(product) {
                return 0.25
            }
            return 0.0
        case .heatwave:
            if isHighSpoilage(product) {
                return -0.15
            } else if isCoolingBeverage(product) {
                return 0.30
            }
            return 0.0
        case .winterCold:
            if isComfortFood(product) || isWarmBeverage(product) {
                return 0.20
            }
            return 0.0
        }
    }
    
    func optimizeQuantity(product: Product, originalQuantity: Int) -> Int {
        guard originalQuantity > 0 else { return 0 }
        let factor = optimizationFactor(for: product)
        let adjusted = Double(originalQuantity) * (1.0 + factor)
        return max(1, Int(round(adjusted)))
    }
    
    func generateAIBriefing() -> String {
        switch currentState {
        case .normal:
            return "WEATHER ADVISORY: Normal weather conditions. Supply chains are running optimally. Standard ordering schedules recommended."
        case .monsoon:
            return "WEATHER ALERT: Monsoon warning active. Regional humidity spiked to 92%, causing a 2.4x acceleration in decay rates of fresh greens. On-device engine has scaled down delicate greens by 30% to prevent spoilage. Concurrently, comfort food demand is projected to surge by 25% due to rain-induced delivery spikes; stock expanded accordingly."
        case .heatwave:
            return "WEATHER ALERT: Extreme Heat warning active. High ambient temperatures (41°C) increase spoilage risks for dairy and meats. On-device engine has reduced procurement of dairy/meat items by 15% and boosted beverage stocks by 30% to match cooling demand."
        case .winterCold:
            return "WEATHER ALERT: Cold Wave active. Temperature dropped to 12°C, prompting a 20% shift in consumer preference toward warm beverages and ready-to-cook hot appetizers. Greens spoilage risk is nominal, but frozen comfort foods have been prioritized."
        }
    }
    
    private func isDelicateGreen(_ product: Product) -> Bool {
        let nameLower = product.name.lowercased()
        let descLower = product.description.lowercased()
        let greenKeywords = ["green", "leaf", "coriander", "spinach", "mint", "lettuce", "cabbage", "herbs"]
        let matchesKeyword = greenKeywords.contains(where: { nameLower.contains($0) || descLower.contains($0) })
        return product.category == "fruits-vegetables" && matchesKeyword
    }
    
    private func isComfortFood(_ product: Product) -> Bool {
        let nameLower = product.name.lowercased()
        return product.category == "frozen" || nameLower.contains("mccain") || nameLower.contains("fries") || nameLower.contains("patty")
    }
    
    private func isHighSpoilage(_ product: Product) -> Bool {
        let nameLower = product.name.lowercased()
        let matchesDairyOrMeat = product.category == "dairy" || product.category == "chicken-eggs" || product.subcategory.lowercased().contains("chicken") || product.subcategory.lowercased().contains("eggs")
        return matchesDairyOrMeat || nameLower.contains("milk") || nameLower.contains("paneer")
    }
    
    private func isCoolingBeverage(_ product: Product) -> Bool {
        let nameLower = product.name.lowercased()
        let coolingKeywords = ["juice", "soda", "drink", "cola", "beverage", "shake"]
        return product.category == "beverages" && coolingKeywords.contains(where: { nameLower.contains($0) })
    }
    
    private func isWarmBeverage(_ product: Product) -> Bool {
        let nameLower = product.name.lowercased()
        return product.category == "beverages" && (nameLower.contains("tea") || nameLower.contains("coffee") || nameLower.contains("hot"))
    }
}
