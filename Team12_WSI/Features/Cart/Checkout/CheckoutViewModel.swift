import Foundation
import Combine

@MainActor
final class CheckoutViewModel: ObservableObject {
    enum CheckoutStep: Int, CaseIterable {
        case shipping
        case delivery
        case payment
        case review
        case confirmation
        
        var title: String {
            switch self {
            case .shipping:
                return "Shipping"
            case .delivery:
                return "Delivery"
            case .payment:
                return "Payment"
            case .review:
                return "Review"
            case .confirmation:
                return "Confirmed"
            }
        }
        
        var primaryActionTitle: String {
            switch self {
            case .shipping:
                return "Continue to Delivery"
            case .delivery:
                return "Continue to Payment"
            case .payment:
                return "Review Order"
            case .review:
                return "Place Order"
            case .confirmation:
                return "Done"
            }
        }
    }
    
    @Published var step: CheckoutStep = .shipping
    @Published var shippingAddress = CheckoutShippingAddress()
    @Published var selectedShippingOptionId: String?
    @Published var paymentSummary = PaymentSummary()
    @Published private(set) var quote: CheckoutQuote?
    @Published private(set) var confirmation: CheckoutConfirmation?
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let cartItems: [CartItem]
    
    private let checkoutService = CheckoutService()
    private let onOrderPlaced: (CheckoutConfirmation) -> Void
    
    init(
        cartItems: [CartItem],
        onOrderPlaced: @escaping (CheckoutConfirmation) -> Void
    ) {
        self.cartItems = cartItems
        self.onOrderPlaced = onOrderPlaced
    }
    
    var selectedShippingOption: ShippingOption? {
        quote?.shippingOptions.first(where: { $0.id == selectedShippingOptionId }) ?? quote?.shippingOptions.first
    }
    
    var canGoBack: Bool {
        step != .shipping && step != .confirmation
    }
    
    var subtotalText: String {
        (quote?.subtotal ?? cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }).currencyText
    }
    
    var shippingText: String {
        (selectedShippingOption?.amount ?? quote?.shippingOptions.first?.amount ?? 0).currencyText
    }
    
    var taxText: String {
        (quote?.tax ?? 0).currencyText
    }
    
    var totalText: String {
        let subtotal = quote?.subtotal ?? cartItems.reduce(0) { $0 + ($1.price * Double($1.quantity)) }
        let shipping = selectedShippingOption?.amount ?? quote?.shippingOptions.first?.amount ?? 0
        let tax = quote?.tax ?? 0
        return (subtotal + shipping + tax).currencyText
    }
    
    func advance() async {
        errorMessage = nil
        
        switch step {
        case .shipping:
            guard shippingAddress.isValid else {
                errorMessage = "Please complete the shipping details before continuing."
                return
            }
            await refreshQuote()
            if quote != nil {
                if selectedShippingOptionId == nil {
                    selectedShippingOptionId = quote?.shippingOptions.first?.id
                }
                step = .delivery
            }
        case .delivery:
            guard selectedShippingOption != nil else {
                errorMessage = "Choose a delivery option to continue."
                return
            }
            step = .payment
        case .payment:
            guard paymentSummary.isValid else {
                errorMessage = "Enter a cardholder name and four ending digits to continue."
                return
            }
            await refreshQuote()
            if quote != nil {
                step = .review
            }
        case .review:
            guard let deliveryOptionId = selectedShippingOption?.id else {
                errorMessage = "A delivery option is required before placing the order."
                return
            }
            await submitOrder(deliveryOptionId: deliveryOptionId)
        case .confirmation:
            break
        }
    }
    
    func goBack() {
        switch step {
        case .shipping:
            return
        case .delivery:
            step = .shipping
        case .payment:
            step = .delivery
        case .review:
            step = .payment
        case .confirmation:
            return
        }
    }
    
    private func refreshQuote() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            quote = try await checkoutService.quote(items: cartItems, shippingAddress: shippingAddress)
            if selectedShippingOptionId == nil {
                selectedShippingOptionId = quote?.shippingOptions.first?.id
            }
        } catch {
            errorMessage = "We couldn't refresh your checkout quote. Please try again."
        }
    }
    
    private func submitOrder(deliveryOptionId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let confirmation = try await checkoutService.submit(
                items: cartItems,
                shippingAddress: shippingAddress,
                deliveryOptionId: deliveryOptionId,
                paymentSummary: paymentSummary
            )
            self.confirmation = confirmation
            step = .confirmation
            onOrderPlaced(confirmation)
        } catch {
            errorMessage = "Your order could not be placed right now. Please try again."
        }
    }
}
