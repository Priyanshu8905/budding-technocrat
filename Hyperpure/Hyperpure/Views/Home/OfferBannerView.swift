// OfferBannerView.swift
// View displaying promotional banners and wholesale deals.

import SwiftUI

struct OfferCardItem: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String
    let bgColors: [Color]
}

struct OfferBannerView: View {
    private let offers = [
        OfferCardItem(id: 1, title: "FREE Delivery", subtitle: "On orders above ₹500", icon: "truck.box.fill", bgColors: [Color(red: 36/255, green: 150/255, blue: 63/255), Color(red: 76/255, green: 175/255, blue: 80/255)]),
        OfferCardItem(id: 2, title: "Bulk Discounts", subtitle: "Save up to 30% on wholesale", icon: "percent", bgColors: [Color(red: 255/255, green: 107/255, blue: 0/255), Color(red: 255/255, green: 152/255, blue: 0/255)]),
        OfferCardItem(id: 3, title: "Welcome Bonus", subtitle: "Get ₹200 off your 1st order", icon: "gift.fill", bgColors: [Color(red: 156/255, green: 39/255, blue: 176/255), Color(red: 186/255, green: 104/255, blue: 200/255)])
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(offers) { offer in
                    HStack(spacing: 12) {
                        Image(systemName: offer.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(offer.title)
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.white)
                            Text(offer.subtitle)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(LinearGradient(colors: offer.bgColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                }
            }
        }
    }
}

#Preview {
    OfferBannerView()
}
