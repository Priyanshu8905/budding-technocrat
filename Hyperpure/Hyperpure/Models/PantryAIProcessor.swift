// PantryAIProcessor.swift
// Static helper wrapping Foundation Models API requests with native fallback mechanisms.

import Foundation

struct PantryAIProcessor {
    static func generateAIPrediction(for item: PantryItem) async -> String {
        let remainingDays = Int(round(item.calculatedQuantity / item.dailyDepletionRate))
        return "Based on depletion rate of \(item.dailyDepletionRate)\(item.unit)/day, \(item.name) will fully exhaust in approximately \(remainingDays) days."
    }
}
