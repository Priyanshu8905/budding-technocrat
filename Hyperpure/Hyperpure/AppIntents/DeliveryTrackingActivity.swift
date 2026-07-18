// DeliveryTrackingActivity.swift
// ActivityKit Live Activity implementation for delivery tracking on Lock Screen and Dynamic Island.

import Foundation
import ActivityKit
import SwiftUI
import AppIntents
import WidgetKit

public enum DeliveryStep: String, Codable, Hashable {
    case placed
    case partnerAssigned
    case dispatched
    case arrived
}

public struct DeliveryTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var currentStatus: DeliveryStep
        public var estimatedArrival: Date
        
        public init(currentStatus: DeliveryStep, estimatedArrival: Date) {
            self.currentStatus = currentStatus
            self.estimatedArrival = estimatedArrival
        }
    }
    
    public var orderID: String
    public var merchantName: String
    
    public init(orderID: String, merchantName: String) {
        self.orderID = orderID
        self.merchantName = merchantName
    }
}

struct DeliveryTrackingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryTrackingAttributes.self) { context in
            // Lock Screen UI
            DeliveryTrackingLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Dynamic Island
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "shippingbox.circle.fill")
                            .foregroundColor(Theme.primary)
                        Text("Hyperpure")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.primary)
                    }
                    .padding(.leading, 8)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .foregroundColor(Theme.primary)
                        Text(context.state.estimatedArrival, style: .timer)
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundColor(Theme.primary)
                    }
                    .padding(.trailing, 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(statusTitle(for: context.state.currentStatus))
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("ID: \(context.attributes.orderID)")
                                .font(.caption.monospaced())
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Text("Courier is approaching your kitchen outpost.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                }
            } compactLeading: {
                Image(systemName: "shippingbox.circle.fill")
                    .foregroundColor(Theme.primary)
            } compactTrailing: {
                Text(statusTitle(for: context.state.currentStatus))
                    .font(.caption2.bold())
                    .foregroundColor(Theme.primary)
            } minimal: {
                Image(systemName: "shippingbox.circle.fill")
                    .foregroundColor(Theme.primary)
            }
        }
    }
    
    private func statusTitle(for step: DeliveryStep) -> String {
        switch step {
        case .placed: return "Order Secured"
        case .partnerAssigned: return "Courier Ready"
        case .dispatched: return "Out for Delivery"
        case .arrived: return "Arrived at Kitchen"
        }
    }
}

struct DeliveryTrackingLockScreenView: View {
    let context: ActivityViewContext<DeliveryTrackingAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row
            HStack {
                Text("HYPERPURE DELIVERY")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "shippingbox.circle.fill")
                        .foregroundColor(Theme.primary)
                    Text(context.attributes.orderID)
                        .font(.system(.caption, design: .monospaced).bold())
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            Divider()
                .background(Color.primary.opacity(0.1))
            
            // Progress chain node bar
            HStack(spacing: 8) {
                progressNode(title: "Placed", active: true)
                progressLine(active: context.state.currentStatus == .dispatched || context.state.currentStatus == .arrived)
                progressNode(title: "Dispatched", active: context.state.currentStatus == .dispatched || context.state.currentStatus == .arrived)
                progressLine(active: context.state.currentStatus == .arrived)
                progressNode(title: "Arrived", active: context.state.currentStatus == .arrived)
            }
            
            // Driver detail block
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title3)
                        .foregroundColor(Theme.primary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(statusDescription(for: context.state.currentStatus))
                            .font(.subheadline.bold())
                            .foregroundColor(Theme.textPrimary)
                        Text("Courier is approaching your kitchen outpost.")
                            .font(.caption)
                            .foregroundColor(Theme.textMuted)
                    }
                    Spacer()
                    
                    Text(context.state.estimatedArrival, style: .timer)
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .foregroundColor(Theme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.primaryBg, in: Capsule())
                }
            }
            .padding(10)
            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.primary.opacity(0.01), Color.primary.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private func progressNode(title: String, active: Bool) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(active ? Color.green : Color.gray.opacity(0.3))
                .shadow(color: active ? .green.opacity(0.8) : .clear, radius: 4)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 10, weight: active ? .bold : .semibold))
                .foregroundColor(active ? Theme.textPrimary : Theme.textMuted)
        }
    }
    
    private func progressLine(active: Bool) -> some View {
        Rectangle()
            .fill(active ? Color.green : Color.gray.opacity(0.3))
            .frame(height: 2)
            .frame(maxWidth: .infinity)
    }
    
    private func statusDescription(for step: DeliveryStep) -> String {
        switch step {
        case .placed: return "Order finalized. Logistics partner en route."
        case .partnerAssigned: return "Delivery Partner Assigned"
        case .dispatched: return "Out for Delivery"
        case .arrived: return "Courier Arrived"
        }
    }
}

struct PlaceProcurementOrderIntent: AppIntent {
    static var title: LocalizedStringResource = "Place Procurement Order"
    static var description = IntentDescription("Checkout items inside your cart and launch a live lock screen delivery tracker.")
    static var openAppWhenRun: Bool = false
    
    init() {}
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return .result(dialog: IntentDialog("Order secured, but Live Activities are disabled in your iOS settings. Please enable them for Hyperpure under Settings to view lock screen widgets."))
        }
        
        let orderId = "#HP-" + String((1000...9999).randomElement() ?? 5024)
        
        let attributes = DeliveryTrackingAttributes(orderID: orderId, merchantName: "Hyperpure Wholesale")
        
        let initialContentState = DeliveryTrackingAttributes.ContentState(
            currentStatus: .placed,
            estimatedArrival: Date().addingTimeInterval(1800) // 30 mins
        )
        
        do {
            let activity = try Activity<DeliveryTrackingAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: initialContentState, staleDate: nil),
                pushType: nil
            )
            return .result(dialog: IntentDialog("Order secured. Live tracking activity requested successfully with ID \(activity.id)."))
        } catch {
            return .result(dialog: IntentDialog("Activity request failed with error: \(error.localizedDescription)"))
        }
    }
}
