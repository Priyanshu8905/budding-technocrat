import SwiftUI

enum Theme {
    // Brand Colors (Matching Screenshots)
    static let primary = Color(red: 239/255, green: 79/255, blue: 95/255) // #EF4F5F Hyperpure Pink/Red
    static let primaryDark = Color(red: 210/255, green: 50/255, blue: 65/255)
    static let primaryLight = Color(red: 239/255, green: 79/255, blue: 95/255).opacity(0.7)
    static let primaryBg = Color(red: 239/255, green: 79/255, blue: 95/255).opacity(0.1)
    static let navyDark = Color(red: 28/255, green: 36/255, blue: 66/255) // #1C2442 Wholesale/Express navy
    static let bgDark = Color(red: 28/255, green: 36/255, blue: 66/255)
    static let navyLight = Color(red: 242/255, green: 244/255, blue: 248/255)
    
    // Backgrounds
    static let bgPrimary = Color.white
    static let bgSecondary = Color(red: 247/255, green: 248/255, blue: 250/255)
    static let cardTileBg = Color(red: 232/255, green: 243/255, blue: 247/255) // #E8F3F7 Light blue category tile
    
    // Badges & Accents
    static let tealBadge = Color(red: 0/255, green: 181/255, blue: 181/255) // #00B5B5 "NEW" badge
    static let bestRateBlue = Color(red: 33/255, green: 150/255, blue: 243/255)
    static let offerRedBg = Color(red: 226/255, green: 55/255, blue: 68/255)
    static let offer = Color(red: 255/255, green: 107/255, blue: 0/255)
    static let adBadgePurple = Color(red: 103/255, green: 58/255, blue: 183/255).opacity(0.15)
    static let success = Color(red: 36/255, green: 150/255, blue: 63/255)
    static let successLight = Color(red: 232/255, green: 245/255, blue: 233/255)
    
    // Text
    static let textPrimary = Color(red: 28/255, green: 36/255, blue: 50/255)
    static let textSecondary = Color(red: 100/255, green: 110/255, blue: 125/255)
    static let textMuted = Color(red: 160/255, green: 168/255, blue: 180/255)
    static let textLinkPink = Color(red: 239/255, green: 79/255, blue: 95/255)
    
    // Radii
    static let radiusSm: CGFloat = 8
    static let radiusMd: CGFloat = 12
    static let radiusLg: CGFloat = 18
    static let radiusFull: CGFloat = 99
}

extension View {
    func hyperpureCardStyle() -> some View {
        self
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.radiusMd)
                    .stroke(Color.gray.opacity(0.12), lineWidth: 1)
            )
    }
    
    func cardStyle() -> some View {
        hyperpureCardStyle()
    }
}
