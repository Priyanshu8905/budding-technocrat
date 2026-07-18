import SwiftUI

struct TestimonialSliderView: View {
    let testimonials: [Testimonial]
    @State private var activeIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trusted by Restaurants")
                .font(.headline.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            
            TabView(selection: $activeIndex) {
                ForEach(testimonials.indices, id: \.self) { index in
                    let item = testimonials[index]
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 2) {
                            ForEach(0..<item.rating, id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption2)
                                    .foregroundColor(.yellow)
                            }
                        }
                        
                        Text("\"\(item.quote)\"")
                            .font(.subheadline)
                            .italic()
                            .foregroundColor(Theme.textPrimary)
                            .lineLimit(4)
                        
                        Spacer()
                        
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Theme.primaryBg)
                                    .frame(width: 36, height: 36)
                                Text(item.avatar)
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(Theme.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.caption.weight(.bold))
                                Text("\(item.role) • \(item.city)")
                                    .font(.caption2)
                                    .foregroundColor(Theme.textMuted)
                            }
                        }
                    }
                    .padding(16)
                    .cardStyle()
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 175)
        }
    }
}
