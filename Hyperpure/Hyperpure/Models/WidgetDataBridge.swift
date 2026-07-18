// WidgetDataBridge.swift
// Writes live checkout state to the shared App Group UserDefaults so the
// KitchenStatusWidget on Lock Screen and Home Screen stays updated.

import Foundation
import WidgetKit

enum WidgetDataKey {
    static let orderID       = "widget_orderID"
    static let statusLabel   = "widget_statusLabel"
    static let statusIcon    = "widget_statusIcon"
    static let progress      = "widget_progress"
    static let isActive      = "widget_isActive"
    static let subtotal      = "widget_subtotal"
    static let arrivalEpoch  = "widget_arrivalEpoch"
    static let paymentMethod = "widget_paymentMethod"
    static let suiteName     = "group.hyperpure.com"
}

@MainActor
final class WidgetDataBridge {
    static let shared = WidgetDataBridge()
    private let defaults: UserDefaults
    private init() {
        defaults = UserDefaults(suiteName: WidgetDataKey.suiteName) ?? .standard
    }

    func writeActiveDelivery(
        orderID: String,
        statusLabel: String,
        statusIcon: String,
        progressFraction: Double,
        subtotal: Int,
        estimatedArrival: Date,
        paymentMethod: String
    ) {
        defaults.set(orderID,              forKey: WidgetDataKey.orderID)
        defaults.set(statusLabel,          forKey: WidgetDataKey.statusLabel)
        defaults.set(statusIcon,           forKey: WidgetDataKey.statusIcon)
        defaults.set(progressFraction,     forKey: WidgetDataKey.progress)
        defaults.set(true,                 forKey: WidgetDataKey.isActive)
        defaults.set(subtotal,             forKey: WidgetDataKey.subtotal)
        defaults.set(estimatedArrival.timeIntervalSince1970, forKey: WidgetDataKey.arrivalEpoch)
        defaults.set(paymentMethod,        forKey: WidgetDataKey.paymentMethod)
        WidgetCenter.shared.reloadTimelines(ofKind: "KitchenStatusWidget")
    }

    func updateProgress(_ fraction: Double, statusLabel: String, statusIcon: String) {
        defaults.set(fraction,    forKey: WidgetDataKey.progress)
        defaults.set(statusLabel, forKey: WidgetDataKey.statusLabel)
        defaults.set(statusIcon,  forKey: WidgetDataKey.statusIcon)
        WidgetCenter.shared.reloadTimelines(ofKind: "KitchenStatusWidget")
    }

    func clearDelivery() {
        defaults.set(false, forKey: WidgetDataKey.isActive)
        defaults.set("",    forKey: WidgetDataKey.orderID)
        defaults.set(0.0,   forKey: WidgetDataKey.progress)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
