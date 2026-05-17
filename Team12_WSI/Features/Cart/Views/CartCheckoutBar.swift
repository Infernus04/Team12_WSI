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
                    .background {
                        LinearGradient(
                            colors: [
                                AuraDesign.Colors.charcoal,
                                AuraDesign.Colors.cocoa
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                    .foregroundColor(AuraDesign.Colors.cream)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(22)
        .background(AuraDesign.Colors.porcelain)
        .overlay(
            VStack {
                Rectangle()
                    .fill(AuraDesign.Colors.hairline.opacity(0.50))
                    .frame(height: 1)
                Spacer()
            }
        )
        .shadow(color: AuraDesign.Colors.charcoal.opacity(0.05), radius: 16, x: 0, y: -8)
    }
}
