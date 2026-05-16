import SwiftUI

struct ProductCardView: View {
    let product: ProductItem
    let quantity: Int
    let registryQuantity: Int
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onAddToRegistry: () -> Void
    let onRemoveFromRegistry: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CustomAsyncImage(url: product.imageURL)
                .frame(height: 150)
                .clipped()
                .cornerRadius(8)
            
            Text(product.title)
                .font(.subheadline)
                .bold()
                .lineLimit(2)
                .frame(height: 40, alignment: .topLeading)
            
            if let price = product.price {
                Text("$\(String(format: "%.2f", price))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 8) {
                // Cart Actions
                HStack {
                    if quantity > 0 {
                        Button(action: onRemove) {
                            Image(systemName: "minus.circle.fill")
                        }
                        Text("\(quantity)")
                        Button(action: onAdd) {
                            Image(systemName: "plus.circle.fill")
                        }
                    } else {
                        Button(action: onAdd) {
                            Label("Add to Cart", systemImage: "cart.badge.plus")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Registry Actions
                HStack {
                    if registryQuantity > 0 {
                        Button(action: onRemoveFromRegistry) {
                            Image(systemName: "heart.slash.fill")
                                .foregroundColor(.red)
                        }
                        Text("\(registryQuantity)")
                        Button(action: onAddToRegistry) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                    } else {
                        Button(action: onAddToRegistry) {
                            Label("Registry", systemImage: "heart")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}