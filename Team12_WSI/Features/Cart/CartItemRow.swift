import SwiftUI

struct CartItemRow: View {
    
    let item: CartItem
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onRemoveAll: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            let url = item.imageURL
            // MARK: - Image
            CustomAsyncImage(url: url)
                .frame(width: 90, height: 90)
                .cornerRadius(4)
                .clipped()
            
            // MARK: - Info
            VStack(alignment: .leading, spacing: 8) {
                
                Text(item.title)
                    .font(AuraDesign.Fonts.sansSerif(size: 14, weight: .medium))
                    .foregroundColor(AuraDesign.Colors.charcoal)
                    .lineLimit(2)
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(AuraDesign.Fonts.serif(size: 14, weight: .semibold))
                    .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.8))
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: onRemove) {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AuraDesign.Colors.charcoal)
                            .frame(width: 24, height: 24)
                            .background(AuraDesign.Colors.cream)
                            .clipShape(Circle())
                    }
                    
                    Text("\(item.quantity)")
                        .font(AuraDesign.Fonts.sansSerif(size: 14, weight: .semibold))
                        .foregroundColor(AuraDesign.Colors.charcoal)
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AuraDesign.Colors.charcoal)
                            .frame(width: 24, height: 24)
                            .background(AuraDesign.Colors.cream)
                            .clipShape(Circle())
                    }
                    
                    Button(action: onRemoveAll) {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AuraDesign.Colors.errorRed)
                            .frame(width: 24, height: 24)
                            .background(AuraDesign.Colors.cream)
                            .clipShape(Circle())
                    }
                }
            }
            
            Spacer()
            
            // MARK: - Total Price per item
            Text("$\(item.price * Double(item.quantity), specifier: "%.2f")")
                .font(AuraDesign.Fonts.serif(size: 16, weight: .bold))
                .foregroundColor(AuraDesign.Colors.charcoal)
        }
        .padding()
        .background(Color.white)
        // Refined shadow and border
        .cornerRadius(0)
        .overlay(
            Rectangle()
                .stroke(AuraDesign.Colors.cream, lineWidth: 1)
        )
    }
}
