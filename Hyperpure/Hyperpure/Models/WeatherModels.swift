// WeatherModels.swift
// Models representing simulated weather alerts, forecast metrics, and demand fluctuations.

import Foundation

public enum WeatherState: String, Codable, Sendable, CaseIterable, Identifiable {
    case normal = "Normal"
    case monsoon = "Monsoon Warning"
    case heatwave = "Heatwave Warning"
    case winterCold = "Cold Wave Warning"
    
    public var id: String { rawValue }
}

public struct WeatherSnapshot: Codable, Sendable {
    public let state: WeatherState
    public let temperature: Double
    public let precipitationProbability: Double
    public let humidity: Double
    public let activeWarning: String?
}

public struct WeatherForecastDay: Identifiable, Codable, Sendable {
    public var id: String { dayName }
    public let dayName: String
    public let projectedDemandSurge: Double
    public let weatherIcon: String
}
