// CheckoutWorkflowIntents.swift
// Complete 5-step transactional checkout grace period, Siri voice ordering, and Live Activity launcher.

import Foundation
import AppIntents
import SwiftUI
import ActivityKit

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
    private var timerTask: Task<Void, Never>?
    
    private init() {}
    
    public func startCheckout() {
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
    }
    
    private func lockOrder() {
        state = .orderLocked
        
        // Start ActivityKit Live Activity
        let attributes = DeliveryTrackingAttributes(orderID: orderID, merchantName: "Hyperpure Wholesale")
        let initialContentState = DeliveryTrackingAttributes.ContentState(
            currentStatus: .placed,
            estimatedArrival: Date().addingTimeInterval(1800) // 30 mins
        )
        
        do {
            let _ = try Activity<DeliveryTrackingAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: initialContentState, staleDate: nil),
                pushType: nil
            )
            postLocalNotification(title: "Order Finalized", body: "Sourcing pipeline locked in. Delivery tracking active.")
        } catch {
            print("Failed to start Live Activity: \(error.localizedDescription)")
        }
        
        // Simulate step transitions over time
        Task {
            try? await Task.sleep(for: .seconds(8))
            await updateLiveActivity(step: .partnerAssigned)
            try? await Task.sleep(for: .seconds(8))
            await updateLiveActivity(step: .dispatched)
            try? await Task.sleep(for: .seconds(8))
            await updateLiveActivity(step: .arrived)
        }
    }
    
    private func updateLiveActivity(step: DeliveryStep) async {
        guard let activity = Activity<DeliveryTrackingAttributes>.activities.first(where: { $0.attributes.orderID == self.orderID }) else { return }
        
        let updatedState: DeliveryTrackingAttributes.ContentState
        if step == .arrived {
            self.state = .dispatched
            updatedState = DeliveryTrackingAttributes.ContentState(
                currentStatus: step,
                estimatedArrival: Date()
            )
            postLocalNotification(title: "Courier Arrived", body: "Consignment successfully delivered to your restaurant dock!")
        } else {
            updatedState = DeliveryTrackingAttributes.ContentState(
                currentStatus: step,
                estimatedArrival: Date().addingTimeInterval(900)
            )
            if step == .partnerAssigned {
                postLocalNotification(title: "Courier Assigned", body: "Delivery partner is loading consignment at warehouse.")
            } else if step == .dispatched {
                postLocalNotification(title: "Consignment Dispatched", body: "Logistics partner has departed warehouse hub.")
            }
        }
        
        await activity.update(using: updatedState)
    }
}

// MARK: - App Intents

struct GetKitchenInsightsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Kitchen Sourcing Insights"
    static var description = IntentDescription("Fetches simulated severe weather conditions and recommends procurement actions.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let dialogue = IntentDialog("Heavy monsoon downpours detected in your area. supply chain transit time is increased by forty-five minutes. I recommend scaling up flour and potato stocks by fifteen percent to buffer against logistical delays.")
        
        return .result(
            dialog: dialogue,
            view: KitchenInsightsSnippetView()
        )
    }
}

struct PlaceProcurementOrderIntent: AppIntent {
    static var title: LocalizedStringResource = "Place Procurement Order"
    static var description = IntentDescription("Processes the local cart and transitions the state machine to the checkout grace window.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        CheckoutManager.shared.startCheckout()
        
        let dialog = IntentDialog("Order received. Starting your thirty-second modification grace window. You can cancel or edit the items right from your screen before dispatch logs freeze.")
        
        return .result(
            dialog: dialog,
            view: CheckoutGracePeriodSnippetView()
        )
    }
}

// MARK: - Snippet Views

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
            
            Divider()
                .background(Color.primary.opacity(0.1))
            
            VStack(alignment: .leading, spacing: 6) {
                Text("RECOMMENDED ADJUSTMENTS:")
                    .font(.caption2.bold())
                    .foregroundColor(Theme.textMuted)
                
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
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
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct CheckoutGracePeriodSnippetView: View {
    @State private var checkoutManager = CheckoutManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("SECURE OUTPOST CHECKOUT")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Image(systemName: "clock.badge.checkmark.fill")
                    .foregroundColor(Theme.primary)
            }
            
            Divider()
                .background(Color.primary.opacity(0.1))
            
            switch checkoutManager.state {
            case .gracePeriodActive(let seconds):
                VStack(spacing: 14) {
                    // Ring
                    ZStack {
                        Circle()
                            .stroke(Color.primary.opacity(0.06), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
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
                    
                    Text("Locking order in: 00:\(seconds, specifier: "%02d")")
                        .font(.subheadline.bold())
                        .foregroundColor(Theme.textPrimary)
                    
                    HStack(spacing: 10) {
                        Button(intent: CancelCheckoutIntent()) {
                            Text("Cancel Order")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        
                        Button(intent: CancelCheckoutIntent()) {
                            Text("Add More Items")
                                .font(.caption.bold())
                                .foregroundColor(Theme.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Theme.primaryBg)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
            case .orderLocked:
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.title)
                        .foregroundColor(.green)
                    
                    Text("Order Finalized & Frozen")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Consignment locked. Live Tracking active on your Lock Screen.")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
            case .dispatched:
                VStack(spacing: 10) {
                    Image(systemName: "truck.box.fill")
                        .font(.title)
                        .foregroundColor(Theme.primary)
                    
                    Text("Consignment Dispatched")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                }
                
            case .idle:
                Text("No active checkout session.")
                    .font(.caption)
                    .foregroundColor(Theme.textMuted)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
        )
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
