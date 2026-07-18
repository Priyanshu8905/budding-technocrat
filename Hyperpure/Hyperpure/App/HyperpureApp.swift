import SwiftUI

@main
struct HyperpureApp: App {
    @State private var cartViewModel = CartViewModel()
    @State private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(cartViewModel)
                .environment(authViewModel)
        }
    }
}
