// CheckoutView.swift
// Checkout screen with dynamic card/COD payment support and grace window integration.

import SwiftUI
import ActivityKit

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CartViewModel.self) private var cartViewModel

    enum CheckoutScreenState: Equatable {
        case idle
        case processingPayment
    }

    @State private var selectedPaymentMethod: PaymentType = .cashOnDelivery
    @State private var screenState: CheckoutScreenState = .idle
    @State private var navigateToConfirmation = false
    @State private var shouldStartGraceOnConfirm = true

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left").bold()
                            Text("Cart")
                        }
                        .foregroundColor(Theme.primary)
                    }
                    Spacer()
                    Text("Secure Checkout")
                        .font(.headline).foregroundColor(Theme.textPrimary)
                    Spacer()
                    Text("Back").foregroundColor(.clear)
                }
                .padding()
                .background(Color(uiColor: .systemBackground))

                ScrollView {
                    VStack(spacing: 20) {
                        // Order Summary
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ORDER DETAILS")
                                .font(.caption.bold()).foregroundColor(Theme.textMuted)

                            ForEach(cartViewModel.items) { item in
                                HStack {
                                    Text("\(item.product.name) (x\(item.quantity))")
                                        .font(.subheadline).foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Text("₹\(item.product.price * Double(item.quantity), specifier: "%.0f")")
                                        .font(.subheadline.bold()).foregroundColor(Theme.textPrimary)
                                }
                            }

                            Divider()

                            SummaryRow(title: "Subtotal", value: "₹\(cartViewModel.subtotal)")
                            SummaryRow(title: "GST (5%)", value: "₹\(cartViewModel.tax)")
                            SummaryRow(title: "Delivery", value: cartViewModel.deliveryFee == 0 ? "FREE" : "₹\(cartViewModel.deliveryFee)")

                            Divider()

                            HStack {
                                Text("Grand Total").font(.headline).foregroundColor(Theme.textPrimary)
                                Spacer()
                                Text("₹\(cartViewModel.grandTotal)")
                                    .font(.title3.bold()).foregroundColor(Theme.primary)
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(Theme.radiusMd)
                        .padding(.horizontal)

                        // Delivery address
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DELIVERY COORDINATES")
                                .font(.caption.bold()).foregroundColor(Theme.textMuted)
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.title3).foregroundColor(Theme.primary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Kitchen Outpost Delhi-NCR (NCR-08)")
                                        .font(.subheadline.bold()).foregroundColor(Theme.textPrimary)
                                    Text("Connaught Place Block-B, New Delhi, 110001")
                                        .font(.caption).foregroundColor(Theme.textSecondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(Theme.radiusMd)
                        .padding(.horizontal)

                        // Payment selector
                        VStack(alignment: .leading, spacing: 14) {
                            Text("PAYMENT MODE")
                                .font(.caption.bold()).foregroundColor(Theme.textMuted)

                            Button { selectedPaymentMethod = .cashOnDelivery } label: {
                                paymentRow(
                                    title: "Cash on Delivery (COD)",
                                    subtitle: "Pay in cash at delivery",
                                    icon: "indianrupeesign.circle.fill",
                                    isSelected: selectedPaymentMethod == .cashOnDelivery
                                )
                            }.buttonStyle(.plain)

                            Divider()

                            Button { selectedPaymentMethod = .cardPayment } label: {
                                paymentRow(
                                    title: "Credit / Debit Card",
                                    subtitle: "Instant payment — no grace window",
                                    icon: "creditcard.fill",
                                    isSelected: selectedPaymentMethod == .cardPayment
                                )
                            }.buttonStyle(.plain)

                            // Dynamic payment badge
                            if selectedPaymentMethod == .cardPayment {
                                HStack(spacing: 6) {
                                    Image(systemName: "lock.shield.fill")
                                        .font(.caption).foregroundColor(.green)
                                    Text("Paid via Credit Card — Instant order lock")
                                        .font(.caption.bold()).foregroundColor(.green)
                                }
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.green.opacity(0.08))
                                .cornerRadius(8)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(Theme.radiusMd)
                        .padding(.horizontal)
                        .animation(.spring(response: 0.35), value: selectedPaymentMethod)
                    }
                    .padding(.vertical)
                }

                // CTA
                VStack {
                    Button { processFulfillment() } label: {
                        Text(selectedPaymentMethod == .cardPayment
                             ? "Process Card Payment & Order"
                             : "Place Order (Cash on Delivery)")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.primary)
                            .cornerRadius(Theme.radiusMd)
                    }
                    .padding()
                }
                .background(Color(uiColor: .systemBackground))
            }

            // Card processing overlay
            if screenState == .processingPayment {
                paymentProcessingOverlay()
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToConfirmation) {
            OrderConfirmationView(
                shouldStartGracePeriod: shouldStartGraceOnConfirm
            )
        }
        .onAppear {
            cartViewModel.applyWeatherBuffer()
        }
    }

    // MARK: - Payment Row
    private func paymentRow(title: String, subtitle: String, icon: String, isSelected: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isSelected ? Theme.primary : Theme.textMuted)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.subheadline.bold()).foregroundColor(Theme.textPrimary)
                Text(subtitle).font(.caption).foregroundColor(Theme.textMuted)
            }
            Spacer()
            Circle()
                .stroke(isSelected ? Theme.primary : Color.gray.opacity(0.4), lineWidth: 2)
                .frame(width: 20, height: 20)
                .overlay(Circle().fill(isSelected ? Theme.primary : .clear).frame(width: 10, height: 10))
        }
        .contentShape(Rectangle())
    }

    // MARK: - Card Processing Overlay
    @ViewBuilder
    private func paymentProcessingOverlay() -> some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.4)
                    Text("Processing Card Payment...")
                        .font(.headline).foregroundColor(.white)
                    Text("Connecting securely to payment gateway...")
                        .font(.caption).foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(28)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Fulfillment Logic
    private func processFulfillment() {
        if selectedPaymentMethod == .cardPayment {
            // Show spinner, then place order with 30-second grace window (just like COD)
            screenState = .processingPayment
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                await MainActor.run {
                    screenState = .idle
                    shouldStartGraceOnConfirm = true

                    CheckoutManager.shared.startCheckout(
                        items: cartViewModel.items,
                        subtotal: cartViewModel.subtotal,
                        tax: cartViewModel.tax,
                        deliveryFee: cartViewModel.deliveryFee,
                        grandTotal: cartViewModel.grandTotal,
                        paymentType: .cardPayment
                    )

                    // Clear cart — order placed
                    cartViewModel.clear()
                    navigateToConfirmation = true
                }
            }
        } else {
            // COD — 30-second grace window
            shouldStartGraceOnConfirm = true
            CheckoutManager.shared.startCheckout(
                items: cartViewModel.items,
                subtotal: cartViewModel.subtotal,
                tax: cartViewModel.tax,
                deliveryFee: cartViewModel.deliveryFee,
                grandTotal: cartViewModel.grandTotal,
                paymentType: .cashOnDelivery
            )
            // Clear cart — order placed
            cartViewModel.clear()
            navigateToConfirmation = true
        }
    }
}
