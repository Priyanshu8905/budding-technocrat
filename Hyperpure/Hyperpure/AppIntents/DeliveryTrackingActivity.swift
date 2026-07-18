// DeliveryTrackingActivity.swift
// ActivityKit Live Activity — Lock Screen + Dynamic Island with dynamic attributes.

import Foundation
import ActivityKit
import SwiftUI
import WidgetKit

public enum DeliveryStep: String, Codable, Hashable {
    case placed
    case partnerAssigned
    case dispatched
    case arrived
}

// MARK: - Dynamic Attributes (static metadata + live ContentState)

public struct DeliveryTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var currentStatus: DeliveryStep
        public var estimatedArrival: Date        // drives Text(.timer) countdown
        public var subtotal: Int                 // computed from live cart manifest
        public var paymentMethod: String         // "Cash on Delivery" | "Credit Card"
        public var itemCount: Int                // true item count from cart
        
        public init(currentStatus: DeliveryStep, estimatedArrival: Date, subtotal: Int = 0, paymentMethod: String = "COD", itemCount: Int = 0) {
            self.currentStatus = currentStatus
            self.estimatedArrival = estimatedArrival
            self.subtotal = subtotal
            self.paymentMethod = paymentMethod
            self.itemCount = itemCount
        }
    }
    
    public var orderID: String
    public var merchantName: String
    
    public init(orderID: String, merchantName: String) {
        self.orderID = orderID
        self.merchantName = merchantName
    }
}

// MARK: - Live Activity Widget

struct DeliveryTrackingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryTrackingAttributes.self) { context in
            DeliveryTrackingLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "shippingbox.circle.fill").foregroundColor(Theme.primary)
                        Text("Hyperpure")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.primary)
                    }
                    .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer").foregroundColor(Theme.primary)
                        // Live countdown using .timer style — updates automatically
                        Text(context.state.estimatedArrival, style: .timer)
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundColor(Theme.primary)
                    }
                    .padding(.trailing, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(statusTitle(for: context.state.currentStatus))
                                .font(.subheadline.bold()).foregroundColor(.white)
                            Spacer()
                            Text("ID: \(context.attributes.orderID)")
                                .font(.caption.monospaced()).foregroundColor(.white.opacity(0.6))
                        }
                        HStack(spacing: 6) {
                            Text("\(context.state.itemCount) items · ₹\(context.state.subtotal)")
                                .font(.caption).foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text(context.state.paymentMethod)
                                .font(.caption2.bold()).foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 4)
                }
            } compactLeading: {
                Image(systemName: "shippingbox.circle.fill").foregroundColor(Theme.primary)
            } compactTrailing: {
                // Live timer in compact trailing — ticks every second automatically
                Text(context.state.estimatedArrival, style: .timer)
                    .font(.caption2.bold()).foregroundColor(Theme.primary).frame(maxWidth: 40)
            } minimal: {
                Image(systemName: "shippingbox.circle.fill").foregroundColor(Theme.primary)
            }
        }
    }
    
    private func statusTitle(for step: DeliveryStep) -> String {
        switch step {
        case .placed:          return "Order Secured"
        case .partnerAssigned: return "Courier Ready"
        case .dispatched:      return "Out for Delivery"
        case .arrived:         return "Arrived at Kitchen"
        }
    }
}

// MARK: - Lock Screen View

struct DeliveryTrackingLockScreenView: View {
    let context: ActivityViewContext<DeliveryTrackingAttributes>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack {
                Text("HYPERPURE DELIVERY")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(Theme.primary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "shippingbox.circle.fill").foregroundColor(Theme.primary)
                    Text(context.attributes.orderID)
                        .font(.system(.caption, design: .monospaced).bold())
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            Divider().background(Color.primary.opacity(0.1))
            
            // Progress chain
            HStack(spacing: 8) {
                progressNode(title: "Placed", active: true)
                progressLine(active: context.state.currentStatus != .placed)
                progressNode(title: "Assigned", active: context.state.currentStatus == .partnerAssigned || context.state.currentStatus == .dispatched || context.state.currentStatus == .arrived)
                progressLine(active: context.state.currentStatus == .dispatched || context.state.currentStatus == .arrived)
                progressNode(title: "Dispatched", active: context.state.currentStatus == .dispatched || context.state.currentStatus == .arrived)
                progressLine(active: context.state.currentStatus == .arrived)
                progressNode(title: "Arrived", active: context.state.currentStatus == .arrived)
            }
            
            // Status + live ETA block
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(statusDescription(for: context.state.currentStatus))
                        .font(.subheadline.bold()).foregroundColor(Theme.textPrimary)
                    // Dynamic item count + subtotal from live ContentState
                    Text("\(context.state.itemCount) items · ₹\(context.state.subtotal) · \(context.state.paymentMethod)")
                        .font(.caption).foregroundColor(Theme.textMuted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("ETA").font(.system(size: 9)).foregroundColor(Theme.textMuted)
                    // Text with .timer style updates automatically every second
                    Text(context.state.estimatedArrival, style: .timer)
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .foregroundColor(Theme.primary)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(Theme.primaryBg, in: Capsule())
                }
            }
            .padding(10)
            .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(
            LinearGradient(colors: [Color.primary.opacity(0.01), Color.primary.opacity(0.03)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
    
    private func progressNode(title: String, active: Bool) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(active ? Color.green : Color.gray.opacity(0.3))
                .shadow(color: active ? .green.opacity(0.8) : .clear, radius: 4)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 9, weight: active ? .bold : .semibold))
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
        case .placed:          return "Order finalized. Logistics partner en route."
        case .partnerAssigned: return "Delivery Partner Assigned"
        case .dispatched:      return "Out for Delivery"
        case .arrived:         return "Courier Arrived"
        }
    }
}
