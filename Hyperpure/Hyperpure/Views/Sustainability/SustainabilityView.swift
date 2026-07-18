import SwiftUI

struct SustainabilityView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sustainability at Our Core")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.white)
                        Text("Building a greener, more sustainable future for commercial food supply.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LinearGradient(colors: [Color(red: 36/255, green: 150/255, blue: 63/255), Color(red: 76/255, green: 175/255, blue: 80/255)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
                    
                    Text("Our Green Initiatives")
                        .font(.headline.weight(.bold))
                    
                    SustainabilityCard(icon: "bolt.car.fill", title: "100% Electric Vehicle Fleet", desc: "Transitioning all delivery vehicles to zero-emission electric vehicles.")
                    SustainabilityCard(icon: "sun.max.fill", title: "Solar-Powered Warehouses", desc: "Harnessing renewable solar energy across our fulfillment centers.")
                    SustainabilityCard(icon: "leaf.arrow.triangle.circlepath", title: "Biodegradable Packaging", desc: "Replacing single-use plastics with eco-friendly alternatives.")
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Sustainability")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SustainabilityCard: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Theme.success)
                .frame(width: 44, height: 44)
                .background(Theme.successLight)
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
    SustainabilityView()
}
