// ProductCardView.swift
// Team12_WSI
// Williams Sonoma luxury product card — matches WS website card style

import SwiftUI

struct ProductCardView: View {
    let product: ProductItem
    let quantity: Int
    let registryQuantity: Int
    let onAdd: () -> Void
    let onRemove: () -> Void
    let onAddToRegistry: () -> Void
    let onRemoveFromRegistry: () -> Void

    // Demo: mark first items as bestsellers based on stable hash
    private var isBestSeller: Bool {
        abs(product.id.hashValue) % 3 == 0
    }

    @State private var heartPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Image Area
            ZStack(alignment: .topLeading) {
                // Product image
                CustomAsyncImage(url: product.imageURL)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(0.85, contentMode: .fit)
                    .clipped()

                // Best Seller badge
                if isBestSeller {
                    WSBadge(text: "Best Seller")
                        .padding(8)
                }

                // Wishlist / Registry heart — top right
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                heartPressed = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                heartPressed = false
                            }
                            if registryQuantity > 0 {
                                onRemoveFromRegistry()
                            } else {
                                onAddToRegistry()
                            }
                        } label: {
                            Image(systemName: registryQuantity > 0 ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(registryQuantity > 0 ? .wsCrimson : .wsPrimary)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.92))
                                .clipShape(Circle())
                                .scaleEffect(heartPressed ? 1.25 : 1.0)
                        }
                        .padding(8)
                    }
                }
            }

            // MARK: - Product Info
            VStack(alignment: .leading, spacing: 6) {

                Text(product.title)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundColor(.wsPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 10)

                // Pricing — WS style: suggested strikethrough + "Our Price" in crimson
                if let price = product.price {
                    let suggestedPrice = price * 1.18
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("Sugg. Price")
                                .font(.wsCaption)
                                .foregroundColor(.wsSecondary)
                            Text("$\(suggestedPrice, specifier: "%.2f")")
                                .font(.wsCaption)
                                .foregroundColor(.wsSecondary)
                                .strikethrough(true, color: .wsSecondary)
                        }
                        HStack(spacing: 4) {
                            Text("Our Price")
                                .font(.wsCaption)
                                .foregroundColor(.wsSecondary)
                            Text("$\(price, specifier: "%.2f")")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.wsCrimson)
                        }
                    }
                }

                // MARK: - Cart Actions
                VStack(spacing: 6) {
                    if quantity > 0 {
                        // Stepper inline
                        HStack(spacing: 0) {
                            Button(action: onRemove) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .medium))
                                    .frame(width: 32, height: 32)
                            }
                            Text("\(quantity)")
                                .font(.system(size: 13, weight: .semibold))
                                .frame(minWidth: 28)
                            Button(action: onAdd) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .medium))
                                    .frame(width: 32, height: 32)
                            }
                        }
                        .foregroundColor(.wsPrimary)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.wsDivider, lineWidth: 1)
                        )
                    } else {
                        Button(action: onAdd) {
                            Text("ADD TO CART")
                                .font(.wsLabel)
                                .tracking(0.8)
                                .foregroundColor(.wsPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 34)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.wsPrimary, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.top, 6)
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 10)
        }
        .background(Color.wsSurface)
        .cornerRadius(2)
        .wsShadow()
    }
}
