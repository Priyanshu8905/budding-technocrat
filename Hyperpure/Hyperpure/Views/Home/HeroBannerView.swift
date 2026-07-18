import SwiftUI

struct HeroBannerSlide: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let gradient: LinearGradient
}

struct HeroBannerView: View {
    @State private var activeIndex = 0
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    private let slides = [
        HeroBannerSlide(id: 0, title: "India's Largest B2B Food Supply Platform", subtitle: "Trusted by 1L+ restaurants across 500+ cities", gradient: LinearGradient(colors: [Color(red: 26/255, green: 26/255, blue: 46/255), Color(red: 15/255, green: 52/255, blue: 96/255)], startPoint: .topLeading, endPoint: .bottomTrailing)),
        HeroBannerSlide(id: 1, title: "Farm-Fresh Quality, Wholesale Prices", subtitle: "Direct farm sourcing with up to 30% savings", gradient: LinearGradient(colors: [Color(red: 13/255, green: 115/255, blue: 119/255), Color(red: 20/255, green: 160/255, blue: 133/255)], startPoint: .topLeading, endPoint: .bottomTrailing)),
        HeroBannerSlide(id: 2, title: "Next-Day Delivery Every Day", subtitle: "Temperature-controlled fleet ensuring maximum freshness", gradient: LinearGradient(colors: [Theme.primary, Theme.primaryDark], startPoint: .topLeading, endPoint: .bottomTrailing))
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $activeIndex) {
                ForEach(slides) { slide in
                    ZStack(alignment: .leading) {
                        slide.gradient
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(slide.title)
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                                .lineLimit(2)
                            
                            Text(slide.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(2)
                            
                            Spacer()
                            
                            HStack {
                                Text("Shop Catalogue")
                                    .font(.caption.weight(.bold))
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.bold))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundColor(Theme.textPrimary)
                            .clipShape(Capsule())
                        }
                        .padding(20)
                    }
                    .tag(slide.id)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 170)
            .onReceive(timer) { _ in
                withAnimation {
                    activeIndex = (activeIndex + 1) % slides.count
                }
            }
            
            HStack(spacing: 6) {
                ForEach(slides.indices, id: \.self) { index in
                    Circle()
                        .fill(index == activeIndex ? Theme.primary : Color.gray.opacity(0.3))
                        .frame(width: 7, height: 7)
                }
            }
        }
    }
}
