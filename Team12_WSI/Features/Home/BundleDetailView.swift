// BundleDetailView.swift
// Team12_WSI — Shows all products in an aesthetic bundle as full cards

import SwiftUI

struct BundleDetailView: View {
    let bundle: AestheticBundle
    let products: [ProductItem]
    let onSelectProduct: (ProductItem) -> Void
    let onAddToCart: (ProductItem) -> Void
    let onAddToRegistry: (ProductItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var addedProductIDs: Set<String> = []

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            Color.wsWarmIvory.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    bundleHero
                    bundleInfo
                    WSDivider().padding(.horizontal, 24).padding(.vertical, 8)
                    productsGrid
                    Spacer().frame(height: 50)
                }
            }
            topBar
        }
        .navigationBarHidden(true)
    }

    // MARK: Hero

    private var bundleHero: some View {
        ZStack(alignment: .bottomLeading) {
            // 4-image mosaic
            HStack(spacing: 2) {
                VStack(spacing: 2) {
                    ForEach(products.prefix(2)) { p in
                        CustomAsyncImage(url: p.imageURL)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                    }
                    if products.count < 2 {
                        Rectangle().fill(Color.wsChampagne).frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                VStack(spacing: 2) {
                    ForEach(products.dropFirst(2).prefix(2)) { p in
                        CustomAsyncImage(url: p.imageURL)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                    }
                    if products.count < 4 {
                        ForEach(0..<max(0, 4 - products.count), id: \.self) { _ in
                            Rectangle().fill(Color.wsChampagne).frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
            }
            .frame(height: 340)
            .cornerRadius(0)

            // Gradient overlay
            LinearGradient(
                colors: [.clear, Color.wsCharcoal.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 340)

            // Match badge
            VStack(alignment: .leading, spacing: 6) {
                Text("\(bundle.compatibilityScore)% MATCH")
                    .font(.wsLabel(size: 10))
                    .tracking(1.5)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.wsMutedBrass)
            }
            .padding(20)
        }
    }

    // MARK: Bundle Info

    private var bundleInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("THE COLLECTION")
                .font(.wsLabel(size: 9))
                .tracking(2)
                .foregroundColor(.wsMutedBrass)

            Text(bundle.title)
                .font(.wsDisplay(size: 26))
                .foregroundColor(.wsCharcoal)
                .lineSpacing(3)

            Text(bundle.aiReason)
                .font(.wsSerif(size: 14))
                .foregroundColor(.wsSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            // Add all button
            Button(action: {
                products.forEach { onAddToCart($0) }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "bag")
                        .font(.system(size: 13))
                    Text("ADD ENTIRE COLLECTION")
                        .font(.wsLabel(size: 12))
                        .tracking(1.5)
                }
            }
            .buttonStyle(WSPrimaryButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }

    // MARK: Products Grid

    private var productsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(products.count) PIECES IN THIS COLLECTION")
                .font(.wsLabel(size: 9))
                .tracking(1.5)
                .foregroundColor(.wsSecondary)
                .padding(.horizontal, 24)

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(products) { product in
                    bundleProductCard(product)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func bundleProductCard(_ product: ProductItem) -> some View {
        BundleProductCardView(
            product: product,
            onSelect: { onSelectProduct(product) },
            onAddToCart: {
                onAddToCart(product)
            },
            onAddToRegistry: { onAddToRegistry(product) }
        )
    }

    // MARK: Top Bar

    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.wsCharcoal)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Circle())
                    .wsShadow()
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

// MARK: - Bundle Product Card (standalone to avoid @ViewBuilder inference issues)

private struct BundleProductCardView: View {
    let product: ProductItem
    let onSelect: () -> Void
    let onAddToCart: () -> Void
    let onAddToRegistry: () -> Void

    @State private var isAdded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image — taps open ProductDetailView
            Button(action: onSelect) {
                CustomAsyncImage(url: product.imageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 170)
                    .clipped()
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                // Product type label
                if let type = product.productType {
                    Text(type.uppercased())
                        .font(.wsLabel(size: 8))
                        .tracking(1.5)
                        .foregroundColor(.wsMutedBrass)
                }

                // Name
                Text(product.name)
                    .font(.wsBody(size: 13))
                    .foregroundColor(.wsCharcoal)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Price
                if let price = product.price {
                    Text("$\(price, specifier: "%.2f")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.wsCrimson)
                }

                // Actions
                HStack(spacing: 8) {
                    Button(action: {
                        onAddToCart()
                        withAnimation(.spring()) { isAdded = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { isAdded = false }
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: isAdded ? "checkmark" : "bag")
                                .font(.system(size: 10))
                            Text(isAdded ? "ADDED" : "ADD TO BAG")
                                .font(.wsLabel(size: 9))
                                .tracking(1)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(isAdded ? Color.wsMutedBrass : Color.wsCharcoal)
                        .cornerRadius(2)
                    }

                    Button(action: onAddToRegistry) {
                        Image(systemName: "heart")
                            .font(.system(size: 14))
                            .foregroundColor(.wsCharcoal)
                            .frame(width: 34, height: 34)
                            .overlay(Rectangle().stroke(Color.wsIvoryShadow, lineWidth: 1))
                    }
                }
            }
            .padding(10)
        }
        .background(Color.white)
        .cornerRadius(2)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}
