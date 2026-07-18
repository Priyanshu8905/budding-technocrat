// HyperpureApp.swift
// Main entry point of the Hyperpure application.

import SwiftUI

@main
struct HyperpureApp: App {
    @State private var cartViewModel = CartViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(cartViewModel)
        }
    }
}
