import SwiftUI

@main
struct HyperpureApp: App {
    @State private var cartViewModel = CartViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(cartViewModel)
        }
    }
}
