import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isSmartListsPresented = false
    @State private var isCartPresented = false
    @Environment(CartViewModel.self) private var cartViewModel
    @Environment(AuthViewModel.self) private var authViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                onNavigateToCategory: { categoryId in
                    // Navigate to category action
                },
                onOpenSmartLists: {
                    isSmartListsPresented = true
                },
                onOpenCart: {
                    isCartPresented = true
                }
            )
            .tabItem {
                Label("Shop", systemImage: "basket.fill")
            }
            .tag(0)
            
            MyListView(
                onStartShopping: {
                    selectedTab = 0
                },
                onOpenCart: {
                    isCartPresented = true
                }
            )
            .tabItem {
                Label("My list", systemImage: "heart.fill")
            }
            .badge("NEW")
            .tag(1)
            
            OrdersView()
                .tabItem {
                    Label("Orders", systemImage: "bag.fill")
                }
                .tag(2)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(3)
        }
        .accentColor(Theme.primary)
        .sheet(isPresented: $isSmartListsPresented) {
            SmartListsView()
        }
        .sheet(isPresented: $isCartPresented) {
            CartView()
        }
        .sheet(isPresented: Bindable(authViewModel).isLoginSheetPresented) {
            LoginView()
        }
    }
}

#Preview {
    MainTabView()
        .environment(CartViewModel())
        .environment(AuthViewModel())
}
