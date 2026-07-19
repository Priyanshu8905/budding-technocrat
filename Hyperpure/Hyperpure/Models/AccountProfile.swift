// AccountProfile.swift
// SwiftData model representing user account profile settings.

import Foundation
import SwiftData

@Model
public final class AccountProfile {
    @Attribute(.unique) public var id: String
    public var walletBalance: Double
    public var isVegModeOn: Bool
    
    public init(id: String = "singleton_profile", walletBalance: Double = 25000.0, isVegModeOn: Bool = false) {
        self.id = id
        self.walletBalance = walletBalance
        self.isVegModeOn = isVegModeOn
    }
}
