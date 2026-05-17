import SwiftUI

struct CartCheckoutBar: View {
    let totalText: String
    let itemCountText: String
    let onCheckout: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ready for checkout")
                        .font(AuraDesign.Fonts.serif(size: 18, weight: .semibold))
                        .foregroundColor(AuraDesign.Colors.charcoal)
                    
                    Text(itemCountText)
                        .font(AuraDesign.Fonts.sansSerif(size: 13))
                        .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.65))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(AppStrings.Cart.total)
                        .font(AuraDesign.Fonts.sansSerif(size: 12, weight: .medium))
                        .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.65))
                    Text(totalText)
                        .font(AuraDesign.Fonts.serif(size: 24, weight: .bold))
                        .foregroundColor(AuraDesign.Colors.charcoal)
                }
            }
            
            Button(action: onCheckout) {
                Text("Continue to Checkout")
                    .font(AuraDesign.Fonts.sansSerif(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(AuraDesign.Colors.charcoal)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(22)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: -4)
    }
}
