import SwiftUI

struct CartItemRow: View {
    
    let item: CartItem
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onRemoveAll: () -> Void
    let onToggleGiftWrap: () -> Void
    let onMoveToRegistry: () -> Void
    
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
                    .font(.wsBody(size: 14, weight: .medium))
                    .foregroundColor(.wsCharcoal)
                    .lineLimit(2)
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.wsSerif(size: 14, weight: .semibold))
                    .foregroundColor(.wsCharcoal.opacity(0.8))
                
                if let stock = item.availability, stock == "ON_HAND" {
                    Text("In Stock")
                        .font(.wsBody(size: 11))
                        .foregroundColor(.green)
                }
                
                if let delivery = item.deliveryEstimate {
                    Text(delivery == "TRANSIT" ? "Ships in 2-3 days" : delivery)
                        .font(.wsBody(size: 11))
                        .foregroundColor(.wsSecondary)
                }
                
                if item.canGiftWrap {
                    Button(action: onToggleGiftWrap) {
                        HStack(spacing: 6) {
                            Image(systemName: item.isGiftWrapped ? "checkmark.square.fill" : "square")
                                .foregroundColor(item.isGiftWrapped ? .wsCharcoal : .wsSecondary)
                            Text("Gift Wrap (+$8.00)")
                                .font(.wsBody(size: 11))
                                .foregroundColor(item.isGiftWrapped ? .wsCharcoal : .wsSecondary)
                        }
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: onRemove) {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.wsCharcoal)
                            .frame(width: 24, height: 24)
                            .background(Color.wsWarmIvory)
                            .clipShape(Circle())
                    }
                    
                    Text("\(item.quantity)")
                        .font(.wsBody(size: 14, weight: .semibold))
                        .foregroundColor(.wsCharcoal)
                    
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.wsCharcoal)
                            .frame(width: 24, height: 24)
                            .background(Color.wsWarmIvory)
                            .clipShape(Circle())
                    }
                    
                    Button(action: onRemoveAll) {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.wsCrimson)
                            .frame(width: 24, height: 24)
                            .background(Color.wsWarmIvory)
                            .clipShape(Circle())
                    }
                    
                    Button(action: onMoveToRegistry) {
                        Image(systemName: "gift")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.wsMutedBrass)
                            .frame(width: 24, height: 24)
                            .background(Color.wsWarmIvory)
                            .clipShape(Circle())
                    }
                }
            }
            
            Spacer()
            
            // MARK: - Total Price per item
            let itemTotal = item.price * Double(item.quantity) + (item.isGiftWrapped ? 8.0 * Double(item.quantity) : 0.0)
            Text("$\(itemTotal, specifier: "%.2f")")
                .font(.wsSerif(size: 16, weight: .bold))
                .foregroundColor(.wsCharcoal)
        }
        .padding()
        .background(Color.wsSurface)
        // Refined shadow and border to match the Home card rows
        .cornerRadius(0)
        .overlay(
            Rectangle()
                .stroke(Color.wsDivider, lineWidth: 0.5)
        )
    }
}
