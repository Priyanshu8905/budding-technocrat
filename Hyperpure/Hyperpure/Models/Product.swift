import Foundation

struct Product: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let category: String
    let subcategory: String
    let price: Double
    let mrp: Double
    let unit: String
    let weight: String
    let description: String
    let inStock: Bool
    let isPopular: Bool
    let rating: Double
    let reviewCount: Int?
    let packInfo: String?         // e.g. "PACK OF 25", "PACK OF 50"
    let customBadge: String?      // e.g. "NECC BENCHMARKED", "ISO CERTIFIED", "IMPORTED"
    let recentBuyersCount: Int?   // e.g. 575 (for "575+ RECENT BUYERS")
    let isAd: Bool?
    let bestRateText: String?     // e.g. "₹0.42/pc Best rate"
    let unitSubtext: String?      // e.g. "₹8.03/pc"
    let minQtyText: String?       // e.g. "2 min. Qty"
    
    var discountPercent: Int {
        guard mrp > price && mrp > 0 else { return 0 }
        return Int(round(Double(mrp - price) / Double(mrp) * 100))
    }
    
    var formattedPrice: String {
        if price.truncatingRemainder(dividingBy: 1) == 0 {
            return "₹\(Int(price))"
        }
        return String(format: "₹%.2f", price)
    }
    
    var formattedMRP: String {
        if mrp.truncatingRemainder(dividingBy: 1) == 0 {
            return "₹\(Int(mrp))"
        }
        return String(format: "₹%.2f", mrp)
    }
}
