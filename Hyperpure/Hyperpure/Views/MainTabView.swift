import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isSmartListsPresented = false
    @State private var isCartPresented = false
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                onNavigateToCategory: { categoryId in
                    // Navigate action
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
            
            OrdersView(
                onStartShopping: {
                    selectedTab = 0
                }
            )
            .tabItem {
                Label("Orders", systemImage: "bag.fill")
            }
            .tag(2)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.fill")
                }
                .tag(3)
            
            SmartPantryView()
                .tabItem {
                    Label("Pantry", systemImage: "archivebox.fill")
                }
                .tag(4)
        }
        .tint(Theme.primary)
        .sheet(isPresented: $isSmartListsPresented) {
            SmartListsView()
        }
        .sheet(isPresented: $isCartPresented) {
            CartView()
        }
    }
}

#Preview {
    MainTabView()
        .environment(CartViewModel.shared)
        .modelContainer(for: PantryItem.self, inMemory: true)
}
