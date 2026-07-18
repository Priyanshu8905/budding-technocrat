// SupplyChainView.swift
// Informational card illustrating the farm-to-kitchen supply chain.

import SwiftUI

struct SupplyChainView: View {
    let steps: [SupplyChainStep]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Farm to Kitchen Technology")
                .font(.headline.weight(.bold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(steps) { step in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(step.icon)
                                    .font(.title)
                                Spacer()
                                Text("#0\(step.id)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(Theme.primaryLight)
                            }
                            
                            Text(step.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.white)
                            
                            Text(step.description)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(3)
                        }
                        .padding(14)
                        .frame(width: 200, height: 135)
                        .background(Color.white.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.bgDark)
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
    }
}

#Preview {
    SupplyChainView(steps: MockContent.supplyChainSteps)
}
