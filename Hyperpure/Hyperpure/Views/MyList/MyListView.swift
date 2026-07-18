import SwiftUI

struct MyListView: View {
    var onStartShopping: (() -> Void)?
    var onOpenCart: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Phone Mockup Graphic (Screenshot 2)
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Theme.navyDark, lineWidth: 10)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white)
                        )
                        .frame(width: 200, height: 260)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("< Fruits & vegetables")
                                .font(.system(size: 8).weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            Spacer()
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 8))
                            Image(systemName: "cart")
                                .font(.system(size: 8))
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 12)
                        
                        Divider()
                        
                        // Mini item card
                        HStack(spacing: 8) {
                            Text("🍅")
                                .font(.system(size: 24))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Fresh Tomato Premium")
                                    .font(.system(size: 8).weight(.bold))
                                Text("1kg")
                                    .font(.system(size: 6))
                                    .foregroundColor(.gray)
                                Text("₹150")
                                    .font(.system(size: 8).weight(.bold))
                            }
                            Spacer()
                            Text("ADD +")
                                .font(.system(size: 7).weight(.bold))
                                .foregroundColor(Theme.primary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .overlay(
                                    Capsule().stroke(Theme.primary, lineWidth: 0.5)
                                )
                        }
                        .padding(8)
                        .background(Color(uiColor: .tertiarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal, 10)
                        
                        Spacer()
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Add items to your list")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Add your favourite items and shop faster at a single place")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                Button {
                    onStartShopping?()
                } label: {
                    Text("Start shopping")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusMd))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .background(Color.white)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            // Search
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.body)
                                .foregroundColor(Theme.primary)
                                .frame(width: 36, height: 36)
                                .background(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        
                        Button {
                            onOpenCart?()
                        } label: {
                            Image(systemName: "cart")
                                .font(.body)
                                .foregroundColor(Theme.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MyListView()
}
