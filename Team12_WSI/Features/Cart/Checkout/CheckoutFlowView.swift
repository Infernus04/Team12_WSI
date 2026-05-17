import SwiftUI

struct CheckoutFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CheckoutViewModel
    
    private let onClose: () -> Void
    
    init(
        cartItems: [CartItem],
        onClose: @escaping () -> Void,
        onOrderPlaced: @escaping (CheckoutConfirmation) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: CheckoutViewModel(
                cartItems: cartItems,
                onOrderPlaced: onOrderPlaced
            )
        )
        self.onClose = onClose
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuraDesign.Colors.ivory
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 18) {
                            stepIndicator
                            
                            if let errorMessage = viewModel.errorMessage {
                                errorBanner(message: errorMessage)
                            }
                            
                            switch viewModel.step {
                            case .shipping:
                                CheckoutShippingStep(address: $viewModel.shippingAddress)
                            case .delivery:
                                CheckoutDeliveryStep(
                                    quote: viewModel.quote,
                                    selectedShippingOptionId: $viewModel.selectedShippingOptionId
                                )
                            case .payment:
                                CheckoutPaymentStep(paymentSummary: $viewModel.paymentSummary)
                            case .review:
                                CheckoutReviewStep(
                                    items: viewModel.cartItems,
                                    shippingAddress: viewModel.shippingAddress,
                                    selectedShippingOption: viewModel.selectedShippingOption,
                                    paymentSummary: viewModel.paymentSummary,
                                    subtotalText: viewModel.subtotalText,
                                    shippingText: viewModel.shippingText,
                                    taxText: viewModel.taxText,
                                    totalText: viewModel.totalText
                                )
                            case .confirmation:
                                if let confirmation = viewModel.confirmation {
                                    CheckoutConfirmationView(
                                        confirmation: confirmation,
                                        onDone: closeFlow
                                    )
                                } else {
                                    EmptyView()
                                }
                            }
                        }
                        .padding(16)
                        .padding(.bottom, viewModel.step == .confirmation ? 20 : 120)
                    }
                    
                    if viewModel.step != .confirmation {
                        bottomBar
                    }
                }
            }
            .navigationTitle(viewModel.step.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: closeFlow) {
                        Image(systemName: "xmark")
                            .foregroundColor(AuraDesign.Colors.charcoal)
                    }
                }
            }
        }
    }
    
    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(CheckoutViewModel.CheckoutStep.allCases.filter { $0 != .confirmation }, id: \.rawValue) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.step.rawValue ? AuraDesign.Colors.charcoal : AuraDesign.Colors.cream)
                    .frame(height: 6)
            }
        }
        .padding(.horizontal, 2)
    }
    
    private var bottomBar: some View {
        VStack(spacing: 14) {
            if viewModel.isLoading {
                ProgressView()
                    .tint(AuraDesign.Colors.charcoal)
            }
            
            HStack(spacing: 12) {
                if viewModel.canGoBack {
                    Button(action: viewModel.goBack) {
                        Text("Back")
                            .font(AuraDesign.Fonts.sansSerif(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AuraDesign.Colors.cream)
                            .foregroundColor(AuraDesign.Colors.charcoal)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    Task {
                        await viewModel.advance()
                    }
                }) {
                    Text(viewModel.step.primaryActionTitle)
                        .font(AuraDesign.Fonts.sansSerif(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AuraDesign.Colors.charcoal)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: -4)
    }
    
    private func errorBanner(message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(AuraDesign.Colors.errorRed)
            Text(message)
                .font(AuraDesign.Fonts.sansSerif(size: 13))
                .foregroundColor(AuraDesign.Colors.charcoal)
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func closeFlow() {
        onClose()
        dismiss()
    }
}

struct CheckoutSectionCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(AuraDesign.Fonts.serif(size: 20, weight: .semibold))
                .foregroundColor(AuraDesign.Colors.charcoal)
            
            content
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(14)
    }
}

struct CheckoutSummaryRow: View {
    let title: String
    let value: String
    let isEmphasized: Bool
    
    init(title: String, value: String, isEmphasized: Bool = false) {
        self.title = title
        self.value = value
        self.isEmphasized = isEmphasized
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(isEmphasized ? AuraDesign.Fonts.sansSerif(size: 14, weight: .semibold) : AuraDesign.Fonts.sansSerif(size: 14))
                .foregroundColor(AuraDesign.Colors.charcoal.opacity(isEmphasized ? 1 : 0.75))
            
            Spacer()
            
            Text(value)
                .font(isEmphasized ? AuraDesign.Fonts.serif(size: 18, weight: .bold) : AuraDesign.Fonts.sansSerif(size: 14, weight: .medium))
                .foregroundColor(AuraDesign.Colors.charcoal)
        }
    }
}
