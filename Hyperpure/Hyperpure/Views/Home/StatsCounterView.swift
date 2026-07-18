import SwiftUI

struct StatsCounterView: View {
    let stats: [StatItem]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(stats) { stat in
                VStack(spacing: 4) {
                    Text(stat.display ?? "\(stat.value)\(stat.suffix)")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Theme.primary)
                    
                    Text(stat.label)
                        .font(.caption.weight(.medium))
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .cardStyle()
            }
        }
    }
}
