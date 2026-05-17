import SwiftUI

struct CheckoutReviewStep: View {
    let items: [CartItem]
    let shippingAddress: CheckoutShippingAddress
    let selectedShippingOption: ShippingOption?
    let paymentSummary: PaymentSummary
    let subtotalText: String
    let shippingText: String
    let taxText: String
    let totalText: String
    
    var body: some View {
        VStack(spacing: 16) {
            CheckoutSectionCard(title: "Order Review") {
                VStack(spacing: 12) {
                    ForEach(items) { item in
                        HStack(spacing: 12) {
                            CustomAsyncImage(url: item.imageURL)
                                .frame(width: 54, height: 54)
                                .cornerRadius(8)
                                .clipped()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(AuraDesign.Fonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundColor(AuraDesign.Colors.charcoal)
                                    .lineLimit(2)
                                Text("Qty \(item.quantity)")
                                    .font(AuraDesign.Fonts.sansSerif(size: 12))
                                    .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.65))
                            }
                            
                            Spacer()
                            
                            Text((item.price * Double(item.quantity)).currencyText)
                                .font(AuraDesign.Fonts.serif(size: 14, weight: .bold))
                                .foregroundColor(AuraDesign.Colors.charcoal)
                        }
                    }
                }
            }
            
            CheckoutSectionCard(title: "Shipping") {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(shippingAddress.formattedLines, id: \.self) { line in
                        Text(line)
                            .font(AuraDesign.Fonts.sansSerif(size: 13))
                            .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.75))
                    }
                }
            }
            
            CheckoutSectionCard(title: "Delivery & Payment") {
                VStack(alignment: .leading, spacing: 12) {
                    if let selectedShippingOption {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedShippingOption.label)
                                .font(AuraDesign.Fonts.sansSerif(size: 14, weight: .semibold))
                            Text(selectedShippingOption.estimatedDays)
                                .font(AuraDesign.Fonts.sansSerif(size: 12))
                                .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.65))
                        }
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(paymentSummary.cardBrand)
                            .font(AuraDesign.Fonts.sansSerif(size: 14, weight: .semibold))
                        Text(paymentSummary.maskedNumber)
                            .font(AuraDesign.Fonts.sansSerif(size: 12))
                            .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.65))
                        Text(paymentSummary.cardholderName)
                            .font(AuraDesign.Fonts.sansSerif(size: 12))
                            .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.65))
                    }
                }
            }
            
            CheckoutSectionCard(title: "Summary") {
                VStack(spacing: 12) {
                    CheckoutSummaryRow(title: "Subtotal", value: subtotalText)
                    CheckoutSummaryRow(title: "Shipping", value: shippingText)
                    CheckoutSummaryRow(title: "Tax", value: taxText)
                    Divider()
                    CheckoutSummaryRow(title: "Total", value: totalText, isEmphasized: true)
                }
            }
        }
    }
}
