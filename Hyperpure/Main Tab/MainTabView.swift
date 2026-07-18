import SwiftUI

struct MainTabView: View {
    @State private var appState = AppState.shared
    @State private var myListViewModel = MyListViewModel.shared
    @State private var isSmartListsPresented = false
    @State private var isAccountPresented = false
    @State private var selectedCategoryId: String? = nil
    @Environment(CartViewModel.self) private var cartViewModel
    
    var body: some View {
        @Bindable var appState = appState
        TabView(selection: $appState.selectedTab) {
            Tab("Shop", systemImage: "basket.fill", value: 0) {
                HomeView(
                    onNavigateToCategory: { categoryId in
                        selectedCategoryId = categoryId
                    },
                    onOpenSmartLists: {
                        isSmartListsPresented = true
                    },
                    onOpenCart: {
                        appState.isCartPresented = true
                    },
                    onOpenAccount: {
                        isAccountPresented = true
                    }
                )
            }
            
            Tab("My list", systemImage: "heart.fill", value: 1) {
                MyListView(
                    onStartShopping: {
                        appState.selectedTab = 0
                    },
                    onOpenCart: {
                        appState.isCartPresented = true
                    }
                )
            }
            .badge(myListViewModel.hasNewItems ? Text("NEW") : nil)
            
            Tab("Orders", systemImage: "bag.fill", value: 2) {
                OrdersView(
                    onStartShopping: {
                        appState.selectedTab = 0
                    }
                )
            }
            
            Tab("Pantry", systemImage: "archivebox.fill", value: 3) {
                SmartPantryView()
            }
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
        .sheet(isPresented: $appState.isCartPresented) {
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
