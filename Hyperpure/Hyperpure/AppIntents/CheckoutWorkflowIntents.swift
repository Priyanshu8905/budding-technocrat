// CheckoutWorkflowIntents.swift
// Transactional checkout grace-period state machine and Siri checkout intents.

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
        } else {
            updatedState = DeliveryTrackingAttributes.ContentState(
                currentStatus: step,
                estimatedArrival: Date().addingTimeInterval(900)
            )
        }
        
        await activity.update(using: updatedState)
    }
}

struct CancelCheckoutIntent: AppIntent {
    static var title: LocalizedStringResource = "Cancel Active Checkout"
    static var description = IntentDescription("Abort the active checkout grace period and restore cart parameters.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        CheckoutManager.shared.cancelCheckout()
        return .result(dialog: IntentDialog("Checkout aborted. Your cart configuration has been fully restored."))
    }
}

struct InitiateCheckoutWorkflowIntent: AppIntent {
    static var title: LocalizedStringResource = "Checkout my Hyperpure cart"
    static var description = IntentDescription("Secures order and triggers a 30-second modification grace window.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        CheckoutManager.shared.startCheckout()
        
        let dialog = IntentDialog("Checkout initiated. You have a 30-second window to alter or cancel your configuration right on your screen before logistics lock in.")
        
        return .result(
            dialog: dialog,
            view: CheckoutGracePeriodSnippetView()
        )
    }
}

struct CheckoutGracePeriodSnippetView: View {
    @State private var checkoutManager = CheckoutManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Header Row
            HStack {
                Text("HYPERPURE SECURE CHECKOUT")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(Theme.primary)
            }
            
            Divider()
                .background(Color.primary.opacity(0.1))
            
            switch checkoutManager.state {
            case .gracePeriodActive(let seconds):
                VStack(spacing: 14) {
                    // Circular Progress Rings
                    ZStack {
                        Circle()
                            .stroke(Color.primary.opacity(0.06), lineWidth: 8)
                            .frame(width: 90, height: 90)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(seconds) / 30.0)
                            .stroke(Theme.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 90, height: 90)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.2), value: seconds)
                        
                        VStack(spacing: 2) {
                            Text("\(seconds)s")
                                .font(.system(.title3, design: .rounded).weight(.bold))
                                .foregroundColor(Theme.textPrimary)
                            Text("Grace Left")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(Theme.textMuted)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Text("Delivery Outpost coordinates mapping. Sourcing pipelines will lock automatically after timer elapses.")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                    
                    // Buttons
                    HStack(spacing: 10) {
                        Button(intent: CancelCheckoutIntent()) {
                            Text("Cancel Order")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.red, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                        
                        Button(intent: CancelCheckoutIntent()) {
                            Text("Add More Items")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Theme.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Theme.primaryBg, in: RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
            case .orderLocked:
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                    
                    Text("Order Locked")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Sourcing channels locked in. Delivery logistics allocating partner.")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 10)
                
            case .dispatched:
                VStack(spacing: 10) {
                    Image(systemName: "truck.box.fill")
                        .font(.largeTitle)
                        .foregroundColor(Theme.primary)
                    
                    Text("Fulfillment Dispatched")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Courier has left the outpost and is en route to your kitchen.")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 10)
                
            case .idle:
                Text("No active checkout session.")
                    .font(.subheadline)
                    .foregroundColor(Theme.textMuted)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 4)
    }
}
