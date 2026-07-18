import SwiftUI

struct BannerView: View {
    var body: some View {
        VStack(spacing: 12) {
            // Banner 1: Red Free Delivery Banner
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: Theme.radiusLg)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 215/255, green: 30/255, blue: 45/255), Color(red: 175/255, green: 20/255, blue: 30/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 100)
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Free delivery")
                            .font(.title3.weight(.black))
                            .foregroundColor(Color(red: 160/255, green: 20/255, blue: 30/255))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.95))
                            .clipShape(Capsule())
                        
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
            
            // Banner 2: Light Pink Plaid Baking Banner
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: Theme.radiusLg)
                    .fill(Color(red: 254/255, green: 242/255, blue: 244/255))
                    .frame(height: 160)
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Better baking starts here")
                            .font(.title2.weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(2)
                        
                        Text("premium essentials for consistent results & margins")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                            .lineLimit(2)
                        
                        Button {
                            // CTA action
                        } label: {
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
                        }
                        .padding(.top, 4)
                    }
                    .padding(.leading, 16)
                    .frame(maxWidth: 200, alignment: .leading)
                    
                    Spacer()
                    
                    Text("🧁")
                        .font(.system(size: 65))
                        .padding(.trailing, 16)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    BannerView()
}
