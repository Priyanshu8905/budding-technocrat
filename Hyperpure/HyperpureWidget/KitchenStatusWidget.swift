// KitchenStatusWidget.swift
// Lock Screen Accessory + Home Screen widget for Hyperpure kitchen delivery status.
// Reads live state from shared UserDefaults app group updated by the main app.

import WidgetKit
import SwiftUI

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

// MARK: - Timeline Entry
struct KitchenStatusEntry: TimelineEntry {
    let date: Date
    let orderID: String
    let statusLabel: String
    let statusIcon: String
    let progressFraction: Double
    let isActive: Bool
    let subtotal: Int
    let estimatedArrival: Date
    let paymentMethod: String
}

// MARK: - Provider
struct KitchenStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> KitchenStatusEntry {
        .demo
    }
    func getSnapshot(in context: Context, completion: @escaping (KitchenStatusEntry) -> Void) {
        completion(context.isPreview ? .demo : loadLiveEntry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<KitchenStatusEntry>) -> Void) {
        let entry = loadLiveEntry()
        // Reload every 3 minutes so ETA countdown stays accurate
        let next = Calendar.current.date(byAdding: .minute, value: 3, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadLiveEntry() -> KitchenStatusEntry {
        let d = UserDefaults(suiteName: WidgetDataKey.suiteName) ?? .standard
        let arrivalEpoch = d.double(forKey: WidgetDataKey.arrivalEpoch)
        let arrival = arrivalEpoch > 0 ? Date(timeIntervalSince1970: arrivalEpoch) : Date().addingTimeInterval(1800)
        return KitchenStatusEntry(
            date: .now,
            orderID:       d.string(forKey: WidgetDataKey.orderID)      ?? "",
            statusLabel:   d.string(forKey: WidgetDataKey.statusLabel)   ?? "No Active Order",
            statusIcon:    d.string(forKey: WidgetDataKey.statusIcon)    ?? "bag",
            progressFraction: d.double(forKey: WidgetDataKey.progress),
            isActive:      d.bool(forKey:   WidgetDataKey.isActive),
            subtotal:      d.integer(forKey: WidgetDataKey.subtotal),
            estimatedArrival: arrival,
            paymentMethod: d.string(forKey: WidgetDataKey.paymentMethod) ?? "COD"
        )
    }
}

private extension KitchenStatusEntry {
    static var demo: KitchenStatusEntry {
        KitchenStatusEntry(
            date: .now, orderID: "#HP-4521",
            statusLabel: "Out for Delivery",
            statusIcon: "shippingbox.fill",
            progressFraction: 0.65,
            isActive: true, subtotal: 1240,
            estimatedArrival: Date().addingTimeInterval(720),
            paymentMethod: "Credit Card"
        )
    }
}

// MARK: - Widget Config
struct KitchenStatusWidget: Widget {
    let kind: String = "KitchenStatusWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KitchenStatusProvider()) { entry in
            KitchenStatusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kitchen Delivery")
        .description("Live status and ETA for your active kitchen delivery.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .systemSmall
        ])
    }
}

// MARK: - Entry View
struct KitchenStatusWidgetEntryView: View {
    let entry: KitchenStatusEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryCircular:   circularView
        case .accessoryRectangular: rectangularView
        case .accessoryInline:     inlineView
        default:                   smallSystemView
        }
    }

    // --- Lock Screen Circular ---
    @ViewBuilder var circularView: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 5)
            Circle()
                .trim(from: 0, to: entry.progressFraction)
                .stroke(.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Image(systemName: entry.isActive ? entry.statusIcon : "bag")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
        }
        .widgetAccentable()
    }

    // --- Lock Screen Rectangular ---
    @ViewBuilder var rectangularView: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: entry.isActive ? entry.statusIcon : "bag")
                    .font(.system(size: 10, weight: .bold))
                Text("HYPERPURE")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                Spacer()
                if entry.isActive {
                    Text(entry.orderID)
                        .font(.system(size: 8, design: .monospaced))
                        .opacity(0.7)
                }
            }
            .foregroundStyle(.white)

            if entry.isActive {
                Text(entry.statusLabel)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                HStack(spacing: 3) {
                    Text("ETA")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.7))
                    Text(entry.estimatedArrival, style: .timer)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.9))
                }
            } else {
                Text("No Active Delivery")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .widgetAccentable()
    }

    // --- Lock Screen Inline ---
    @ViewBuilder var inlineView: some View {
        Label {
            Text(entry.isActive ? entry.statusLabel : "No Active Order")
        } icon: {
            Image(systemName: entry.isActive ? entry.statusIcon : "bag")
        }
        .widgetAccentable()
    }

    // --- Home Screen Small ---
    @ViewBuilder var smallSystemView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 239/255, green: 79/255, blue: 95/255),
                    Color(red: 180/255, green: 40/255, blue: 58/255)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "shippingbox.fill")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Spacer()
                    if entry.isActive {
                        Circle()
                            .fill(.green)
                            .frame(width: 7, height: 7)
                            .overlay(Circle().stroke(.white, lineWidth: 1))
                    }
                }
                Spacer()
                if entry.isActive {
                    Text(entry.statusLabel)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    HStack(spacing: 2) {
                        Text("ETA ")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.7))
                        Text(entry.estimatedArrival, style: .timer)
                            .font(.system(size: 9, design: .monospaced).bold())
                            .foregroundColor(.white)
                    }
                    Text("₹\(entry.subtotal) • \(entry.paymentMethod)")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                } else {
                    Text("No active\ndelivery")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
