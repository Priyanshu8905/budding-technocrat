import Foundation
import Supabase

actor SupabaseService {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient?
    
    private init() {
        if SupabaseConfig.isConfigured, let url = URL(string: SupabaseConfig.projectURLString) {
            self.client = SupabaseClient(supabaseURL: url, supabaseKey: SupabaseConfig.anonKey)
        } else {
            self.client = nil
        }
    }
    
    // MARK: - Categories
    func fetchCategories() async throws -> [Category] {
        guard let client = client else {
            return MockCategories.categories
        }
        
        do {
            let categories: [Category] = try await client.from("categories")
                .select()
                .execute()
                .value
            return categories.isEmpty ? MockCategories.categories : categories
        } catch {
            print("Supabase fetchCategories error: \(error.localizedDescription)")
            return MockCategories.categories
        }
    }
    
    // MARK: - Products
    func fetchProducts() async throws -> [Product] {
        guard let client = client else {
            return MockProducts.products
        }
        
        do {
            let products: [Product] = try await client.from("products")
                .select()
                .execute()
                .value
            return products.isEmpty ? MockProducts.products : products
        } catch {
            print("Supabase fetchProducts error: \(error.localizedDescription)")
            return MockProducts.products
        }
    }
    
    func fetchProducts(category categoryId: String) async throws -> [Product] {
        let allProducts = try await fetchProducts()
        if categoryId == "all" {
            return allProducts
        }
        return allProducts.filter { $0.category == categoryId }
    }
    
    // MARK: - Search
    func searchProducts(query: String) async throws -> [Product] {
        let allProducts = try await fetchProducts()
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return allProducts
        }
        let lower = query.lowercased()
        return allProducts.filter {
            $0.name.lowercased().contains(lower) ||
            $0.category.lowercased().contains(lower) ||
            $0.description.lowercased().contains(lower)
        }
    }
}
