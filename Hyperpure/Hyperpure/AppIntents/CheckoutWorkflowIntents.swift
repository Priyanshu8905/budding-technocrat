// CheckoutWorkflowIntents.swift
// Global checkout state machine, Siri App Intents, dynamic Live Activity, and widget bridge.

import Foundation
import AppIntents
import SwiftUI
import ActivityKit
import WidgetKit

// MARK: - Payment Type

public enum PaymentType: String, Codable, AppEnum {
    case cashOnDelivery = "Cash on Delivery"
    case cardPayment    = "Credit Card"
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Payment Method"
    }
    
    public static var caseDisplayRepresentations: [PaymentType: DisplayRepresentation] {
        [
            .cashOnDelivery: "Cash on Delivery",
            .cardPayment: "Credit Card"
        ]
    }
    
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
        case arrived      // "Order Reached" or "Courier Arrived"
        case completed    // "Order Completed"
    }

    public var state: CheckoutState = .idle
    public var orderID: String = ""
    public var courierProgress: Double = 0.0
    var timerTask: Task<Void, Never>?
    private var simulationTask: Task<Void, Never>?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    // Checkout payload — true data from cart at order time
    var purchasedItems: [CartItem] = []
    var subtotal: Int = 0
    var tax: Int = 0
    var deliveryFee: Int = 0
    var grandTotal: Int = 0
    var paymentType: PaymentType = .cashOnDelivery
    var dispatchedAt: Date = .now

    private init() {}

    // MARK: Activity restoration logic
    public func restoreActiveActivityIfAny() {
        guard let activeActivity = Activity<DeliveryTrackingAttributes>.activities.first else { return }
        
        let state = activeActivity.content.state
        let attrs = activeActivity.attributes
        
        self.orderID = attrs.orderID
        self.grandTotal = state.subtotal
        self.paymentType = state.paymentMethod == PaymentType.cardPayment.displayLabel ? .cardPayment : .cashOnDelivery
        
        switch state.currentStatus {
        case .placed:
            self.state = .orderLocked
            self.courierProgress = 0.2
        case .partnerAssigned:
            self.state = .orderLocked
            self.courierProgress = 0.4
        case .dispatched:
            self.state = .dispatched
            self.courierProgress = 0.7
        case .arrived:
            self.state = .arrived
            self.courierProgress = 0.9
        case .completed:
            self.state = .completed
            self.courierProgress = 1.0
        }
        
        if self.purchasedItems.isEmpty {
            let placeholderProduct = Product(
                id: 9999,
                name: "Wholesale Consignment",
                category: "wholesale",
                subcategory: "Sourced Items",
                price: Double(state.subtotal),
                mrp: Double(state.subtotal),
                unit: "unit",
                weight: "\(state.itemCount) items",
                description: "Sourced consignment details",
                inStock: true,
                isPopular: false,
                rating: 5.0,
                reviewCount: 100,
                packInfo: nil,
                customBadge: nil,
                recentBuyersCount: nil,
                isAd: false,
                bestRateText: nil,
                unitSubtext: nil,
                minQtyText: nil
            )
            self.purchasedItems = [CartItem(product: placeholderProduct, quantity: 1)]
            self.subtotal = state.subtotal
            self.grandTotal = state.subtotal
        }
    }

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
        self.courierProgress = 0.0

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
        simulationTask?.cancel()
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
        state = .idle
        courierProgress = 0.0
        CartViewModel.shared.clear()
        WidgetDataBridge.shared.clearDelivery()
    }

    // MARK: Force Lock order immediately (bypasses grace period)
    public func forceLockOrder() {
        timerTask?.cancel()
        lockOrder()
    }

    // MARK: Lock Order & start Live Activity + widget
    private func lockOrder() {
        state = .orderLocked
        dispatchedAt = .now
        courierProgress = 0.0

        // Begin background task to survive minimization
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "DeliverySimulation") { [weak self] in
            guard let self = self else { return }
            Task { @MainActor in
                if self.backgroundTaskID != .invalid {
                    UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
                    self.backgroundTaskID = .invalid
                }
            }
        }

        // Write widget data to App Group
        WidgetDataBridge.shared.writeActiveDelivery(
            orderID: orderID,
            statusLabel: "Preparing Order",
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
                title: "Order Sourcing Locked",
                body: "Consignment \(orderID) locked for dispatch preparation."
            )
        } catch {
            print("Live Activity error: \(error)")
        }

        // Run smooth centralized courier progress simulation
        simulationTask?.cancel()
        simulationTask = Task {
            // progress: 0.0 -> 1.0 (updates by 0.02 every 0.6 seconds, takes 30 seconds total)
            for _ in 1...50 {
                try? await Task.sleep(for: .milliseconds(600))
                if Task.isCancelled { break }
                
                self.courierProgress += 0.02
                if self.courierProgress > 1.0 { self.courierProgress = 1.0 }
                
                // Map progress to steps
                let progress = self.courierProgress
                if progress >= 1.0 {
                    await updateDeliveryStep(.completed, progress: 1.0)
                    break
                } else if progress >= 0.85 {
                    await updateDeliveryStep(.arrived, progress: 0.9)
                } else if progress >= 0.55 {
                    await updateDeliveryStep(.dispatched, progress: 0.7)
                } else if progress >= 0.25 {
                    await updateDeliveryStep(.partnerAssigned, progress: 0.4)
                }
            }
            
            // End the background task
            if self.backgroundTaskID != .invalid {
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
                self.backgroundTaskID = .invalid
            }
        }
    }

    private func updateDeliveryStep(_ step: DeliveryStep, progress: Double) async {
        guard let activity = Activity<DeliveryTrackingAttributes>.activities
            .first(where: { $0.attributes.orderID == self.orderID }) else { return }

        // Update the app state machine matching the steps
        switch step {
        case .placed:
            self.state = .orderLocked
        case .partnerAssigned:
            self.state = .orderLocked
        case .dispatched:
            self.state = .dispatched
        case .arrived:
            if self.state != .arrived {
                self.state = .arrived
                postLocalNotification(title: "Courier Arrived 🎉", body: "Consignment reached Connaught Place dock.")
            }
        case .completed:
            if self.state != .completed {
                self.state = .completed
                postLocalNotification(title: "Order Completed! 📦", body: "Receipt saved to history.")
                               // Save order to SwiftData database history
                let context = Database.shared.context
                let orderItems = self.purchasedItems.map { item in
                    CartLineItem(product: item.product, quantity: item.quantity)
                }
                for item in orderItems {
                    context.insert(item)
                }
                
                let newOrder = Order(
                    id: self.orderID,
                    items: orderItems,
                    subtotal: self.subtotal,
                    deliveryFee: self.deliveryFee,
                    tax: self.tax,
                    grandTotal: self.grandTotal,
                    deliverySlot: "Today, Sourcing Pipeline",
                    placedAt: self.dispatchedAt,
                    status: .confirmed
                )
                context.insert(newOrder)
                try? context.save()
                OrderManager.shared.fetchOrders()
            }
        }

        let updatedState = DeliveryTrackingAttributes.ContentState(
            currentStatus: step,
            estimatedArrival: step == .completed ? Date() : Date().addingTimeInterval(900),
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
        case .arrived:         label = "Order Reached";    icon = "house.fill"
        case .completed:       label = "Order Completed";  icon = "checkmark.seal.fill"
        default:               label = "Preparing";        icon = "clock.fill"
        }
        await MainActor.run {
            WidgetDataBridge.shared.updateProgress(progress, statusLabel: label, statusIcon: icon)
        }

        // Milestone notifications
        switch step {
        case .partnerAssigned:
            postLocalNotification(title: "Courier Assigned", body: "Delivery partner loading cargo at CP hub.")
        case .dispatched:
            postLocalNotification(title: "Consignment Dispatched", body: "Logistics partner departed CP warehouse.")
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

    @Parameter(title: "Payment Method", default: .cashOnDelivery)
    var paymentMethod: PaymentType

    static var parameterSummary: some ParameterSummary {
        Summary("Place my kitchen order using \(\.$paymentMethod)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let cart = CartViewModel.shared
        if cart.items.isEmpty {
            return .result(dialog: IntentDialog("Your cart is empty. Please add items to your cart first before placing a procurement order."))
        }

        CheckoutManager.shared.startCheckout(
            items: cart.items,
            subtotal: cart.subtotal,
            tax: cart.tax,
            deliveryFee: cart.deliveryFee,
            grandTotal: cart.grandTotal,
            paymentType: paymentMethod
        )
        // Auto-clear cart since order is placed
        cart.clear()

        let dialog = IntentDialog("Order received via \(paymentMethod.displayLabel). Starting your thirty-second modification grace window. You can cancel or edit items before dispatch logs freeze.")
        return .result(dialog: dialog, view: CheckoutGracePeriodSnippetView())
    }
}

struct CancelCheckoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Cancel Checkout"
    static var description = IntentDescription("Cancels the active checkout session and reverts to cart.")
    static var openAppWhenRun: Bool = false
    init() {}

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let mgr = CheckoutManager.shared
        let isCard = mgr.paymentType == .cardPayment
        let refundAmount = mgr.grandTotal
        
        mgr.cancelCheckout()
        
        let dialogText: String
        if isCard {
            dialogText = "Your credit card order has been cancelled, and a refund of \(refundAmount) rupees has been initiated to your account."
        } else {
            dialogText = "Your cash on delivery order has been cancelled successfully."
        }
        
        return .result(dialog: IntentDialog("\(dialogText)"))
    }
}

