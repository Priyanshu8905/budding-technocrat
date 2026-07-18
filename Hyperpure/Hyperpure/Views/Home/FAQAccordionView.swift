import SwiftUI

struct FAQAccordionView: View {
    let faqs: [FAQItem]
    @State private var expandedId: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Frequently Asked Questions")
                .font(.headline.weight(.bold))
                .foregroundColor(Theme.textPrimary)
            
            VStack(spacing: 8) {
                ForEach(faqs) { item in
                    let isExpanded = expandedId == item.question
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                expandedId = isExpanded ? nil : item.question
                            }
                        } label: {
                            HStack {
                                Text(item.question)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(Theme.textPrimary)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(Theme.primary)
                            }
                        }
                        
                        if isExpanded {
                            Text(item.answer)
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                                .padding(.top, 4)
                        }
                    }
                    .padding(14)
                    .cardStyle()
                }
            }
        }
    }
}
