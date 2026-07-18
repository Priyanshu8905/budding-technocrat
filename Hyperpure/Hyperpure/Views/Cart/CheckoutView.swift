// CheckoutView.swift
// Interactive Checkout management screen supporting simulated Card Payments and Cash on Delivery with grace windows.

import SwiftUI
import ActivityKit

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CartViewModel.self) private var cartViewModel
    
    enum PaymentMethod {
        case card
        case cod
    }
    
    enum CheckoutScreenState: Equatable {
        case idle
        case processingPayment
        case gracePeriodActive(secondsRemaining: Int)
        case orderPlacedAndLocked
    }
    
    @State private var selectedPaymentMethod: PaymentMethod = .cod
    @State private var screenState: CheckoutScreenState = .idle
    @State private var orderID: String = ""
    @State private var navigateToConfirmation = false
    @State private var shouldStartGraceOnConfirm = true
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .bold()
                            Text("Cart")
                        }
                        .foregroundColor(Theme.primary)
                    }
                    Spacer()
                    Text("Secure Checkout")
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    // Spacer to balance back button
                    Text("Back")
                        .foregroundColor(.clear)
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Order details Summary Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ORDER DETAILS")
                                .font(.caption.bold())
                                .foregroundColor(Theme.textMuted)
                            
                            ForEach(cartViewModel.items) { item in
                                HStack {
                                    Text("\(item.product.name) (x\(item.quantity))")
                                        .font(.subheadline)
                                        .foregroundColor(Theme.textPrimary)
                                    Spacer()
                                    Text("₹\(item.product.price * Double(item.quantity), specifier: "%.2f")")
                                        .font(.subheadline.bold())
                                        .foregroundColor(Theme.textPrimary)
                                }
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Grand Total")
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)
                                Spacer()
                                Text("₹\(cartViewModel.grandTotal)")
                                    .font(.title3.bold())
                                    .foregroundColor(Theme.primary)
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(Theme.radiusMd)
                        .padding(.horizontal)
                        
                        // Delivery Outpost Address Card
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DELIVERY COORDINATES")
                                .font(.caption.bold())
                                .foregroundColor(Theme.textMuted)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.title3)
                                    .foregroundColor(Theme.primary)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Kitchen Outpost Delhi-NCR (NCR-08)")
                                        .font(.subheadline.bold())
                                        .foregroundColor(Theme.textPrimary)
                                    Text("Connaught Place Block-B, New Delhi, 110001")
                                        .font(.caption)
                                        .foregroundColor(Theme.textSecondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(Theme.radiusMd)
                        .padding(.horizontal)
                        
                        // Payment Method Selection Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("PAYMENT MODE")
                                .font(.caption.bold())
                                .foregroundColor(Theme.textMuted)
                            
                            Button {
                                selectedPaymentMethod = .cod
                            } label: {
                                paymentRow(
                                    title: "Cash on Delivery (COD)",
                                    icon: "indianrupeesign.circle.fill",
                                    isSelected: selectedPaymentMethod == .cod
                                )
                            }
                            .buttonStyle(.plain)
                            
                            Divider()
                            
                            Button {
                                selectedPaymentMethod = .card
                            } label: {
                                paymentRow(
                                    title: "Credit/Debit Card (Simulated)",
                                    icon: "creditcard.fill",
                                    isSelected: selectedPaymentMethod == .card
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding()
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(Theme.radiusMd)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                // Confirm Bottom Action
                VStack {
                    Button {
                        processFulfillment()
                    } label: {
                        Text(selectedPaymentMethod == .card ? "Process Payment & Order" : "Place Order (COD)")
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
            
            // Full Screen Overlay for Payment / Grace Period states
            if screenState == .processingPayment {
                overlayStateView()
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToConfirmation) {
            OrderConfirmationView(
                orderID: orderID,
                amount: cartViewModel.grandTotal,
                shouldStartGracePeriod: shouldStartGraceOnConfirm
            )
        }
        .onAppear {
            orderID = "#HP-" + String(Int.random(in: 1000...9999))
        }
    }
    
    private func paymentRow(title: String, icon: String, isSelected: Bool) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isSelected ? Theme.primary : Theme.textMuted)
            
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(Theme.textPrimary)
            
            Spacer()
            
            Circle()
                .stroke(isSelected ? Theme.primary : Color.gray.opacity(0.4), lineWidth: 2)
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .fill(isSelected ? Theme.primary : Color.clear)
                        .frame(width: 10, height: 10)
                )
        }
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func overlayStateView() -> some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Processing Payment...")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Connecting securely to server gateway...")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .padding(.horizontal, 24)
        }
    }
    
    private func processFulfillment() {
        if selectedPaymentMethod == .card {
            screenState = .processingPayment
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                screenState = .idle
                shouldStartGraceOnConfirm = false
                navigateToConfirmation = true
            }
        } else {
            shouldStartGraceOnConfirm = true
            navigateToConfirmation = true
        }
    }
}
