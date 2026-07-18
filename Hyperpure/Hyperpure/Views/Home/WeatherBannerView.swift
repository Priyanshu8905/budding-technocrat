import SwiftUI

struct WeatherBannerView: View {
    @Bindable var weatherViewModel: WeatherViewModel
    var onShowDetails: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Weather Header Card
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(weatherViewModel.weatherAlert != nil ? Theme.primary : Theme.success)
                                .frame(width: 8, height: 8)
                            Text("WEATHER INTELLIGENCE SHIELD")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white.opacity(0.8))
                                .tracking(1.5)
                        }
                        
                        Text(weatherViewModel.currentPreset.rawValue)
                            .font(.title3.weight(.black))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Weather icon based on preset
                    Image(systemName: weatherIconName(for: weatherViewModel.currentPreset))
                        .font(.title)
                        .foregroundColor(.white)
                        .symbolEffect(.bounce, value: weatherViewModel.currentPreset)
                }
                
                // Weather details: Temp & Precipitation
                HStack(spacing: 16) {
                    Label(
                        title: { Text(String(format: "%.0f°C", weatherViewModel.temperature)).font(.subheadline.weight(.bold)).foregroundColor(.white) },
                        icon: { Image(systemName: "thermometer.medium").foregroundColor(.white.opacity(0.8)) }
                    )
                    
                    Label(
                        title: { Text(String(format: "%.0f%% Rain", weatherViewModel.precipitationChance * 100)).font(.subheadline.weight(.bold)).foregroundColor(.white) },
                        icon: { Image(systemName: "drop.fill").foregroundColor(.white.opacity(0.8)) }
                    )
                }
                
                // Severe weather alert warning box
                if let alert = weatherViewModel.weatherAlert {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Theme.primary)
                            .font(.subheadline)
                        Text(alert)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusSm))
                }
                
                Divider()
                    .background(Color.white.opacity(0.15))
                    .padding(.vertical, 2)
                
                HStack {
                    Text("Auto-adjusting fresh stock quantities")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Button(action: onShowDetails) {
                        HStack(spacing: 4) {
                            Text("Review Adjustments")
                            Image(systemName: "arrow.right")
                        }
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.primary)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Theme.navyDark, Color(red: 48/255, green: 60/255, blue: 105/255)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
            .shadow(color: Theme.navyDark.opacity(0.18), radius: 10, x: 0, y: 5)
            
            // Interactive demo switcher: Lets user test Monsoon vs Heatwave in simulator
            VStack(alignment: .leading, spacing: 6) {
                Text("Simulate Weather Shifts (Demo Controls)")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(0.5)
                    .padding(.horizontal, 4)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(WeatherPreset.allCases) { preset in
                            Button {
                                withAnimation(.spring(duration: 0.35)) {
                                    weatherViewModel.applyPreset(preset, for: MockProducts.products)
                                }
                            } label: {
                                Text(preset.rawValue)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(weatherViewModel.currentPreset == preset ? Theme.primaryBg : Color.white)
                                    .foregroundColor(weatherViewModel.currentPreset == preset ? Theme.primary : Theme.textPrimary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(weatherViewModel.currentPreset == preset ? Theme.primary : Color.gray.opacity(0.15), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                }
            }
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusMd)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
    }
    
    private func weatherIconName(for preset: WeatherPreset) -> String {
        switch preset {
        case .normal: return "sun.max.fill"
        case .monsoon: return "cloud.heavyrain.fill"
        case .heatwave: return "sun.thermometer.fill"
        case .coldWave: return "snowflake"
        }
    }
}

#Preview {
    WeatherBannerView(weatherViewModel: WeatherViewModel()) {}
}
