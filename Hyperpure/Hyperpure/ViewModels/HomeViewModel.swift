import Foundation
import Observation

@Observable
final class HomeViewModel {
    private(set) var categories: [Category] = MockCategories.categories
    private(set) var popularProducts: [Product] = MockProducts.products.filter { $0.isPopular }
    private(set) var testimonials: [Testimonial] = MockContent.testimonials
    private(set) var faqs: [FAQItem] = MockContent.faqs
    private(set) var stats: [StatItem] = MockContent.stats
    private(set) var supplyChainSteps: [SupplyChainStep] = MockContent.supplyChainSteps
    
    var activeHeroIndex: Int = 0
    var expandedFAQIndex: Int? = 0
    
    func nextHeroSlide() {
        activeHeroIndex = (activeHeroIndex + 1) % 3
    }
    
    func toggleFAQ(index: Int) {
        if expandedFAQIndex == index {
            expandedFAQIndex = nil
        } else {
            expandedFAQIndex = index
        }
    }
}
