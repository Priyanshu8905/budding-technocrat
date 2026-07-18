// ToastView.swift
// Temporary popup notification displaying success or status messages.

import SwiftUI

struct ToastView: View {
    let message: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundColor(Theme.primary)
            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.navyDark)
        .clipShape(Capsule())
        .shadow(radius: 8)
    }
}

#Preview {
    ToastView(message: "Item added to cart", iconName: "cart.badge.plus")
}
