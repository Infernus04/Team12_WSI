import SwiftUI

struct CheckoutConfirmationView: View {
    let confirmation: CheckoutConfirmation
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 46))
                .foregroundColor(AuraDesign.Colors.successGreen)
            
            Text("Order Confirmed")
                .font(AuraDesign.Fonts.serif(size: 28, weight: .bold))
                .foregroundColor(AuraDesign.Colors.charcoal)
            
            Text(confirmation.confirmationMessage)
                .font(AuraDesign.Fonts.sansSerif(size: 15))
                .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.75))
                .multilineTextAlignment(.center)
            
            CheckoutSectionCard(title: "Confirmation Details") {
                VStack(spacing: 12) {
                    CheckoutSummaryRow(title: "Order ID", value: confirmation.orderId)
                    CheckoutSummaryRow(title: "Estimated Delivery", value: confirmation.estimatedDelivery)
                    CheckoutSummaryRow(title: "Order Total", value: confirmation.total.currencyText, isEmphasized: true)
                }
            }
            
            Button(action: onDone) {
                Text("Back to Cart")
                    .font(AuraDesign.Fonts.sansSerif(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(AuraDesign.Colors.charcoal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}
