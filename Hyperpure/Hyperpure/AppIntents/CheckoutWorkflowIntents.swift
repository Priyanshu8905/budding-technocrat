// CheckoutWorkflowIntents.swift
// Global checkout state machine, Siri App Intents, dynamic Live Activity, and widget bridge.

import Foundation
import AppIntents
import SwiftUI
import ActivityKit
import WidgetKit

// MARK: - Payment Type

public enum PaymentType: String, Codable {
    case cashOnDelivery = "Cash on Delivery"
    case cardPayment    = "Credit Card"
    
    var displayLabel: String { rawValue }
    var icon: String {
        switch self {
        case .cashOnDelivery: return "indianrupeesign.circle.fill"
        case .cardPayment:    return "creditcard.fill"
        }
    }
}

// MARK: - CheckoutManager (Global Singleton)

@Observable
@MainActor
public class CheckoutManager {
    public static let shared = CheckoutManager()

    public enum CheckoutState: Equatable {
        case idle
        case gracePeriodActive(secondsRemaining: Int)
        case orderLocked
        case dispatched
    }

    public var state: CheckoutState = .idle
    public var orderID: String = ""
    var timerTask: Task<Void, Never>?

    // Checkout payload — true data from cart at order time
    var purchasedItems: [CartItem] = []
    var subtotal: Int = 0
    var tax: Int = 0
    var deliveryFee: Int = 0
    var grandTotal: Int = 0
    var paymentType: PaymentType = .cashOnDelivery
    var dispatchedAt: Date = .now

    private init() {}

    // MARK: Start with full payload
    func startCheckout(
        items: [CartItem] = [],
        subtotal: Int = 0,
        tax: Int = 0,
        deliveryFee: Int = 0,
        grandTotal: Int = 0,
        paymentType: PaymentType = .cashOnDelivery
    ) {
        self.purchasedItems = items
        self.subtotal = subtotal
        self.tax = tax
        self.deliveryFee = deliveryFee
        self.grandTotal = grandTotal
        self.paymentType = paymentType
        self.dispatchedAt = .now

        orderID = "#HP-" + String(Int.random(in: 1000...9999))
        state = .gracePeriodActive(secondsRemaining: 30)

        timerTask?.cancel()
        timerTask = Task {
            for seconds in stride(from: 29, through: 0, by: -1) {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { return }
                state = .gracePeriodActive(secondsRemaining: seconds)
            }
            lockOrder()
        }
    }

    public func cancelCheckout() {
        timerTask?.cancel()
        state = .idle
        CartViewModel.shared.clear()
        WidgetDataBridge.shared.clearDelivery()
    }

    // MARK: Lock Order & start Live Activity + widget
    private func lockOrder() {
        state = .orderLocked
        dispatchedAt = .now

        // Write widget data to App Group
        WidgetDataBridge.shared.writeActiveDelivery(
            orderID: orderID,
            statusLabel: "Order Locked & Preparing",
            statusIcon: "lock.fill",
            progressFraction: 0.2,
            subtotal: grandTotal,
            estimatedArrival: Date().addingTimeInterval(1800),
            paymentMethod: paymentType.displayLabel
        )

        // Start Live Activity
        let attrs = DeliveryTrackingAttributes(orderID: orderID, merchantName: "Hyperpure Wholesale")
        let initState = DeliveryTrackingAttributes.ContentState(
            currentStatus: .placed,
            estimatedArrival: Date().addingTimeInterval(1800),
            subtotal: grandTotal,
            paymentMethod: paymentType.displayLabel,
            itemCount: purchasedItems.count
        )
        do {
            let _ = try Activity<DeliveryTrackingAttributes>.request(
                attributes: attrs,
                content: ActivityContent(state: initState, staleDate: nil),
                pushType: nil
            )
            postLocalNotification(
                title: "Order Finalized",
                body: "Sourcing pipeline locked in. Live tracking active on Lock Screen."
            )
        } catch {
            print("Live Activity error: \(error)")
        }

        // Simulate async step progression
        Task {
            try? await Task.sleep(for: .seconds(8))
            await updateDeliveryStep(.partnerAssigned, progress: 0.4)
            try? await Task.sleep(for: .seconds(8))
            await updateDeliveryStep(.dispatched, progress: 0.7)
            try? await Task.sleep(for: .seconds(8))
            await updateDeliveryStep(.arrived, progress: 1.0)
        }
    }

