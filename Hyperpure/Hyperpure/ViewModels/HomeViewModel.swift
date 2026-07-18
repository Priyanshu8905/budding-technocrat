import SwiftUI
import Observation

@Observable
final class HomeViewModel {
    var categories: [Category] = MockCategories.categories
    var featuredProducts: [Product] = MockProducts.products
    var isLoading: Bool = false
    var errorMessage: String?
    
    init() {
        Task {
            await loadData()
        }
    }
    
    @MainActor
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let fetchedCategories = SupabaseService.shared.fetchCategories()
            async let fetchedProducts = SupabaseService.shared.fetchProducts()
            
            self.categories = try await fetchedCategories
            self.featuredProducts = try await fetchedProducts
        } catch {
            self.errorMessage = error.localizedDescription
            self.categories = MockCategories.categories
            self.featuredProducts = MockProducts.products
        }
    }
}
