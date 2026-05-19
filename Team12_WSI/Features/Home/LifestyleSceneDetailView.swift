// LifestyleSceneDetailView.swift
// Team12_WSI — Immersive scene detail: lifestyle story + shoppable product grid

import SwiftUI

struct LifestyleSceneDetailView: View {
    let scene: LifestyleScene
    let allProducts: [ProductItem]
    let onSelectProduct: (ProductItem) -> Void
    let onAddToCart: (ProductItem) -> Void
    let onAddToRegistry: (ProductItem) -> Void

    @Environment(\.dismiss) private var dismiss

    // Pull the hero + related products for this scene (hero + 5 companions)
    private var sceneProducts: [ProductItem] {
        guard !allProducts.isEmpty else { return [] }
        let base = scene.productOffset
        let count = allProducts.count
        return (0..<6).compactMap { offset -> ProductItem? in
            let idx = (base + offset) % count
            return allProducts[idx]
        }
    }

    private var heroProduct: ProductItem? { sceneProducts.first }
    private var gridProducts: [ProductItem] { Array(sceneProducts.dropFirst()) }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    @State private var whyExpanded = false
    @State private var headerAppeared = false
    @State private var gridAppeared = false

    var body: some View {
        ZStack(alignment: .top) {
            Color.wsWarmIvory.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroBlock
                    sceneStory
                    WSDivider().padding(.horizontal, 24).padding(.vertical, 4)
                    shopTheScene
                    Spacer().frame(height: 60)
                }
            }

            topBar
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { headerAppeared = true }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { gridAppeared = true }
        }
    }

    // MARK: Hero

    private var heroBlock: some View {
        ZStack(alignment: .bottom) {
            // Hero image — full bleed cinematic
            if let hero = heroProduct {
                CustomAsyncImage(url: hero.imageURL)
                    .frame(maxWidth: .infinity)
                    .frame(height: 440)
                    .clipped()
            } else {
                Color.wsChampagne.frame(height: 440)
            }

            // Layered scrim — warm ivory fade at base for smooth transition into white body
            LinearGradient(
                colors: [
                    .clear,
                    Color.wsCharcoal.opacity(0.15),
                    Color.wsCharcoal.opacity(0.70)
                ],
                startPoint: .init(x: 0.5, y: 0.3),
                endPoint: .bottom
            )
            .frame(height: 440)

            // Hero text block
            VStack(alignment: .leading, spacing: 10) {
                Text("THE SCENE")
                    .font(.wsLabel(size: 9))
                    .tracking(2.5)
                    .foregroundColor(.wsMutedBrass)

                Text(scene.title)
                    .font(.wsDisplay(size: 30))
                    .foregroundColor(.white)
                    .lineSpacing(3)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                Text(scene.subtitle)
                    .font(.wsSerif(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .italic()
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 36)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(headerAppeared ? 1 : 0)
            .offset(y: headerAppeared ? 0 : 16)
        }
    }

    // MARK: Story / Why This Works

    private var sceneStory: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section label
            HStack(spacing: 6) {
                Image(systemName: "leaf")
                    .font(.system(size: 9))
                    .foregroundColor(.wsMutedBrass)
                Text("THE DESIGN STORY")
                    .font(.wsLabel(size: 9))
                    .tracking(2)
                    .foregroundColor(.wsMutedBrass)
            }

            // "Why This Works" expandable
            VStack(alignment: .leading, spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.35)) { whyExpanded.toggle() }
                }) {
                    HStack {
                        Text("Why This Scene Works")
                            .font(.wsSerif(size: 18, weight: .semibold))
                            .foregroundColor(.wsCharcoal)
                        Spacer()
                        Image(systemName: whyExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.wsSecondary)
                    }
                }

                if whyExpanded {
                    Text(scene.reason)
                        .font(.wsSerif(size: 14))
                        .foregroundColor(.wsSecondary)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                WSDivider()

                // Style DNA tags
                HStack(spacing: 8) {
                    ForEach(styleTagsForScene, id: \.self) { tag in
                        Text(tag)
                            .font(.wsLabel(size: 9))
                            .tracking(1)
                            .foregroundColor(.wsMutedBrass)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .overlay(Rectangle().stroke(Color.wsMutedBrass.opacity(0.4), lineWidth: 1))
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
    }

    // MARK: Shop The Scene

    private var shopTheScene: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Shop The Scene")
                    .font(.wsDisplay(size: 24))
                    .foregroundColor(.wsCharcoal)
                Text("\(sceneProducts.count) PIECES FEATURED IN THIS LOOK")
                    .font(.wsLabel(size: 9))
                    .tracking(1.5)
                    .foregroundColor(.wsSecondary)
            }
            .padding(.horizontal, 24)

            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(sceneProducts) { product in
                    SceneProductCard(
                        product: product,
                        onSelect: { onSelectProduct(product) },
                        onAddToCart: { onAddToCart(product) },
                        onAddToRegistry: { onAddToRegistry(product) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .opacity(gridAppeared ? 1 : 0)
            .offset(y: gridAppeared ? 0 : 24)
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
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

    // MARK: Style tags derived from scene title

    private var styleTagsForScene: [String] {
        let title = scene.title.lowercased()
        if title.contains("brunch") { return ["ORGANIC", "LINEN", "MORNING RITUAL"] }
        if title.contains("dining") { return ["CANDLELIGHT", "BRASS", "INTIMATE"] }
        if title.contains("autumn") { return ["COPPER", "WARM TONES", "SEASONAL"] }
        if title.contains("kitchen") { return ["HAND-THROWN", "SLOW LIVING", "ARTISANAL"] }
        return ["CURATED", "EDITORIAL", "LIFESTYLE"]
    }
}

// MARK: - Scene Product Card

struct SceneProductCard: View {
    let product: ProductItem
    let onSelect: () -> Void
    let onAddToCart: () -> Void
    let onAddToRegistry: () -> Void
    var badgeLabel: String? = "IN SCENE"   // Pass nil to hide the badge

    @State private var isAdded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Tappable image → ProductDetailView
            Button(action: onSelect) {
                ZStack(alignment: .topTrailing) {
                    CustomAsyncImage(url: product.imageURL)
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipped()

                    if let badge = badgeLabel {
                        Text(badge)
                            .font(.wsLabel(size: 7))
                            .tracking(1)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.wsCharcoal.opacity(0.75))
                            .padding(6)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                if let type = product.productType {
                    Text(type.uppercased())
                        .font(.wsLabel(size: 8))
                        .tracking(1.5)
                        .foregroundColor(.wsMutedBrass)
                }

                Text(product.name)
                    .font(.wsBody(size: 13))
                    .foregroundColor(.wsCharcoal)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let price = product.price {
                    Text("$\(price, specifier: "%.2f")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.wsCrimson)
                }

                    Button(action: {
                        onAddToCart()
                        withAnimation(.spring()) { isAdded = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { isAdded = false }
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isAdded ? "checkmark" : "bag")
                                .font(.system(size: 9))
                            Text(isAdded ? "ADDED" : "ADD")
                                .font(.wsLabel(size: 9))
                                .tracking(1)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                        .background(isAdded ? Color.wsMutedBrass : Color.wsCharcoal)
                        .cornerRadius(2)
                    }
            }
            .padding(10)
        }
        .background(Color.white)
        .cornerRadius(2)
        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}
