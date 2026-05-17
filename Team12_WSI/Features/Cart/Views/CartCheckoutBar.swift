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
                        .font(.wsSerif(size: 18, weight: .semibold))
                        .foregroundColor(.wsCharcoal)
                    
                    Text(itemCountText)
                        .font(.wsBody(size: 13))
                        .foregroundColor(.wsCharcoal.opacity(0.65))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(AppStrings.Cart.total)
                        .font(.wsBody(size: 12, weight: .medium))
                        .foregroundColor(.wsCharcoal.opacity(0.65))
                    Text(totalText)
                        .font(.wsSerif(size: 24, weight: .bold))
                        .foregroundColor(.wsCharcoal)
                }
            }
            
            Button(action: onCheckout) {
                Text("Continue to Checkout")
            }
            .buttonStyle(WSPrimaryButtonStyle())
        }
        .padding(22)
        .background(Color.wsWarmIvory)
        .overlay(
            VStack {
                Rectangle()
                    .fill(Color.wsDivider)
                    .frame(height: 1)
                Spacer()
            }
        )
        .wsLuxuryShadow()
    }
}
