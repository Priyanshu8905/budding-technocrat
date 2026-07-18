import Foundation

struct Testimonial: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let role: String
    let city: String
    let quote: String
    let rating: Int
    let avatar: String
}

struct BlogPost: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let excerpt: String
    let category: String
    let readTime: String
    let date: String
    let author: String
}

struct FAQItem: Identifiable, Codable, Hashable {
    var id: String { question }
    let question: String
    let answer: String
}

struct StatItem: Identifiable, Codable, Hashable {
    var id: String { label }
    let value: Int
    let suffix: String
    let label: String
    let display: String?
}

struct SupplyChainStep: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let description: String
    let icon: String
}
