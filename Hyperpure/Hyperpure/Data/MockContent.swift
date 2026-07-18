import Foundation

enum MockContent {
    static let testimonials: [Testimonial] = [
        Testimonial(id: 1, name: "Rajesh Kumar", role: "Owner, Spice Garden", city: "Delhi", quote: "Hyperpure has transformed how we source ingredients. The quality is consistently top-notch and saved us 15% on costs.", rating: 5, avatar: "RK"),
        Testimonial(id: 2, name: "Priya Sharma", role: "Head Chef, Cloud Kitchen Co.", city: "Mumbai", quote: "As a cloud kitchen operating 3 brands, consistency is everything. Hyperpure delivers restaurant-grade quality every time.", rating: 5, avatar: "PS"),
        Testimonial(id: 3, name: "Mohammed Ali", role: "Owner, Biryani House", city: "Hyderabad", quote: "We switched to Hyperpure for our basmati rice and spices. Bulk pricing saves us lakhs every month.", rating: 5, avatar: "MA")
    ]

    static let blogs: [BlogPost] = [
        BlogPost(id: 1, title: "5 Ways to Reduce Food Waste in Your Restaurant Kitchen", excerpt: "Learn practical strategies to minimize food waste, cut costs, and run a sustainable kitchen.", category: "Kitchen Tips", readTime: "5 min read", date: "2025-06-15", author: "Hyperpure Team"),
        BlogPost(id: 2, title: "Farm-to-Fork: How Hyperpure Ensures Freshness", excerpt: "Discover our end-to-end cold chain process delivering farm-fresh produce within 24 hours.", category: "Supply Chain", readTime: "7 min read", date: "2025-06-10", author: "Hyperpure Team"),
        BlogPost(id: 3, title: "Trending Menu Ideas for Cloud Kitchens in 2025", excerpt: "Stay ahead with these innovative menu concepts driving orders on food platforms.", category: "Menu Innovation", readTime: "6 min read", date: "2025-06-05", author: "Chef Rohit Mehra")
    ]

    static let faqs: [FAQItem] = [
        FAQItem(question: "What is Hyperpure by Zomato?", answer: "Hyperpure is a leading B2B service company addressing procurement and supply chain challenges for hotels, restaurants, and cloud kitchens."),
        FAQItem(question: "What makes Hyperpure different from other suppliers?", answer: "We provide direct farm sourcing, tech-enabled logistics, FSSAI-certified temperature controlled warehousing, and full quality transparency."),
        FAQItem(question: "Does Hyperpure supply to home chefs & small businesses?", answer: "Yes! We cater to restaurants, cloud kitchens, home chefs, and caterers of all sizes."),
        FAQItem(question: "What modes of payment does Hyperpure offer?", answer: "We accept Hyperpure Wallet, Hyperpure Credits, Zomato Pay Later, UPI, and Pay on Delivery.")
    ]

    static let stats: [StatItem] = [
        StatItem(value: 500, suffix: "+", label: "Cities Served", display: "500+"),
        StatItem(value: 100000, suffix: "+", label: "Restaurant Partners", display: "1L+"),
        StatItem(value: 2000, suffix: "+", label: "Products Available", display: "2000+"),
        StatItem(value: 50000, suffix: "+", label: "Daily Orders", display: "50K+")
    ]

    static let supplyChainSteps: [SupplyChainStep] = [
        SupplyChainStep(id: 1, title: "Farm Collection Centres", description: "Direct sourcing from farmers across India.", icon: "🌾"),
        SupplyChainStep(id: 2, title: "State-of-the-Art Food Park", description: "Central kitchen for recipe standardization and innovation.", icon: "🏭"),
        SupplyChainStep(id: 3, title: "Quality Testing Lab", description: "Rigorous testing across 100+ parameters in accredited labs.", icon: "🔬"),
        SupplyChainStep(id: 4, title: "FSSAI Warehouses", description: "Hygienic, climate-controlled warehousing network.", icon: "🏪"),
        SupplyChainStep(id: 5, title: "Temperature Controlled Fleet", description: "Refrigerated vehicles guaranteeing uninterrupted cold chain.", icon: "🚚")
    ]
}
