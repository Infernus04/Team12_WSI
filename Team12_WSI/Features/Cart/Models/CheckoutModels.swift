import Foundation

struct CartLineItemRequest: Codable, Hashable {
    let productId: String
    let quantity: Int
}

struct CheckoutShippingAddress: Equatable {
    var firstName: String = ""
    var lastName: String = ""
    var address1: String = ""
    var address2: String = ""
    var city: String = ""
    var state: String = ""
    var postalCode: String = ""
    var country: String = "US"
    
    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !address1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !state.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !postalCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var formattedLines: [String] {
        let nameLine = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        let cityLine = "\(city), \(state) \(postalCode)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        return [nameLine, address1, address2, cityLine, country]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

struct ShippingOption: Codable, Identifiable, Equatable {
    let id: String
    let label: String
    let detail: String
    let amount: Double
    let estimatedDays: String
}

struct CheckoutQuote: Codable, Equatable {
    let subtotal: Double
    let shippingOptions: [ShippingOption]
    let tax: Double
    let total: Double
}

struct PaymentSummary: Equatable {
    var cardholderName: String = ""
    var cardBrand: String = "Visa"
    var lastFourDigits: String = ""
    
    var isValid: Bool {
        !cardholderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        lastFourDigits.count == 4 &&
        lastFourDigits.allSatisfy { $0.isNumber }
    }
    
    var maskedNumber: String {
        "•••• \(lastFourDigits)"
    }
}

struct CheckoutConfirmation: Equatable {
    let orderId: String
    let placedAt: String
    let estimatedDelivery: String
    let confirmationMessage: String
    let total: Double
    let deliveryOption: ShippingOption?
    let paymentSummary: PaymentReceipt?
}

struct PaymentReceipt: Equatable {
    let cardholderName: String
    let cardBrand: String
    let maskedNumber: String
}

extension Double {
    var currencyText: String {
        String(format: "$%.2f", self)
    }
}
