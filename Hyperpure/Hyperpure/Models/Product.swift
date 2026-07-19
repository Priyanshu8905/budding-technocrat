// Product.swift
// SwiftData model representing a catalog product.

import Foundation
import SwiftData

@Model
public final class Product: Identifiable {
    @Attribute(.unique) public var id: Int
    public var name: String
    public var category: String
    public var subcategory: String
    public var price: Double
    public var mrp: Double
    public var unit: String
    public var weight: String
    public var productDescription: String
    public var inStock: Bool
    public var isPopular: Bool
    public var rating: Double
    public var reviewCount: Int?
    public var packInfo: String?
    public var customBadge: String?
    public var recentBuyersCount: Int?
    public var isAd: Bool?
    public var bestRateText: String?
    public var unitSubtext: String?
    public var minQtyText: String?
    
    public var description: String { productDescription }
    
    public init(
        id: Int,
        name: String,
        category: String,
        subcategory: String,
        price: Double,
        mrp: Double,
        unit: String,
        weight: String,
        productDescription: String,
        inStock: Bool,
        isPopular: Bool,
        rating: Double,
        reviewCount: Int? = nil,
        packInfo: String? = nil,
        customBadge: String? = nil,
        recentBuyersCount: Int? = nil,
        isAd: Bool? = nil,
        bestRateText: String? = nil,
        unitSubtext: String? = nil,
        minQtyText: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.subcategory = subcategory
        self.price = price
        self.mrp = mrp
        self.unit = unit
        self.weight = weight
        self.productDescription = productDescription
        self.inStock = inStock
        self.isPopular = isPopular
        self.rating = rating
        self.reviewCount = reviewCount
        self.packInfo = packInfo
        self.customBadge = customBadge
        self.recentBuyersCount = recentBuyersCount
        self.isAd = isAd
        self.bestRateText = bestRateText
        self.unitSubtext = unitSubtext
        self.minQtyText = minQtyText
    }
    
    public convenience init(
        id: Int,
        name: String,
        category: String,
        subcategory: String,
        price: Double,
        mrp: Double,
        unit: String,
        weight: String,
        description: String,
        inStock: Bool,
        isPopular: Bool,
        rating: Double,
        reviewCount: Int? = nil,
        packInfo: String? = nil,
        customBadge: String? = nil,
        recentBuyersCount: Int? = nil,
        isAd: Bool? = nil,
        bestRateText: String? = nil,
        unitSubtext: String? = nil,
        minQtyText: String? = nil
    ) {
        self.init(
            id: id,
            name: name,
            category: category,
            subcategory: subcategory,
            price: price,
            mrp: mrp,
            unit: unit,
            weight: weight,
            productDescription: description,
            inStock: inStock,
            isPopular: isPopular,
            rating: rating,
            reviewCount: reviewCount,
            packInfo: packInfo,
            customBadge: customBadge,
            recentBuyersCount: recentBuyersCount,
            isAd: isAd,
            bestRateText: bestRateText,
            unitSubtext: unitSubtext,
            minQtyText: minQtyText
        )
    }
    
    public var discountPercent: Int {
        guard mrp > price && mrp > 0 else { return 0 }
        return Int(round(Double(mrp - price) / Double(mrp) * 100))
    }
    
    public var formattedPrice: String {
        if price.truncatingRemainder(dividingBy: 1) == 0 {
            return "₹\(Int(price))"
        }
        return String(format: "₹%.2f", price)
    }
    
    public var formattedMRP: String {
        if mrp.truncatingRemainder(dividingBy: 1) == 0 {
            return "₹\(Int(mrp))"
        }
        return String(format: "₹%.2f", mrp)
    }
}
