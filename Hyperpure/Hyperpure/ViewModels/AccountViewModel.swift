// AccountViewModel.swift
// ViewModel managing user profile settings, wallet balance, and veg mode toggles using SwiftData.

import Foundation
import Observation
import SwiftData

@MainActor
@Observable
public final class AccountViewModel {
    public static let shared = AccountViewModel()
    
    private var profile: AccountProfile? = nil
    
    private init() {
        fetchProfile()
    }
    
    public func fetchProfile() {
        let context = Database.shared.context
        let descriptor = FetchDescriptor<AccountProfile>()
        if let existing = (try? context.fetch(descriptor))?.first {
            self.profile = existing
        } else {
            let newProfile = AccountProfile(walletBalance: 25000.0, isVegModeOn: false)
            context.insert(newProfile)
            try? context.save()
            self.profile = newProfile
        }
    }
    
    public var walletBalance: Double {
        profile?.walletBalance ?? 25000.0
    }
    
    public var isVegModeOn: Bool {
        profile?.isVegModeOn ?? false
    }
    
    public func updateVegMode(_ isOn: Bool) {
        let context = Database.shared.context
        fetchProfile()
        profile?.isVegModeOn = isOn
        try? context.save()
    }
    
    public func updateWalletBalance(to balance: Double) {
        let context = Database.shared.context
        fetchProfile()
        profile?.walletBalance = balance
        try? context.save()
    }
}