struct ConfirmKitchenOrderIntent: AppIntent {
    static var title: LocalizedStringResource = "Confirm Kitchen Order"
    static var description = IntentDescription("Instantly locks the active checkout, bypassing the remaining grace seconds.")
    static var openAppWhenRun: Bool = false
    init() {}

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let mgr = CheckoutManager.shared
        if mgr.state == .idle {
            return .result(dialog: IntentDialog("You don't have an active checkout to lock right now."))
        }
        
        mgr.forceLockOrder()
        let dialogText = "Your order \(mgr.orderID) is now locked immediately. Sourcing logistics initiated."
        return .result(dialog: IntentDialog("\(dialogText)"))
    }
}

struct CheckActiveDeliveryStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Kitchen Delivery Status"
    static var description = IntentDescription("Returns the real-time progress and milestone of your active kitchen delivery.")
    static var openAppWhenRun: Bool = false
    init() {}

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let mgr = CheckoutManager.shared
        
        if mgr.state == .idle {
            let dialog = IntentDialog("You don't have any active kitchen delivery right now. Place an order to start tracking.")
            return .result(dialog: dialog, view: EmptyDeliverySnippetView())
        }

        let dialogText: String
        switch mgr.state {
        case .gracePeriodActive(let secs):
            dialogText = "Your order is in the modification grace window. Sourcing logs will freeze in \(secs) seconds."
        case .orderLocked:
            dialogText = "Your order is locked and preparing. Sourcing warehouse is loading your cargo."
        case .dispatched:
            dialogText = "Your consignment is out for delivery. Courier is en route via Connaught Place outer ring road."
        case .arrived:
            dialogText = "Your courier has arrived at your restaurant dock!"
        case .completed:
            dialogText = "Your order is completed. Cargo has been successfully delivered and checked in."
        case .idle:
            dialogText = "No active delivery."
        }

        return .result(dialog: IntentDialog("\(dialogText)"), view: SiriActiveDeliverySnippetView())
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
                    
                    VStack(spacing: 4) {
                        Text("Locking order in: 00:\(String(format: "%02d", seconds))")
                            .font(.subheadline.bold()).foregroundColor(Theme.textPrimary)
                        Text(checkoutManager.paymentType == .cardPayment ? "Paid via Credit Card" : "Payment Mode: Cash on Delivery")
                            .font(.caption).foregroundColor(Theme.textMuted)
                    }

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
            
            case .arrived:
                VStack(spacing: 10) {
                    Image(systemName: "house.fill").font(.title).foregroundColor(.green)
                    Text("Courier Arrived").font(.headline).foregroundColor(Theme.textPrimary)
                }
            
            case .completed:
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill").font(.title).foregroundColor(.green)
                    Text("Order Completed").font(.headline).foregroundColor(Theme.textPrimary)
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

