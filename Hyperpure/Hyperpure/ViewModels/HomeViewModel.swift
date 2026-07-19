// HomeViewModel.swift
// ViewModel managing the home screen data, including categories and featured products using SwiftData.

import SwiftUI
import Observation
import SwiftData

@MainActor
@Observable
public final class HomeViewModel {
    public static let shared = HomeViewModel()
    
    public var categories: [Category] = []
    public var featuredProducts: [Product] = []
    public var isLoading: Bool = false
    
    public init() {
        loadData()
    }
    
    public func loadData() {
        let context = Database.shared.context
        let catDescriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        self.categories = (try? context.fetch(catDescriptor)) ?? []
        
        let prodDescriptor = FetchDescriptor<Product>()
        self.featuredProducts = (try? context.fetch(prodDescriptor)) ?? []
    }
}
