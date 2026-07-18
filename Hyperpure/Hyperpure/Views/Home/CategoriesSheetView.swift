import SwiftUI

struct CategoriesSheetView: View {
    @Environment(\.dismiss) private var dismiss
    var onSelectCategory: ((String) -> Void)?
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // Close Button Bar (Screenshot 2)
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Categories Grid (16 Items)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(MockCategories.categories) { category in
                        Button {
                            onSelectCategory?(category.id)
                            dismiss()
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: Theme.radiusLg)
                                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                        .frame(height: 72)
                                    
                                    Text(category.icon)
                                        .font(.system(size: 36))
                                }
                                
                                Text(category.shortName)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(Theme.textPrimary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.8)
                                    .frame(height: 32, alignment: .top)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white)
    }
}

#Preview {
    CategoriesSheetView()
}
