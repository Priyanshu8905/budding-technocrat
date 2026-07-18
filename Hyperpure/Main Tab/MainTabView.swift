import SwiftUI

struct MainTabView: View {
    @State private var appState = AppState.shared
    @State private var myListViewModel = MyListViewModel.shared
    @State private var isSmartListsPresented = false
    @State private var isCartPresented = false
    @State private var isAccountPresented = false
    @State private var selectedCategoryId: String? = nil
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        @Bindable var appState = appState
        TabView(selection: $appState.selectedTab) {
            HomeView(
                onNavigateToCategory: { categoryId in
                    selectedCategoryId = categoryId
                },
                onOpenSmartLists: {
                    isSmartListsPresented = true
                },
                onOpenCart: {
                    isCartPresented = true
                },
                onOpenAccount: {
                    isAccountPresented = true
                }
            )
            .tabItem {
                Label("Shop", systemImage: "basket.fill")
            }
            .tag(0)
            
            MyListView(
                onStartShopping: {
                    appState.selectedTab = 0
                },
                onOpenCart: {
                    isCartPresented = true
                }
            )
            .tabItem {
                Label("My list", systemImage: "heart.fill")
            }
            .badge(myListViewModel.hasNewItems ? "NEW" : nil)
            .tag(1)
            
            OrdersView(
                onStartShopping: {
                    appState.selectedTab = 0
                }
            )
            .tabItem {
                Label("Orders", systemImage: "bag.fill")
            }
            .tag(2)
            
            SmartPantryView()
                .tabItem {
                    Label("Pantry", systemImage: "archivebox.fill")
                }
                .tag(3)
        }
        .tint(Theme.primary)
        .onChange(of: appState.selectedTab) { _, newTab in
            if newTab == 1 {
                myListViewModel.markAsSeen()
            }
        }
        .sheet(isPresented: $isSmartListsPresented) {
            SmartListsView()
        }
        .sheet(isPresented: $isCartPresented) {
            CartView()
        }
        .sheet(isPresented: $isAccountPresented) {
            AccountView()
        }
        .sheet(isPresented: Binding(
            get: { selectedCategoryId != nil },
            set: { if !$0 { selectedCategoryId = nil } }
        )) {
            if let categoryId = selectedCategoryId {
                CatalogueView(initialCategoryId: categoryId)
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(CartViewModel.shared)
        .modelContainer(for: PantryItem.self, inMemory: true)
}
