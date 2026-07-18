// AppState.swift
// Global state management for tab-navigation deep linking.

import SwiftUI

@Observable
@MainActor
public class AppState {
    public static let shared = AppState()
    public var selectedTab: Int = 0
}
