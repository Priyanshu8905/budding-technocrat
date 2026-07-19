// DeliveryTrackingLiveActivity.swift
// Live Activity widget for order delivery tracking on Lock Screen and Dynamic Island.

import WidgetKit
import SwiftUI
import ActivityKit

enum DeliveryStep: String, Codable, Hashable {
    case placed
    case partnerAssigned
    case dispatched
    case arrived
    case completed
}

struct DeliveryTrackingAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentStatus: DeliveryStep
        var estimatedArrival: Date
        var subtotal: Int
        var paymentMethod: String
        var itemCount: Int
    }

    var orderID: String
    var merchantName: String
}

struct DeliveryTrackingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryTrackingAttributes.self) { context in
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Image(systemName: "shippingbox.circle.fill")
                            .foregroundColor(Color(red: 239/255, green: 79/255, blue: 95/255))
                        Text("Hyperpure")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 239/255, green: 79/255, blue: 95/255))
                    }
                    .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .foregroundColor(Color(red: 239/255, green: 79/255, blue: 95/255))
                        Text(context.state.estimatedArrival, style: .timer)
                            .font(.system(.subheadline, design: .monospaced).bold())
                            .foregroundColor(Color(red: 239/255, green: 79/255, blue: 95/255))
                    }
                    .padding(.trailing, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(statusTitle(for: context.state.currentStatus))
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            Spacer()
                            Text("ID: \(context.attributes.orderID)")
                                .font(.caption.monospaced())
                                .foregroundColor(.white.opacity(0.6))
                        }
                        HStack(spacing: 6) {
                            Text("\(context.state.itemCount) items · ₹\(context.state.subtotal)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text(context.state.paymentMethod)
                                .font(.caption2.bold())
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                }
            } compactLeading: {
                Image(systemName: "shippingbox.circle.fill")
                    .foregroundColor(Color(red: 239/255, green: 79/255, blue: 95/255))
            } compactTrailing: {
                Text(context.state.estimatedArrival, style: .timer)
                    .font(.caption2.bold())
                    .foregroundColor(Color(red: 239/255, green: 79/255, blue: 95/255))
                    .frame(maxWidth: 40)
            } minimal: {
                Image(systemName: "shippingbox.circle.fill")
                    .foregroundColor(Color(red: 239/255, green: 79/255, blue: 95/255))
            }
        }
    }

    private func statusTitle(for step: DeliveryStep) -> String {
        switch step {
        case .placed:          return "Order Secured"
        case .partnerAssigned: return "Courier Ready"
        case .dispatched:      return "Out for Delivery"
        case .arrived:         return "Arrived at Kitchen"
        case .completed:       return "Order Completed"
        }
    }
}

struct LockScreenView: View {
    let context: ActivityViewContext<DeliveryTrackingAttributes>
    private let hpPrimary = Color(red: 239/255, green: 79/255, blue: 95/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("HYPERPURE DELIVERY")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundColor(hpPrimary)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "shippingbox.circle.fill")
                        .foregroundColor(hpPrimary)
                    Text(context.attributes.orderID)
                        .font(.system(.caption, design: .monospaced).bold())
                        .foregroundColor(.secondary)
                }
            }

            Divider().background(Color.primary.opacity(0.1))

            HStack(spacing: 8) {
                progressNode(title: "Placed", active: true)
                progressLine(active: context.state.currentStatus != .placed)
                progressNode(title: "Assigned", active: [.partnerAssigned, .dispatched, .arrived, .completed].contains(context.state.currentStatus))
                progressLine(active: [.dispatched, .arrived, .completed].contains(context.state.currentStatus))
                progressNode(title: "Transit", active: [.dispatched, .arrived, .completed].contains(context.state.currentStatus))
                progressLine(active: [.arrived, .completed].contains(context.state.currentStatus))
                progressNode(title: "Reached", active: [.arrived, .completed].contains(context.state.currentStatus))
                progressLine(active: context.state.currentStatus == .completed)
                progressNode(title: "Done", active: context.state.currentStatus == .completed)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(statusDescription(for: context.state.currentStatus))
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Text("\(context.state.itemCount) items · ₹\(context.state.subtotal) · \(context.state.paymentMethod)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("ETA")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text(context.state.estimatedArrival, style: .timer)
                        .font(.system(.subheadline, design: .monospaced).bold())
                        .foregroundColor(hpPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(hpPrimary.opacity(0.1), in: Capsule())
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
                .foregroundColor(active ? .primary : .secondary)
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
        case .arrived:         return "Courier Arrived / Order Reached"
        case .completed:       return "Order Completed Successfully"
        }
    }
}
