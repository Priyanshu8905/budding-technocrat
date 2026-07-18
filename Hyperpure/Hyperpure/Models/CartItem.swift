import Foundation

struct CartItem: Identifiable, Codable, Hashable {
    var id: Int { product.id }
    let product: Product
    var quantity: Int
    
    var subtotal: Int {
        Int(round(product.price * Double(quantity)))
    }
    
    var totalMrp: Int {
        Int(round(product.mrp * Double(quantity)))
    }
    
    var totalSavings: Int {
        totalMrp - subtotal
    }
}
