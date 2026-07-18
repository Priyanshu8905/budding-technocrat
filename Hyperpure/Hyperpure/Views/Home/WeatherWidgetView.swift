// WeatherWidgetView.swift
// Compact dashboard widget displaying current weather metrics and warning status on the home feed.

import SwiftUI

struct WeatherWidgetView: View {
    let snapshot: WeatherSnapshot
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: weatherIcon)
                            .font(.title3)
                            .foregroundColor(snapshot.state == .normal ? Theme.bestRateBlue : .white)
                        
                        Text(snapshot.state.rawValue)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(snapshot.state == .normal ? Theme.textPrimary : .white)
                    }
                    
                    Spacer()
                    
                    if snapshot.state != .normal {
                        Text("ACTIVE WARNING")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Capsule())
                    }
                }
                
                if let warning = snapshot.activeWarning {
                    Text(warning)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "thermometer")
                        Text(String(format: "%.0f°C", snapshot.temperature))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                        Text(String(format: "%.0f%% Rain", snapshot.precipitationProbability * 100))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "humidity")
                        Text(String(format: "%.0f%% RH", snapshot.humidity * 100))
                    }
                }
                .font(.caption)
                .foregroundColor(snapshot.state == .normal ? Theme.textSecondary : .white.opacity(0.85))
                
                HStack {
                    Text(snapshot.state == .normal ? "View Forecast" : "Optimize Orders Proactively")
                        .font(.caption.weight(.bold))
                        .foregroundColor(snapshot.state == .normal ? Theme.primary : .white)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(snapshot.state == .normal ? Theme.primary : .white)
                }
                .padding(.top, 4)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch snapshot.state {
        case .normal:
            Color.white
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radiusMd)
                        .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                )
        case .monsoon:
            LinearGradient(
                colors: [Color(red: 74/255, green: 85/255, blue: 104/255), Color(red: 45/255, green: 55/255, blue: 72/255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .heatwave:
            LinearGradient(
                colors: [Color(red: 237/255, green: 137/255, blue: 54/255), Color(red: 229/255, green: 62/255, blue: 62/255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .winterCold:
            LinearGradient(
                colors: [Color(red: 66/255, green: 153/255, blue: 225/255), Color(red: 43/255, green: 108/255, blue: 176/255)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var weatherIcon: String {
        switch snapshot.state {
        case .normal: return "sun.max.fill"
        case .monsoon: return "cloud.rain.fill"
        case .heatwave: return "thermometer.sun.fill"
        case .winterCold: return "snowflake"
        }
    }
}
