// WeatherIntelligenceWidget.swift
// WidgetKit extension integration for Feature 1: Weather Intelligence Engine.

import WidgetKit
import SwiftUI
import AppIntents

public struct WeatherWidgetConfigurationIntent: WidgetConfigurationIntent {
    public static var title: LocalizedStringResource = "Weather Widget Configuration"
    public static var description = IntentDescription("Choose target weather condition for menu optimization.")
    
    @Parameter(title: "Target Climate Mode", default: .monsoon)
    public var condition: SimulatedWeatherCondition
    
    public init() {}
}

public struct WeatherWidgetEntry: TimelineEntry {
    public let date: Date
    public let condition: SimulatedWeatherCondition
    public let perishableDelta: String
    public let comfortBuffer: String
    public let recommendations: [DishRecommendation]
    
    public init(date: Date, condition: SimulatedWeatherCondition, perishableDelta: String, comfortBuffer: String, recommendations: [DishRecommendation]) {
        self.date = date
        self.condition = condition
        self.perishableDelta = perishableDelta
        self.comfortBuffer = comfortBuffer
        self.recommendations = recommendations
    }
}

public struct WeatherMatrixTimelineProvider: AppIntentTimelineProvider {
    public typealias Entry = WeatherWidgetEntry
    public typealias Intent = WeatherWidgetConfigurationIntent
    
    public init() {}
    
    public func placeholder(in context: Context) -> WeatherWidgetEntry {
        WeatherWidgetEntry(
            date: Date(),
            condition: .monsoon,
            perishableDelta: "-20%",
            comfortBuffer: "+15%",
            recommendations: [
                DishRecommendation(name: "Hot Tomato & Basil Soup", category: "Appetizers", rationale: "", iconName: "cup.and.saucer.fill")
            ]
        )
    }
    
    public func snapshot(for configuration: WeatherWidgetConfigurationIntent, in context: Context) async -> WeatherWidgetEntry {
        let condition = configuration.condition
        let perishableDelta = condition == .monsoon ? "-20%" : (condition == .heatwave ? "-15%" : "0%")
        let comfortBuffer = condition == .monsoon ? "+15%" : (condition == .heatwave ? "+30%" : "0%")
        
        let recommendations: [DishRecommendation]
        if condition == .monsoon {
            recommendations = [
                DishRecommendation(name: "Hot Tomato & Basil Soup", category: "Appetizers", rationale: "", iconName: "cup.and.saucer.fill"),
                DishRecommendation(name: "Artisanal Pakoras & Chai Platter", category: "Snacks", rationale: "", iconName: "mug.fill")
            ]
        } else if condition == .heatwave {
            recommendations = [
                DishRecommendation(name: "Chilled Watermelon Salad", category: "Salads", rationale: "", iconName: "fork.knife"),
                DishRecommendation(name: "Chilled Cold Brew Coolers", category: "Beverages", rationale: "", iconName: "glass.juice.fill")
            ]
        } else {
            recommendations = [
                DishRecommendation(name: "Signature Farmhouse Pizza", category: "Mains", rationale: "", iconName: "circle.hexagongrid.fill")
            ]
        }
        
        return WeatherWidgetEntry(
            date: Date(),
            condition: condition,
            perishableDelta: perishableDelta,
            comfortBuffer: comfortBuffer,
            recommendations: recommendations
        )
    }
    
    public func timeline(for configuration: WeatherWidgetConfigurationIntent, in context: Context) async -> Timeline<WeatherWidgetEntry> {
        let entry = await snapshot(for: configuration, in: context)
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

public struct WeatherIntelligenceWidgetEntryView: View {
    var entry: WeatherWidgetEntry
    
    public init(entry: WeatherWidgetEntry) {
        self.entry = entry
    }
    
    var iconName: String {
        switch entry.condition {
        case .monsoon: return "cloud.rain.fill"
        case .heatwave: return "thermometer.sun.fill"
        case .optimal: return "sun.max.fill"
        }
    }
    
    var iconColor: Color {
        switch entry.condition {
        case .monsoon: return .blue
        case .heatwave: return .orange
        case .optimal: return .yellow
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Row
            HStack {
                Text("Hyperpure Engine")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                
                Spacer()
                
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
                    .font(.subheadline)
            }
            
            // Perishable tracking metrics
            VStack(alignment: .leading, spacing: 2) {
                Text("Climate Sourcing Delta:")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Theme.textSecondary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Text("Perishables:")
                            .font(.system(size: 9))
                            .foregroundColor(Theme.textMuted)
                        Text(entry.perishableDelta)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.red)
                    }
                    
                    HStack(spacing: 4) {
                        Text("Buffers:")
                            .font(.system(size: 9))
                            .foregroundColor(Theme.textMuted)
                        Text(entry.comfortBuffer)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(6)
            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 8))
            
            // Recommended seasonal dishes
            VStack(alignment: .leading, spacing: 4) {
                Text("Seasonal Pivots:")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(Theme.primary)
                
                ForEach(entry.recommendations.prefix(2)) { dish in
                    HStack(spacing: 6) {
                        Image(systemName: dish.iconName)
                            .font(.system(size: 8))
                            .foregroundColor(Theme.primary)
                        Text(dish.name)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Interactive recalculate button
            Button(intent: ApplyWeatherOptimizationIntent(condition: entry.condition)) {
                Label("Recalculate", systemImage: "arrow.clockwise.circle.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(Theme.primary, in: RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .containerBackground(.ultraThinMaterial, for: .widget)
    }
}

#if WIDGET_EXTENSION
@main
public struct WeatherIntelligenceWidget: Widget {
    let kind: String = "WeatherIntelligenceWidget"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: WeatherWidgetConfigurationIntent.self,
            provider: WeatherMatrixTimelineProvider()
        ) { entry in
            WeatherIntelligenceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Weather Intelligence Engine")
        .description("Optimize restaurant inventory ordering proactively based on localized climate shifts.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
#endif

#Preview("Weather Widget Medium") {
    WeatherIntelligenceWidgetEntryView(
        entry: WeatherWidgetEntry(
            date: Date(),
            condition: .monsoon,
            perishableDelta: "-20%",
            comfortBuffer: "+15%",
            recommendations: [
                DishRecommendation(name: "Hot Tomato & Basil Soup", category: "Appetizers", rationale: "", iconName: "cup.and.saucer.fill"),
                DishRecommendation(name: "Artisanal Pakoras & Chai Platter", category: "Snacks", rationale: "", iconName: "mug.fill")
            ]
        )
    )
    .frame(width: 340, height: 170)
}