struct EmptyDeliverySnippetView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "box.truck").font(.largeTitle).foregroundColor(Theme.textMuted)
            Text("No Active Delivery").font(.headline).foregroundColor(Theme.textPrimary)
            Text("Your active and past orders will show up here.").font(.caption).foregroundColor(Theme.textSecondary)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }
}

struct SiriActiveDeliverySnippetView: View {
    @State private var mgr = CheckoutManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ORDER STATUS")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Text(mgr.orderID)
                    .font(.system(.caption, design: .monospaced).bold())
                    .foregroundColor(Theme.textSecondary)
            }
            Divider().background(Color.primary.opacity(0.1))

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.primary.opacity(0.06)).frame(height: 8)
                    Capsule()
                        .fill(mgr.state == .arrived || mgr.state == .completed ? Color.green : Theme.primary)
                        .frame(width: geo.size.width * CGFloat(mgr.courierProgress), height: 8)
                        .animation(.spring(), value: mgr.courierProgress)
                }
            }
            .frame(height: 8)

            HStack {
                Text(statusText(for: mgr.state))
                    .font(.subheadline.bold())
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text("₹\(mgr.grandTotal) · \(mgr.paymentType.displayLabel)")
                    .font(.caption)
                    .foregroundColor(Theme.textMuted)
            }

            if case .gracePeriodActive(let secs) = mgr.state {
                Text("Sourcing logs lock in \(secs)s")
                    .font(.caption2.bold())
                    .foregroundColor(.red)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
    }

    private func statusText(for state: CheckoutManager.CheckoutState) -> String {
        switch state {
        case .gracePeriodActive: return "Grace Window Active"
        case .orderLocked:       return "Order Preparing"
        case .dispatched:        return "Out for Delivery"
        case .arrived:           return "Order Reached"
        case .completed:         return "Order Completed"
        case .idle:              return "Idle"
        }
    }
}
