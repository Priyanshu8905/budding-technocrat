import SwiftUI

struct BannerView: View {
    var onNavigateToCategory: ((String) -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            // Banner 1: Red Free Delivery Banner (Liquid Glass)
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 215/255, green: 30/255, blue: 45/255).opacity(0.88),
                                Color(red: 175/255, green: 20/255, blue: 30/255).opacity(0.78)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.regularMaterial)
                    )
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.6), .white.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Free delivery")
                            .font(.title3.weight(.black))
                            .foregroundColor(Color(red: 160/255, green: 20/255, blue: 30/255))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .background(Color.white.opacity(0.85))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
                            )
                        
                        Text("on orders above ₹3,000")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    Text("🚚")
                        .font(.system(size: 60))
                        .padding(.trailing, 16)
                }
            }
            
            // Banner 2: Light Pink Plaid Baking Banner (Liquid Glass & Functional Button)
            Button {
                onNavigateToCategory?("bakery")
            } label: {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 254/255, green: 242/255, blue: 244/255).opacity(0.88),
                                    Color(red: 250/255, green: 228/255, blue: 233/255).opacity(0.68)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.regularMaterial)
                        )
                        .frame(height: 175)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.9), .white.opacity(0.25)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Better baking starts here")
                                .font(.title2.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            Text("premium essentials for consistent results & margins")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            HStack(spacing: 4) {
                                Text("Shop here")
                                Image(systemName: "chevron.right")
                            }
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Theme.navyDark)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: Theme.navyDark.opacity(0.2), radius: 6, x: 0, y: 3)
                            .padding(.top, 4)
                        }
                        .padding(.leading, 16)
                        .frame(maxWidth: 220, alignment: .leading)
                        
                        Spacer()
                        
                        Text("🧁")
                            .font(.system(size: 65))
                            .padding(.trailing, 16)
                    }
                }
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.impact(weight: .light), trigger: true)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    BannerView()
}
