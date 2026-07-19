// HyperpureApp.swift
// Main entry point of the Hyperpure application.

import SwiftUI
import SwiftData

@main
struct HyperpureApp: App {
    @State private var cartViewModel = CartViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(cartViewModel)
                .modelContainer(Database.shared.container)
        }
    }
}
