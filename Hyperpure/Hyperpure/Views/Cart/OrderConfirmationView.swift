import SwiftUI
import MapKit
import UserNotifications

struct OrderConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CartViewModel.self) private var cartViewModel
    
    let orderID: String
    let amount: Int
    let shouldStartGracePeriod: Bool
    
    @State private var secondsRemaining = 30
    @State private var isLocked = false
    @State private var timer: Timer?
    @State private var showCancelAlert = false
    
    var body: some View {
        ZStack {
            // Elegant premium dark background to match the theme
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 28) {
                        // Celebratory checkmark animation header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.green.opacity(0.15), Color.green.opacity(0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 130, height: 130)
                                
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [.green, .green.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 4
                                    )
                                    .frame(width: 110, height: 110)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.green, .emerald],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .padding(.top, 40)
                            
                            VStack(spacing: 6) {
                                Text("Order Received Successfully!")
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(Theme.textPrimary)
                                
                                Text("ID: \(orderID)")
                                    .font(.subheadline.monospaced())
                                    .foregroundColor(Theme.textMuted)
                            }
                        }
                        
                        // Sourcing delivery coordinates & details card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "box.truck.fill")
                                    .foregroundColor(Theme.primary)
                                Text("DELIVERY TARGET")
                                    .font(.caption.bold())
                                    .foregroundColor(Theme.textMuted)
                            }
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Kitchen Outpost NCR-08")
                                    .font(.subheadline.bold())
                                    .foregroundColor(Theme.textPrimary)
                                Text("Connaught Place Block-B, New Delhi")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Paid Via")
                                    .font(.caption)
                                    .foregroundColor(Theme.textMuted)
                                Spacer()
                                Text("Cash on Delivery (COD)")
                                    .font(.caption.bold())
                                    .foregroundColor(Theme.textPrimary)
                            }
                            
                            HStack {
                                Text("Total Amount Paid")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textSecondary)
                                Spacer()
                                Text("₹\(amount)")
                                    .font(.subheadline.bold())
                                    .foregroundColor(Theme.primary)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        
                        if isLocked {
                            SourcingMapView()
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            // Sourcing pipeline details card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("ORDER SPECIFICATIONS")
                                    .font(.caption.bold())
                                    .foregroundColor(Theme.textMuted)
                                
                                Divider()
                                
                                Text("Fresh produce and raw ingredients are currently queued at the logistics dispatch queue. Sourcing coordinates frozen for on-device tracking.")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                    .lineSpacing(4)
                            }
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .transition(.opacity)
                        }
                    }
                    .padding(.bottom, 160) // Extra padding for persistent bottom bar
                }
                
                // Return Home button (visible only when order is locked)
                if isLocked {
                    VStack {
                        Button {
                            cartViewModel.clear()
                            dismiss()
                        } label: {
                            Text("Go back to Dashboard")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.primary)
                                .clipShape(Capsule())
                        }
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .background(Color(uiColor: .systemBackground))
                }
            }
            
            // Persistent Bottom Bar
            if !isLocked {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 14) {
                        // Countdown row
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(Color.primary.opacity(0.08), lineWidth: 4)
                                    .frame(width: 32, height: 32)
                                
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
                                Text("Locking order in: 00:\(secondsRemaining, specifier: "%02d")")
                                    .font(.subheadline.bold())
                                    .foregroundColor(Theme.textPrimary)
                                Text("You can modify or abort during this grace period.")
                                    .font(.caption2)
                                    .foregroundColor(Theme.textMuted)
                            }
                            Spacer()
                        }
                        
                        // Control buttons row
                        HStack(spacing: 12) {
                            Button {
                                timer?.invalidate()
                                dismiss() // Go back to append items
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.caption.bold())
                                    Text("Add Items")
                                        .font(.subheadline.bold())
                                }
                                .foregroundColor(Theme.primary)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Theme.primaryBg)
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            Button {
                                showCancelAlert = true
                            } label: {
                                Text("Cancel Order")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            requestNotificationPermission()
            postLocalNotification(title: "Order Placed Successfully", body: "Your order ID \(orderID) of ₹\(amount) has been received.")
            if shouldStartGracePeriod {
                startGraceCountdown()
            } else {
                secondsRemaining = 0
                isLocked = true
                lockAndLaunchLiveActivity()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .alert("Abort Order?", isPresented: $showCancelAlert) {
            Button("Yes, Cancel", role: .destructive) {
                timer?.invalidate()
                dismiss() // Return to cart
            }
            Button("No, Keep Order", role: .cancel) {}
        } message: {
            Text("Are you sure you want to cancel this order? Your cart items will be preserved.")
        }
    }
    
    private func startGraceCountdown() {
        secondsRemaining = 30
        isLocked = false
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if secondsRemaining > 1 {
                withAnimation(.linear(duration: 0.2)) {
                    secondsRemaining -= 1
                }
            } else {
                timer?.invalidate()
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    secondsRemaining = 0
                    isLocked = true
                }
                postLocalNotification(title: "Order Finalized", body: "30s grace elapsed. Sourcing pipeline locked in.")
                lockAndLaunchLiveActivity()
            }
        }
    }
    
    private func lockAndLaunchLiveActivity() {
        // Live Activity is started by CheckoutManager.lockOrder() — do NOT start a duplicate here.
        // This method is kept as a no-op to avoid double-starting competing activities.
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
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request)
}

