// SearchBarView.swift
// Text input view for filtering products and categories.

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Search items or categories..."
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField(placeholder, text: $text)
                .font(.body)
                .autocorrectionDisabled()
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(uiColor: .tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    @Previewable @State var text = ""
    SearchBarView(text: $text)
}
