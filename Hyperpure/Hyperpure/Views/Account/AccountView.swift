import SwiftUI

struct AccountView: View {
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var isVegModeOn = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header Card (Screenshot 1)
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 232/255, green: 242/255, blue: 250/255))
                                .frame(width: 54, height: 54)
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(Color(red: 40/255, green: 110/255, blue: 210/255))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(authViewModel.isLoggedIn ? (authViewModel.currentUser?.name ?? "Guest Outlet") : "Guest Outlet")
                                .font(.title3.weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            
                            Text(authViewModel.isLoggedIn ? "+91 \(authViewModel.currentUser?.phone ?? "")" : "Guest Account")
                                .font(.subheadline)
                                .foregroundColor(Theme.textMuted)
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
                    
                    // ORDERS & STATEMENTS Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("ORDERS & STATEMENTS")
                            .font(.caption2.weight(.bold))
                            .tracking(1.5)
                            .foregroundColor(Theme.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            AccountRowItem(iconName: "bag", title: "Your orders")
                            Divider().padding(.leading, 48)
                            AccountRowItem(iconName: "indianrupeesign.square", title: "Food cost summary")
                            Divider().padding(.leading, 48)
                            AccountRowItem(iconName: "doc.text", title: "Account statement")
                            Divider().padding(.leading, 48)
                            AccountRowItem(iconName: "bubble.left", title: "Need help")
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
                    }
                    
                    // WALLET & PAYMENT Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("WALLET & PAYMENT")
                            .font(.caption2.weight(.bold))
                            .tracking(1.5)
                            .foregroundColor(Theme.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        
                        HStack(spacing: 14) {
                            Image(systemName: "wallet.pass")
                                .font(.body)
                                .foregroundColor(Theme.textPrimary)
                                .frame(width: 24)
                            
                            Text("Hyperpure wallet")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text("₹0")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Theme.tealBadge)
                                .clipShape(Capsule())
                            
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Theme.textMuted)
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
                    }
                    
                    // OTHERS Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("OTHERS")
                            .font(.caption2.weight(.bold))
                            .tracking(1.5)
                            .foregroundColor(Theme.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            AccountRowItem(iconName: "person", title: "Profile settings")
                            Divider().padding(.leading, 48)
                            AccountRowItem(iconName: "building.2", title: "Manage outlets")
                            Divider().padding(.leading, 48)
                            AccountRowItem(iconName: "briefcase", title: "Register as business", badgeText: "NEW")
                            Divider().padding(.leading, 48)
                            
                            // Veg Mode Toggle Row
                            HStack(spacing: 14) {
                                Image(systemName: "leaf.circle")
                                    .font(.body)
                                    .foregroundColor(Color.green)
                                    .frame(width: 24)
                                
                                Text("Veg mode")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(Theme.textPrimary)
                                
                                Spacer()
                                
                                Toggle("", isOn: $isVegModeOn)
                                    .labelsHidden()
                                    .tint(Color.green)
                            }
                            .padding(16)
                            
                            Divider().padding(.leading, 48)
                            AccountRowItem(iconName: "bell", title: "Notification preferences")
                            Divider().padding(.leading, 48)
                            AccountRowItem(iconName: "heart", title: "My list")
                            Divider().padding(.leading, 48)
                            AccountRowItem(iconName: "gift", title: "Claim coupon")
                            Divider().padding(.leading, 48)
                            AccountRowItem(iconName: "line.3.horizontal.decrease", title: "Request new product")
                            Divider().padding(.leading, 48)
                            AccountRowItem(iconName: "info.circle", title: "Contact us")
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
                    }
                    
                    // Logout Card
                    Button {
                        authViewModel.logout()
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "power")
                                .font(.body.weight(.bold))
                                .foregroundColor(Theme.primary)
                                .frame(width: 24)
                            
                            Text("Logout")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(Theme.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Theme.textMuted)
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.radiusLg))
                    }
                    
                    // App Version Footer
                    Text("App version v5.10.0")
                        .font(.caption)
                        .foregroundColor(Theme.textMuted)
                        .padding(.vertical, 8)
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AccountRowItem: View {
    let iconName: String
    let title: String
    var badgeText: String? = nil
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .font(.body)
                .foregroundColor(Theme.textPrimary)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Theme.textPrimary)
            
            Spacer()
            
            if let badge = badgeText {
                Text(badge)
                    .font(.system(size: 10).weight(.bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.primary)
                    .clipShape(Capsule())
            }
            
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(Theme.textMuted)
        }
        .padding(16)
    }
}

#Preview {
    AccountView()
        .environment(AuthViewModel())
}
