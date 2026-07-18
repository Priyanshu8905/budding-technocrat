// OrderConfirmationView.swift
// Reads all data from CheckoutManager.shared — no static params needed.
// Timer persists when screen is dismissed. Cart cleared when order placed.

import SwiftUI
import ActivityKit
import MapKit
import UserNotifications

struct OrderConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CartViewModel.self) private var cartViewModel

    let shouldStartGracePeriod: Bool

    @State private var checkoutManager = CheckoutManager.shared
    @State private var showCancelAlert = false

    private var secondsRemaining: Int {
        if case .gracePeriodActive(let s) = checkoutManager.state { return s }
        return 0
    }
    private var isLocked: Bool {
        checkoutManager.state == .orderLocked || checkoutManager.state == .dispatched
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {

                        // Success header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.green.opacity(0.15), .green.opacity(0.04)],
                                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 130, height: 130)
                                Circle()
                                    .stroke(LinearGradient(colors: [.green, .green.opacity(0.4)],
                                                           startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4)
                                    .frame(width: 110, height: 110)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(LinearGradient(colors: [.green, .emerald],
                                                                    startPoint: .topLeading, endPoint: .bottomTrailing))
                            }
                            .padding(.top, 40)

                            VStack(spacing: 6) {
                                Text("Order Received Successfully!")
                                    .font(.title2.weight(.bold)).foregroundColor(Theme.textPrimary)
                                Text("ID: \(checkoutManager.orderID)")
                                    .font(.subheadline.monospaced()).foregroundColor(Theme.textMuted)
                            }
                        }

                        // Dynamic payment badge
                        HStack(spacing: 8) {
                            Image(systemName: checkoutManager.paymentType.icon)
                                .foregroundColor(checkoutManager.paymentType == .cardPayment ? .green : Theme.primary)
                            Text("Paid via \(checkoutManager.paymentType.displayLabel)")
                                .font(.subheadline.bold())
                                .foregroundColor(checkoutManager.paymentType == .cardPayment ? .green : Theme.primary)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                        .background((checkoutManager.paymentType == .cardPayment ? Color.green : Theme.primary).opacity(0.1))
                        .cornerRadius(30)

                        // Delivery target card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "box.truck.fill").foregroundColor(Theme.primary)
                                Text("DELIVERY TARGET")
                                    .font(.caption.bold()).foregroundColor(Theme.textMuted)
                            }
                            Divider()
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Kitchen Outpost NCR-08")
                                    .font(.subheadline.bold()).foregroundColor(Theme.textPrimary)
                                Text("Connaught Place Block-B, New Delhi")
                                    .font(.caption).foregroundColor(Theme.textSecondary)
                                Text("Contact: +91 98765 43210")
                                    .font(.caption).foregroundColor(Theme.textSecondary)
                            }
                            Divider()
                            HStack {
                                Text("Total Amount Paid")
                                    .font(.subheadline).foregroundColor(Theme.textSecondary)
                                Spacer()
                                Text("₹\(checkoutManager.grandTotal)")
                                    .font(.subheadline.bold()).foregroundColor(Theme.primary)
                            }
                        }
                        .padding(16)
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(Theme.radiusMd)
                        .padding(.horizontal)

                        // Order items (real data from CheckoutManager)
                        if !checkoutManager.purchasedItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("ORDER ITEMS (\(checkoutManager.purchasedItems.count))")
                                    .font(.caption.bold()).foregroundColor(Theme.textMuted)
                                Divider()
                                ForEach(checkoutManager.purchasedItems) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.product.name)
                                                .font(.subheadline.bold()).foregroundColor(Theme.textPrimary)
                                            Text("Qty: \(item.quantity) × ₹\(Int(round(item.product.price)))")
                                                .font(.caption).foregroundColor(Theme.textSecondary)
                                        }
                                        Spacer()
                                        Text("₹\(item.subtotal)")
                                            .font(.subheadline.bold()).foregroundColor(Theme.textPrimary)
                                    }
                                    .padding(.vertical, 2)
                                }
                                Divider()
                                SummaryRow(title: "Subtotal",  value: "₹\(checkoutManager.subtotal)")
                                SummaryRow(title: "GST (5%)", value: "₹\(checkoutManager.tax)")
                                SummaryRow(title: "Delivery",  value: checkoutManager.deliveryFee == 0 ? "FREE" : "₹\(checkoutManager.deliveryFee)")
                            }
                            .padding(16)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(Theme.radiusMd)
                            .padding(.horizontal)
                        }

                        // Live dispatch timer (shows only during grace)
                        if !isLocked {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DISPATCH ELAPSED")
                                    .font(.caption.bold()).foregroundColor(Theme.textMuted)
                                Divider()
                                HStack(spacing: 8) {
                                    Image(systemName: "stopwatch.fill").foregroundColor(Theme.primary)
                                    Text("Time since order placed: ")
                                        .font(.caption).foregroundColor(Theme.textSecondary)
                                    // Live elapsed timer using .timer style
                                    Text(checkoutManager.dispatchedAt, style: .timer)
                                        .font(.system(.subheadline, design: .monospaced).bold())
                                        .foregroundColor(Theme.primary)
                                }
                            }
                            .padding(16)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(Theme.radiusMd)
                            .padding(.horizontal)
                        }

                        // Map shown when locked
                        if isLocked {
                            SourcingMapView()
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("ORDER SPECIFICATIONS")
                                    .font(.caption.bold()).foregroundColor(Theme.textMuted)
                                Divider()
                                Text("Fresh produce and raw ingredients queued at logistics dispatch. Sourcing coordinates frozen for on-device tracking.")
                                    .font(.caption).foregroundColor(Theme.textSecondary).lineSpacing(4)
                            }
                            .padding(16)
                            .background(Color(uiColor: .systemBackground))
                            .cornerRadius(Theme.radiusMd)
                            .padding(.horizontal)
                            .transition(.opacity)
                        }
                    }
                    .padding(.bottom, 160)
                }

                // Go to Dashboard — returns to HomeView root
                if isLocked {
                    VStack {
                        Button {
                            AppState.shared.isCartPresented = false
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "house.fill").font(.subheadline.bold())
                                Text("Go to Dashboard").font(.headline.bold())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(Theme.primary).cornerRadius(Theme.radiusMd)
                        }
                        .padding()
                    }
                    .background(Color(uiColor: .systemBackground))
                }
            }

            // Persistent Grace Period Bottom Bar
            if !isLocked {
                VStack {
                    Spacer()
                    VStack(spacing: 14) {
                        // Countdown ring
                        HStack(spacing: 12) {
                            ZStack {
                                Circle().stroke(Color.primary.opacity(0.08), lineWidth: 4).frame(width: 32, height: 32)
                                Circle()
                                    .trim(from: 0, to: CGFloat(secondsRemaining) / 30.0)
                                    .stroke(Color.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 32, height: 32)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.linear(duration: 0.2), value: secondsRemaining)
                                Text("\(secondsRemaining)")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Locking in: 00:\(String(format: "%02d", secondsRemaining))")
                                    .font(.subheadline.bold()).foregroundColor(Theme.textPrimary)
                                Text("Modify or abort during this grace period.")
                                    .font(.caption2).foregroundColor(Theme.textMuted)
                            }
                            Spacer()
                        }

                        // Action buttons
                        HStack(spacing: 12) {
                            // Add Items — dismiss only, timer keeps running
                            Button { dismiss() } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus").font(.caption.bold())
                                    Text("Add Items").font(.subheadline.bold())
                                }
                                .foregroundColor(Theme.primary)
                                .padding(.vertical, 12).frame(maxWidth: .infinity)
                                .background(Theme.primaryBg).cornerRadius(10)
                            }.buttonStyle(.plain)

                            Button { showCancelAlert = true } label: {
                                Text("Cancel Order")
                                    .font(.subheadline.bold()).foregroundColor(.white)
                                    .padding(.vertical, 12).frame(maxWidth: .infinity)
                                    .background(Color.red).cornerRadius(10)
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(Color.primary.opacity(0.1), lineWidth: 1))
                    .padding(.horizontal).padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            requestNotificationPermission()
            postLocalNotification(
                title: "Order Placed Successfully",
                body: "Order \(checkoutManager.orderID) · ₹\(checkoutManager.grandTotal) received."
            )

            // If CheckoutManager is idle here (opened directly), kick off grace
            if shouldStartGracePeriod && checkoutManager.state == .idle {
                CheckoutManager.shared.startCheckout(
                    items: cartViewModel.items,
                    subtotal: cartViewModel.subtotal,
                    tax: cartViewModel.tax,
                    deliveryFee: cartViewModel.deliveryFee,
                    grandTotal: cartViewModel.grandTotal,
                    paymentType: .cashOnDelivery
                )
                cartViewModel.clear()
            } else if !shouldStartGracePeriod && checkoutManager.state == .idle {
                CheckoutManager.shared.state = .orderLocked
                launchLiveActivity()
            }

            // Watch for grace → locked transition to fire Live Activity
            Task {
                while true {
                    try? await Task.sleep(for: .seconds(1))
                    let s = await MainActor.run { CheckoutManager.shared.state }
                    if s == .orderLocked {
                        await MainActor.run {
                            postLocalNotification(title: "Order Finalized", body: "30s grace elapsed. Sourcing pipeline locked.")
                            launchLiveActivity()
                            WidgetDataBridge.shared.writeActiveDelivery(
                                orderID: CheckoutManager.shared.orderID,
                                statusLabel: "Order Locked & Preparing",
                                statusIcon: "lock.fill",
                                progressFraction: 0.2,
                                subtotal: CheckoutManager.shared.grandTotal,
                                estimatedArrival: Date().addingTimeInterval(1800),
                                paymentMethod: CheckoutManager.shared.paymentType.displayLabel
                            )
                        }
                        break
                    }
                    if s == .idle { break }
                }
            }
        }
        .alert("Abort Order?", isPresented: $showCancelAlert) {
            Button("Yes, Cancel", role: .destructive) {
                // Cancel clears cart and dismisses to home
                CheckoutManager.shared.cancelCheckout()
                AppState.shared.isCartPresented = false
            }
            Button("No, Keep Order", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this order?")
        }
    }

    private func launchLiveActivity() {
        let attrs = DeliveryTrackingAttributes(orderID: checkoutManager.orderID, merchantName: "Hyperpure Wholesale")
        let initState = DeliveryTrackingAttributes.ContentState(
            currentStatus: .placed,
            estimatedArrival: Date().addingTimeInterval(1800),
            subtotal: checkoutManager.grandTotal,
            paymentMethod: checkoutManager.paymentType.displayLabel,
            itemCount: checkoutManager.purchasedItems.count
        )
        do {
            let _ = try Activity<DeliveryTrackingAttributes>.request(
                attributes: attrs,
                content: ActivityContent(state: initState, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Live Activity error: \(error)")
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
}

public func postLocalNotification(title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    let request = UNNotificationRequest(
        identifier: UUID().uuidString,
        content: content,
        trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    )
    UNUserNotificationCenter.current().add(request)
}

extension Color {
    static let emerald = Color(red: 16/255, green: 185/255, blue: 129/255)
}

struct SourcingMapView: View {
    let warehouse   = CLLocationCoordinate2D(latitude: 28.6270, longitude: 77.2150)
    let destination = CLLocationCoordinate2D(latitude: 28.6328, longitude: 77.2195)

    @State private var courierPosition = CLLocationCoordinate2D(latitude: 28.6270, longitude: 77.2150)
    @State private var progress: Double = 0.0
    @State private var timer: Timer?
    @State private var notifiedSteps: Set<Int> = []
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 28.6299, longitude: 77.2172),
                           span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012))
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "map.fill").foregroundColor(Theme.primary)
                    Text("LIVE ROUTING MAP").font(.caption.bold()).foregroundColor(Theme.textMuted)
                }
                Spacer()
                Text("\(Int(progress * 100))% En Route")
                    .font(.caption.bold())
                    .foregroundColor(progress >= 1.0 ? .green : Theme.primary)
            }

            Map(position: $position) {
                Marker("Sourcing Warehouse", systemImage: "building.2.fill", coordinate: warehouse).tint(.blue)
                Marker("Kitchen Outpost (NCR-08)", systemImage: "fork.knife", coordinate: destination).tint(Theme.primary)
                Annotation("Courier", coordinate: courierPosition) {
                    ZStack {
                        Circle().fill(.green).frame(width: 32, height: 32).shadow(color: .green.opacity(0.6), radius: 6)
                        Image(systemName: "shippingbox.fill").foregroundColor(.white).font(.system(size: 13, weight: .bold))
                    }
                }
            }
            .frame(height: 220)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.1), lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                Text(progress >= 1.0 ? "Courier arrived at your restaurant dock." : "Consignment dispatched. Tracking active in real-time.")
                    .font(.caption.bold()).foregroundColor(Theme.textPrimary)
                Text("Delhi-NCR Hub Route: cp-outer-ring-rd")
                    .font(.system(size: 9).monospaced()).foregroundColor(Theme.textMuted)
            }
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(Theme.radiusMd)
        .padding(.horizontal)
        .onAppear { startCourierSimulation() }
        .onDisappear { timer?.invalidate() }
    }

    private func startCourierSimulation() {
        progress = 0.0; courierPosition = warehouse; notifiedSteps = []
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            if progress < 1.0 {
                withAnimation(.linear(duration: 1.5)) {
                    progress += 0.05
                    if progress > 1.0 { progress = 1.0 }
                    let lat = warehouse.latitude + (destination.latitude - warehouse.latitude) * progress
                    let lon = warehouse.longitude + (destination.longitude - warehouse.longitude) * progress
                    courierPosition = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                }
                let pct = Int(round(progress * 100))
                if pct >= 20 && pct < 60 && !notifiedSteps.contains(20) {
                    notifiedSteps.insert(20)
                    postLocalNotification(title: "Courier Assigned", body: "Loading consignment at CP warehouse.")
                    WidgetDataBridge.shared.updateProgress(0.4, statusLabel: "Courier Assigned", statusIcon: "person.fill")
                } else if pct >= 60 && pct < 100 && !notifiedSteps.contains(60) {
                    notifiedSteps.insert(60)
                    postLocalNotification(title: "Consignment Dispatched", body: "Logistics partner departed hub.")
                    WidgetDataBridge.shared.updateProgress(0.7, statusLabel: "Out for Delivery", statusIcon: "shippingbox.fill")
                }
            } else {
                timer?.invalidate()
                if !notifiedSteps.contains(100) {
                    notifiedSteps.insert(100)
                    postLocalNotification(title: "Courier Arrived 🎉", body: "Delivered to your restaurant dock!")
                    CheckoutManager.shared.state = .dispatched
                    WidgetDataBridge.shared.updateProgress(1.0, statusLabel: "Delivered!", statusIcon: "checkmark.seal.fill")
                }
            }
        }
    }
}