// Visual layout support for green gradient
extension Color {
    static let emerald = Color(red: 16/255, green: 185/255, blue: 129/255)
}

struct SourcingMapView: View {
    // CP coords: CP Center (approx 28.6304, 77.2177)
    let warehouse = CLLocationCoordinate2D(latitude: 28.6270, longitude: 77.2150) // Sourcing Hub
    let destination = CLLocationCoordinate2D(latitude: 28.6328, longitude: 77.2195) // Kitchen Outpost
    
    @State private var courierPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 28.6270, longitude: 77.2150)
    @State private var progress: Double = 0.0
    @State private var timer: Timer?
    
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 28.6299, longitude: 77.2172),
            span: MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        )
    )
    
    @State private var notifiedSteps: Set<Int> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "map.fill")
                        .foregroundColor(Theme.primary)
                    Text("LIVE ROUTING MAP")
                        .font(.caption.bold())
                        .foregroundColor(Theme.textMuted)
                }
                Spacer()
                Text("\(Int(progress * 100))% En Route")
                    .font(.caption.bold())
                    .foregroundColor(progress >= 1.0 ? .green : Theme.primary)
            }
            
            // Modern iOS 17 Map component
            Map(position: $position) {
                Marker("Sourcing Warehouse", systemImage: "building.2.fill", coordinate: warehouse)
                    .tint(.blue)
                
                Marker("Kitchen Outpost (NCR-08)", systemImage: "fork.knife", coordinate: destination)
                    .tint(Theme.primary)
                
                Annotation("Courier", coordinate: courierPosition) {
                    ZStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 32, height: 32)
                            .shadow(color: .green.opacity(0.6), radius: 6)
                        
                        Image(systemName: "shippingbox.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 13, weight: .bold))
                    }
                }
            }
            .frame(height: 220)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(progress >= 1.0 ? "Courier has arrived at your restaurant dock." : "Consignment dispatched. Delivery partner tracking active in real-time.")
                    .font(.caption.bold())
                    .foregroundColor(Theme.textPrimary)
                Text("Delhi-NCR Hub Route: cp-outer-ring-rd")
                    .font(.system(size: 9).monospaced())
                    .foregroundColor(Theme.textMuted)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.gray.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal)
        .onAppear {
            startCourierSimulation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startCourierSimulation() {
        progress = 0.0
        courierPosition = warehouse
        notifiedSteps = []
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            if progress < 1.0 {
                withAnimation(.linear(duration: 1.5)) {
                    progress += 0.05
                    if progress > 1.0 { progress = 1.0 }
                    
                    // Linear interpolation
                    let newLat = warehouse.latitude + (destination.latitude - warehouse.latitude) * progress
                    let newLon = warehouse.longitude + (destination.longitude - warehouse.longitude) * progress
                    courierPosition = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
                }
                
                let percent = Int(round(progress * 100))
                if percent >= 20 && percent < 60 && !notifiedSteps.contains(20) {
                    notifiedSteps.insert(20)
                    postLocalNotification(title: "Courier Assigned", body: "Delivery partner is loading consignment at CP warehouse.")
                } else if percent >= 60 && percent < 100 && !notifiedSteps.contains(60) {
                    notifiedSteps.insert(60)
                    postLocalNotification(title: "Consignment Dispatched", body: "Logistics partner has departed warehouse hub.")
                }
            } else {
                timer?.invalidate()
                if !notifiedSteps.contains(100) {
                    notifiedSteps.insert(100)
                    postLocalNotification(title: "Courier Arrived", body: "Consignment successfully delivered to your restaurant dock!")
                }
            }
        }
    }
}
