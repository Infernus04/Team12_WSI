import SwiftUI

struct CheckoutDeliveryStep: View {
    let quote: CheckoutQuote?
    @Binding var selectedShippingOptionId: String?
    
    var body: some View {
        CheckoutSectionCard(title: "Delivery Options") {
            if let quote {
                VStack(spacing: 12) {
                    ForEach(quote.shippingOptions) { option in
                        Button(action: {
                            selectedShippingOptionId = option.id
                        }) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: selectedShippingOptionId == option.id ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(AuraDesign.Colors.charcoal)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(option.label)
                                            .font(AuraDesign.Fonts.sansSerif(size: 14, weight: .semibold))
                                        Spacer()
                                        Text(option.amount.currencyText)
                                            .font(AuraDesign.Fonts.serif(size: 16, weight: .bold))
                                    }
                                    
                                    Text(option.detail)
                                        .font(AuraDesign.Fonts.sansSerif(size: 13))
                                        .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.7))
                                    
                                    Text(option.estimatedDays)
                                        .font(AuraDesign.Fonts.sansSerif(size: 12, weight: .medium))
                                        .foregroundColor(AuraDesign.Colors.mutedGold)
                                }
                            }
                            .padding(14)
                            .background(selectedShippingOptionId == option.id ? AuraDesign.Colors.cream : AuraDesign.Colors.ivory)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedShippingOptionId == option.id ? AuraDesign.Colors.charcoal.opacity(0.15) : AuraDesign.Colors.cream, lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    CheckoutSummaryRow(title: "Subtotal", value: quote.subtotal.currencyText)
                    CheckoutSummaryRow(title: "Estimated Tax", value: quote.tax.currencyText)
                }
            } else {
                Text("Add your shipping details first to load delivery options.")
                    .font(AuraDesign.Fonts.sansSerif(size: 13))
                    .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.7))
            }
        }
    }
}
