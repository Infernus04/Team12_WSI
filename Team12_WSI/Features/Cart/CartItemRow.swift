import SwiftUI

struct CartItemRow: View {
    
    let item: CartItem
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onRemoveAll: () -> Void
    let onToggleGiftWrap: () -> Void
    let onMoveToRegistry: () -> Void // renamed: now saves to wishlist
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                // MARK: - Image
                CustomAsyncImage(url: item.imageURL)
                    .frame(width: 90, height: 90)
                    .cornerRadius(4)
                    .clipped()
                
                // MARK: - Info + Price
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        Text(item.title)
                            .font(.wsBody(size: 14, weight: .medium))
                            .foregroundColor(.wsCharcoal)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        // Total Price per item
                        let itemTotal = item.price * Double(item.quantity) + (item.isGiftWrapped ? 8.0 * Double(item.quantity) : 0.0)
                        Text("$\(itemTotal, specifier: "%.2f")")
                            .font(.wsSerif(size: 16, weight: .bold))
                            .foregroundColor(.wsCharcoal)
                    }
                    
                    Text("$\(item.price, specifier: "%.2f")")
                        .font(.wsSerif(size: 13, weight: .semibold))
                        .foregroundColor(.wsCharcoal.opacity(0.7))
                    
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
                        .padding(.top, 2)
                    }
                }
            }
            
            // MARK: - Quantity Controls (full-width row below)
            HStack(spacing: 0) {
                Spacer()
                
                HStack(spacing: 20) {
                    // Minus
                    Button(action: onRemove) {
                        Image(systemName: "minus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.wsCharcoal)
                            .frame(width: 28, height: 28)
                            .background(Color.wsWarmIvory)
                            .clipShape(Circle())
                    }
                    
                    // Quantity label
                    Text("\(item.quantity)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.wsCharcoal)
                        .frame(minWidth: 24, alignment: .center)
                    
                    // Plus
                    Button(action: onAdd) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.wsCharcoal)
                            .frame(width: 28, height: 28)
                            .background(Color.wsWarmIvory)
                            .clipShape(Circle())
                    }
                    
                    // Divider
                    Rectangle()
                        .fill(Color.wsDivider)
                        .frame(width: 1, height: 20)
                    
                    // Delete
                    Button(action: onRemoveAll) {
                        Image(systemName: "trash")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.wsCrimson)
                            .frame(width: 28, height: 28)
                            .background(Color.wsWarmIvory)
                            .clipShape(Circle())
                    }
                    
                    // Save for later (heart)
                    Button(action: onMoveToRegistry) {
                        Image(systemName: "heart")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.wsCrimson)
                            .frame(width: 28, height: 28)
                            .background(Color.wsWarmIvory)
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
            }
            .padding(.top, 12)
        }
        .padding(16)
        .background(Color.wsSurface)
        .overlay(
            Rectangle()
                .stroke(Color.wsDivider, lineWidth: 0.5)
        )
    }
}
