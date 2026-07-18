// SearchBarView.swift
// Text input view for filtering products and categories.

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Search items or categories..."
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.textMuted)
            
            TextField(placeholder, text: $text)
                .font(.body)
                .autocorrectionDisabled()
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.textMuted)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
    }
}

#Preview {
    @Previewable @State var text = ""
    SearchBarView(text: $text)
}