    private func updateDeliveryStep(_ step: DeliveryStep, progress: Double) async {
        guard let activity = Activity<DeliveryTrackingAttributes>.activities
            .first(where: { $0.attributes.orderID == self.orderID }) else { return }

        let isArrived = step == .arrived
        if isArrived { self.state = .dispatched }

        let updatedState = DeliveryTrackingAttributes.ContentState(
            currentStatus: step,
            estimatedArrival: isArrived ? Date() : Date().addingTimeInterval(900),
            subtotal: grandTotal,
            paymentMethod: paymentType.displayLabel,
            itemCount: purchasedItems.count
        )
        await activity.update(using: updatedState)

        // Update widget
        let label: String
        let icon: String
        switch step {
        case .partnerAssigned: label = "Courier Assigned"; icon = "person.fill"
        case .dispatched:      label = "Out for Delivery"; icon = "shippingbox.fill"
        case .arrived:         label = "Delivered!";       icon = "checkmark.seal.fill"
        default:               label = "Preparing";        icon = "clock.fill"
        }
        await MainActor.run {
            WidgetDataBridge.shared.updateProgress(progress, statusLabel: label, statusIcon: icon)
        }

        // Milestone notifications
        switch step {
        case .partnerAssigned:
            postLocalNotification(title: "Courier Assigned", body: "Delivery partner loading at CP warehouse.")
        case .dispatched:
            postLocalNotification(title: "Consignment Dispatched", body: "Logistics partner departed hub.")
        case .arrived:
            postLocalNotification(title: "Courier Arrived 🎉", body: "Consignment delivered to your restaurant dock!")
        default: break
        }
    }
}

// MARK: - App Intents

struct GetKitchenInsightsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Kitchen Sourcing Insights"
    static var description = IntentDescription("Fetches weather conditions and recommends procurement adjustments.")
    static var openAppWhenRun: Bool = false
    init() {}

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let dialogue = IntentDialog("Heavy monsoon downpours detected in your area. Supply chain transit time is increased by forty-five minutes. I recommend scaling up flour and potato stocks by fifteen percent to buffer against logistical delays.")
        return .result(dialog: dialogue, view: KitchenInsightsSnippetView())
    }
}

struct PlaceProcurementOrderIntent: AppIntent {
    static var title: LocalizedStringResource = "Place Procurement Order"
    static var description = IntentDescription("Processes the local cart and starts the 30-second grace window.")
    static var openAppWhenRun: Bool = false
    init() {}

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let cart = CartViewModel.shared
        CheckoutManager.shared.startCheckout(
            items: cart.items,
            subtotal: cart.subtotal,
            tax: cart.tax,
            deliveryFee: cart.deliveryFee,
            grandTotal: cart.grandTotal,
            paymentType: .cashOnDelivery
        )
        let dialog = IntentDialog("Order received. Starting your thirty-second modification grace window. You can cancel or edit items before dispatch logs freeze.")
        return .result(dialog: dialog, view: CheckoutGracePeriodSnippetView())
    }
}

struct CancelCheckoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Cancel Checkout"
    static var description = IntentDescription("Cancels the active checkout session and reverts to cart.")
    static var openAppWhenRun: Bool = false
    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        CheckoutManager.shared.cancelCheckout()
        return .result()
    }
}

struct ShowKitchenStatusOnLockScreenIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Kitchen Status"
    static var description = IntentDescription("Updates the Lock Screen widget with the latest kitchen delivery data.")
    static var openAppWhenRun: Bool = false
    init() {}

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let mgr = CheckoutManager.shared

        // Force a widget timeline reload to surface current data
        WidgetCenter.shared.reloadAllTimelines()

        let isActive = mgr.state != .idle
        let dialog: IntentDialog
        if isActive {
            dialog = IntentDialog("Your kitchen delivery widget is now updated on your Lock Screen. Order \(mgr.orderID) status: \(mgr.state == .dispatched ? "Out for Delivery" : "Preparing"). Check your Lock Screen for the live ETA countdown.")
        } else {
            dialog = IntentDialog("No active kitchen delivery right now. Place an order first and your Lock Screen widget will automatically track it in real time.")
        }
        return .result(dialog: dialog)
    }
}

// MARK: - Siri Snippet Views

struct KitchenInsightsSnippetView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cloud.rain.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Monsoon Alert Active")
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text("Heavy Rain")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .cornerRadius(8)
            }

            Text("Supply chain transit time is increased by 45 minutes due to flooded roadways. Sourcing pipelines are currently constrained.")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
                .lineSpacing(2)

            Divider().background(Color.primary.opacity(0.1))

            VStack(alignment: .leading, spacing: 6) {
                Text("RECOMMENDED ADJUSTMENTS:")
                    .font(.caption2.bold())
                    .foregroundColor(Theme.textMuted)
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill").foregroundColor(.green)
                    Text("Scale up Flour & Potato stocks by 15%")
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.textPrimary)
                }
            }

            Button(intent: PlaceProcurementOrderIntent()) {
                Text("Place Order (Apply Buffers)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Theme.primary)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct CheckoutGracePeriodSnippetView: View {
    @State private var checkoutManager = CheckoutManager.shared

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("SECURE OUTPOST CHECKOUT")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Image(systemName: "clock.badge.checkmark.fill").foregroundColor(Theme.primary)
            }
            Divider().background(Color.primary.opacity(0.1))

            switch checkoutManager.state {
            case .gracePeriodActive(let seconds):
                VStack(spacing: 14) {
                    ZStack {
                        Circle().stroke(Color.primary.opacity(0.06), lineWidth: 8).frame(width: 80, height: 80)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(seconds) / 30.0)
                            .stroke(Theme.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.2), value: seconds)
                        Text("\(seconds)s")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .foregroundColor(Theme.textPrimary)
                    }
                    Text("Locking order in: 00:\(String(format: "%02d", seconds))")
                        .font(.subheadline.bold()).foregroundColor(Theme.textPrimary)
                    HStack(spacing: 10) {
                        Button(intent: CancelCheckoutIntent()) {
                            Text("Cancel Order")
                                .font(.caption.bold()).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(Color.red).cornerRadius(8)
                        }.buttonStyle(.plain)
                        Button(intent: CancelCheckoutIntent()) {
                            Text("Add More Items")
                                .font(.caption.bold()).foregroundColor(Theme.primary)
                                .frame(maxWidth: .infinity).padding(.vertical, 10)
                                .background(Theme.primaryBg).cornerRadius(8)
                        }.buttonStyle(.plain)
                    }
                }

            case .orderLocked:
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill").font(.title).foregroundColor(.green)
                    Text("Order Finalized & Frozen").font(.headline).foregroundColor(Theme.textPrimary)
                    Text("Live tracking active on your Lock Screen.").font(.caption).foregroundColor(Theme.textSecondary).multilineTextAlignment(.center)
                }

            case .dispatched:
                VStack(spacing: 10) {
                    Image(systemName: "shippingbox.fill").font(.title).foregroundColor(Theme.primary)
                    Text("Consignment Dispatched").font(.headline).foregroundColor(Theme.textPrimary)
                }

            case .idle:
                Text("No active checkout session.").font(.caption).foregroundColor(Theme.textMuted)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}
