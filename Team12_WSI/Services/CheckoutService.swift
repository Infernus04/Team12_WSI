import Foundation

final class CheckoutService {
    func quote(items: [CartItem], shippingAddress: CheckoutShippingAddress) async throws -> CheckoutQuote {
        let requestBody = CheckoutQuoteRequest(
            items: items.map { CartLineItemRequest(productId: $0.id, quantity: $0.quantity) },
            shippingAddress: ShippingAddressPayload(from: shippingAddress)
        )
        
        return try await APIClient.shared.request(.checkoutQuote(), body: requestBody)
    }
    
    func submit(
        items: [CartItem],
        shippingAddress: CheckoutShippingAddress,
        deliveryOptionId: String,
        paymentSummary: PaymentSummary
    ) async throws -> CheckoutConfirmation {
        let requestBody = CheckoutSubmitRequest(
            items: items.map { CartLineItemRequest(productId: $0.id, quantity: $0.quantity) },
            shippingAddress: ShippingAddressPayload(from: shippingAddress),
            deliveryOptionId: deliveryOptionId,
            paymentSummary: PaymentSummaryPayload(from: paymentSummary)
        )
        
        let response: CheckoutConfirmationDTO = try await APIClient.shared.request(.checkoutSubmit(), body: requestBody)
        return response.toDomain()
    }
}

private struct CheckoutQuoteRequest: Codable {
    let items: [CartLineItemRequest]
    let shippingAddress: ShippingAddressPayload
}

private struct CheckoutSubmitRequest: Codable {
    let items: [CartLineItemRequest]
    let shippingAddress: ShippingAddressPayload
    let deliveryOptionId: String
    let paymentSummary: PaymentSummaryPayload
}

private struct ShippingAddressPayload: Codable {
    let firstName: String
    let lastName: String
    let address1: String
    let address2: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    
    init(from address: CheckoutShippingAddress) {
        self.firstName = address.firstName
        self.lastName = address.lastName
        self.address1 = address.address1
        self.address2 = address.address2
        self.city = address.city
        self.state = address.state
        self.postalCode = address.postalCode
        self.country = address.country
    }
}

private struct PaymentSummaryPayload: Codable {
    let cardholderName: String
    let cardBrand: String
    let maskedNumber: String
    
    init(from paymentSummary: PaymentSummary) {
        self.cardholderName = paymentSummary.cardholderName
        self.cardBrand = paymentSummary.cardBrand
        self.maskedNumber = paymentSummary.maskedNumber
    }
}

private struct CheckoutConfirmationDTO: Decodable {
    let orderId: String
    let placedAt: String
    let estimatedDelivery: String
    let confirmationMessage: String
    let total: Double
    let deliveryOption: ShippingOption?
    let paymentSummary: PaymentReceiptDTO?
    
    func toDomain() -> CheckoutConfirmation {
        CheckoutConfirmation(
            orderId: orderId,
            placedAt: placedAt,
            estimatedDelivery: estimatedDelivery,
            confirmationMessage: confirmationMessage,
            total: total,
            deliveryOption: deliveryOption,
            paymentSummary: paymentSummary?.toDomain()
        )
    }
}

private struct PaymentReceiptDTO: Decodable {
    let cardholderName: String
    let cardBrand: String
    let maskedNumber: String
    
    func toDomain() -> PaymentReceipt {
        PaymentReceipt(
            cardholderName: cardholderName,
            cardBrand: cardBrand,
            maskedNumber: maskedNumber
        )
    }
}
