import SwiftUI

// MARK: - Quick Checkout View (Simplified Single-Page Payment)

struct QuickCheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    
    let cartItems: [CartItem]
    let totalPrice: Double
    let onClose: () -> Void
    let onOrderPlaced: () -> Void
    
    @State private var selectedPayment: PaymentMethod?
    @State private var isProcessing = false
    @State private var showConfirmation = false
    @State private var generatedOrderId = ""
    
    enum PaymentMethod: String, CaseIterable, Identifiable {
        case applePay = "Apple Pay"
        case creditCard = "Credit / Debit Card"
        case paypal = "PayPal"
        case klarna = "Klarna — Pay in 4"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .applePay: return "apple.logo"
            case .creditCard: return "creditcard.fill"
            case .paypal: return "p.circle.fill"
            case .klarna: return "clock.arrow.2.circlepath"
            }
        }
        
        var subtitle: String {
            switch self {
            case .applePay: return "Pay instantly with Face ID"
            case .creditCard: return "Visa, Mastercard, Amex"
            case .paypal: return "Pay with your PayPal account"
            case .klarna: return "4 interest-free payments"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.wsWarmIvory.ignoresSafeArea()
                
                if showConfirmation {
                    confirmationView
                } else {
                    VStack(spacing: 0) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 24) {
                                orderSummaryCard
                                paymentMethodsSection
                            }
                            .padding(20)
                            .padding(.bottom, 120)
                        }
                        
                        payButton
                    }
                }
            }
            .navigationTitle(showConfirmation ? "Order Confirmed" : "Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !showConfirmation {
                        Button(action: closeFlow) {
                            Image(systemName: "xmark")
                                .foregroundColor(.wsCharcoal)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Order Summary
    
    private var orderSummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Summary")
                .font(.wsSerif(size: 20, weight: .semibold))
                .foregroundColor(.wsCharcoal)
            
            VStack(spacing: 12) {
                ForEach(cartItems) { item in
                    HStack(spacing: 12) {
                        CustomAsyncImage(url: item.imageURL)
                            .frame(width: 50, height: 50)
                            .cornerRadius(4)
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.wsBody(size: 13, weight: .medium))
                                .foregroundColor(.wsCharcoal)
                                .lineLimit(1)
                            Text("Qty: \(item.quantity)")
                                .font(.wsBody(size: 11))
                                .foregroundColor(.wsSecondary)
                        }
                        
                        Spacer()
                        
                        Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                            .font(.wsSerif(size: 14, weight: .semibold))
                            .foregroundColor(.wsCharcoal)
                    }
                }
            }
            
            Rectangle()
                .fill(Color.wsDivider)
                .frame(height: 1)
            
            HStack {
                Text("Total")
                    .font(.wsSerif(size: 18, weight: .bold))
                    .foregroundColor(.wsCharcoal)
                Spacer()
                Text(totalPrice.currencyText)
                    .font(.wsSerif(size: 22, weight: .bold))
                    .foregroundColor(.wsCharcoal)
            }
        }
        .padding(20)
        .background(Color.wsSurface)
        .cornerRadius(12)
        .wsLuxuryShadow()
    }
    
    // MARK: - Payment Methods
    
    private var paymentMethodsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.wsSerif(size: 20, weight: .semibold))
                .foregroundColor(.wsCharcoal)
            
            VStack(spacing: 10) {
                ForEach(PaymentMethod.allCases) { method in
                    paymentMethodRow(method)
                }
            }
        }
    }
    
    private func paymentMethodRow(_ method: PaymentMethod) -> some View {
        let isSelected = selectedPayment == method
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPayment = method
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: method.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(isSelected ? .wsCharcoal : .wsSecondary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.rawValue)
                        .font(.wsBody(size: 15, weight: .semibold))
                        .foregroundColor(.wsCharcoal)
                    Text(method.subtitle)
                        .font(.wsBody(size: 12))
                        .foregroundColor(.wsSecondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .wsCharcoal : .wsDivider)
            }
            .padding(16)
            .background(Color.wsSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.wsCharcoal : Color.wsDivider, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Pay Button
    
    private var payButton: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.wsDivider)
                .frame(height: 1)
            
            VStack(spacing: 14) {
                if isProcessing {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(.wsCharcoal)
                        Text("Processing payment...")
                            .font(.wsBody(size: 14))
                            .foregroundColor(.wsSecondary)
                    }
                }
                
                Button(action: processPayment) {
                    Text(selectedPayment == .applePay ? "Pay with Apple Pay" : "Place Order — \(totalPrice.currencyText)")
                        .font(.wsBody(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedPayment != nil ? Color.wsCharcoal : Color.wsSecondary.opacity(0.4))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(selectedPayment == nil || isProcessing)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(Color.wsWarmIvory)
        }
    }
    
    // MARK: - Confirmation View
    
    private var confirmationView: some View {
        VStack(spacing: 28) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            VStack(spacing: 10) {
                Text("Order Placed!")
                    .font(.wsDisplay(size: 28))
                    .foregroundColor(.wsCharcoal)
                
                Text("Thank you for your purchase")
                    .font(.wsSerif(size: 16))
                    .foregroundColor(.wsSecondary)
            }
            
            VStack(spacing: 16) {
                confirmationRow(label: "Order ID", value: generatedOrderId)
                confirmationRow(label: "Payment", value: selectedPayment?.rawValue ?? "")
                confirmationRow(label: "Total", value: totalPrice.currencyText)
                confirmationRow(label: "Est. Delivery", value: estimatedDeliveryText)
            }
            .padding(20)
            .background(Color.wsSurface)
            .cornerRadius(12)
            .wsLuxuryShadow()
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button(action: {
                onOrderPlaced()
                closeFlow()
            }) {
                Text("Done")
                    .font(.wsBody(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.wsCharcoal)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    private func confirmationRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.wsBody(size: 14))
                .foregroundColor(.wsSecondary)
            Spacer()
            Text(value)
                .font(.wsBody(size: 14, weight: .semibold))
                .foregroundColor(.wsCharcoal)
        }
    }
    
    private var estimatedDeliveryText: String {
        let calendar = Calendar.current
        let deliveryDate = calendar.date(byAdding: .day, value: Int.random(in: 3...7), to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: deliveryDate)
    }
    
    // MARK: - Actions
    
    private func processPayment() {
        guard selectedPayment != nil else { return }
        isProcessing = true
        generatedOrderId = "WS-\(Int.random(in: 100000...999999))"
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            withAnimation(.spring()) {
                showConfirmation = true
            }
        }
    }
    
    private func closeFlow() {
        onClose()
        dismiss()
    }
}
