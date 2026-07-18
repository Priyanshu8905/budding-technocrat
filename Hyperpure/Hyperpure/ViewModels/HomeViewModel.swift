import SwiftUI
import Observation

@Observable
final class HomeViewModel {
    var categories: [Category] = MockCategories.categories
    var featuredProducts: [Product] = MockProducts.products
    var isLoading: Bool = false
    
    init() {
        loadData()
    }
    
    func loadData() {
        self.categories = MockCategories.categories
        self.featuredProducts = MockProducts.products
    }
}
