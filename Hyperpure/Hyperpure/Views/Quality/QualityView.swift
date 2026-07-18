import SwiftUI

struct QualityView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quality You Can Trust")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                        Text("From farm to your doorstep, we ensure the highest standards of food safety, freshness, and compliance.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LinearGradient(colors: [Theme.primary, Theme.primaryDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
                    
                    Text("Our Quality Pillars")
                        .font(.headline.weight(.bold))
                    
                    QualityPillarRow(icon: "leaf.fill", title: "Direct Farm Sourcing", desc: "Sourced directly from farmers at Mandi rates without intermediaries.")
                    QualityPillarRow(icon: "checkmark.seal.fill", title: "FSSAI Certified Warehouses", desc: "Temperature-controlled warehousing adhering to FSSAI guidelines.")
                    QualityPillarRow(icon: "snowflake", title: "End-to-End Cold Chain", desc: "Uninterrupted refrigeration from farm to kitchen doorstep.")
                    QualityPillarRow(icon: "flask.fill", title: "Lab Tested Ingredients", desc: "Over 100+ parameters checked in accredited quality labs.")
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Quality")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct QualityPillarRow: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.primary)
                .frame(width: 44, height: 44)
                .background(Theme.primaryBg)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(desc)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(14)
        .cardStyle()
    }
}

#Preview {
    QualityView()
}
