// MoodboardResultsView.swift
// Team12_WSI — Dedicated results screen: aesthetic identity + irregular masonry collage

import SwiftUI

struct MoodboardResultsView: View {
    let profile: MoodboardStyleProfile
    let scoredProducts: [ScoredProduct]
    let allProducts: [ProductItem]
    let onAddToCart: (ProductItem) -> Void
    let onAddToRegistry: (ProductItem) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var barsVisible = false
    @State private var collageAppeared = false
    @State private var selectedProduct: ProductItem?

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 28) {
                    headerSection(width: screenWidth)
                    styleIdentityCard(width: screenWidth)

                    if profile.confidence < 0.5 {
                        confidenceNote(width: screenWidth)
                    }

                    if !scoredProducts.isEmpty {
                        collageSection(width: screenWidth)
                    }

                    Spacer().frame(height: 60)
                }
                .frame(width: screenWidth)
                .padding(.top, 16)
            }
        }
        .background(Color.wsWarmIvory.ignoresSafeArea())
        .ignoresSafeArea(.container, edges: .bottom)
        .fullScreenCover(item: $selectedProduct) { product in
            NavigationStack {
                ProductDetailView(
                    product: product,
                    allProducts: allProducts,
                    onAddToCart: onAddToCart,
                    onAddToRegistry: onAddToRegistry,
                    onAddToSaveForLater: nil,
                    cartQuantity: 0,
                    registryQuantity: 0,
                    isInSaveForLater: false,
                    onSelectRelatedProduct: { related in
                        selectedProduct = related
                    }
                )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { barsVisible = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.6)) { collageAppeared = true }
            }
        }
    }

    // MARK: - Header

    private func headerSection(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .medium))
                        Text("Back")
                            .font(.wsBody(size: 14))
                    }
                    .foregroundColor(.wsCharcoal)
                }
                Spacer()
                Text("✦ YOUR RESULTS")
                    .font(.wsLabel(size: 10))
                    .tracking(2)
                    .foregroundColor(.wsMutedBrass)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.wsCharcoal)
                }
            }

            Text("Your Style Profile")
                .font(.wsDisplay(size: 26))
                .foregroundColor(.wsCharcoal)

            Text("Based on your moodboard and aesthetic preferences.")
                .font(.wsBody(size: 13))
                .foregroundColor(.wsSecondary)
        }
        .frame(width: width - 40, alignment: .leading)
        .padding(.horizontal, 20)
    }

    // MARK: - Style Identity Card

    private func styleIdentityCard(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("YOUR AESTHETIC IDENTITY")
                .font(.wsLabel(size: 10))
                .tracking(1.5)
                .foregroundColor(.wsMutedBrass)

            Text(profile.identityName)
                .font(.wsDisplay(size: 22))
                .foregroundColor(.wsCharcoal)
                .fixedSize(horizontal: false, vertical: true)

            Text(profile.identityDescription)
                .font(.wsSerif(size: 13))
                .foregroundColor(.wsSecondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

            // Color swatches
            HStack(spacing: 8) {
                ForEach(profile.swatches.indices, id: \.self) { i in
                    Circle()
                        .fill(profile.swatches[i])
                        .frame(width: 24, height: 24)
                        .overlay(Circle().stroke(Color.wsIvoryShadow, lineWidth: 1))
                }
                Spacer()
                Text("PALETTE")
                    .font(.wsLabel(size: 8))
                    .tracking(1)
                    .foregroundColor(.wsSecondary)
            }

            // Style bars
            VStack(spacing: 10) {
                styleBar(label: "Warmth", value: profile.warmth, color: Color(hex: "#C4A882"), barWidth: width - 80)
                styleBar(label: "Modern", value: profile.modern, color: Color.wsCharcoal, barWidth: width - 80)
                styleBar(label: "Minimalist", value: profile.minimalist, color: Color.wsMutedBrass, barWidth: width - 80)
            }

            // Tags
            if !profile.styleTags.isEmpty || !profile.materialTags.isEmpty {
                tagRow
            }

            // AI badge
            HStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .font(.system(size: 9))
                    .foregroundColor(.wsMutedBrass)
                Text("MODELED FROM YOUR MOODBOARD")
                    .font(.wsLabel(size: 8))
                    .tracking(1)
                    .foregroundColor(.wsMutedBrass)
            }
        }
        .padding(20)
        .frame(width: width - 40, alignment: .leading)
        .background(Color.white)
        .cornerRadius(4)
        .wsLuxuryShadow()
        .padding(.horizontal, 20)
    }

    private func styleBar(label: String, value: Double, color: Color, barWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label)
                    .font(.wsBody(size: 11))
                    .foregroundColor(.wsCharcoal)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.wsLabel(size: 9))
                    .foregroundColor(.wsSecondary)
            }
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.wsChampagne)
                    .frame(height: 3)
                Rectangle()
                    .fill(color)
                    .frame(width: barsVisible ? barWidth * CGFloat(value) : 0, height: 3)
                    .animation(.easeOut(duration: 0.9), value: barsVisible)
            }
            .frame(height: 3)
        }
    }

    private var tagRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(Array(Set(profile.styleTags + profile.materialTags + profile.moodTags)).sorted(), id: \.self) { tag in
                    Text(tag.uppercased())
                        .font(.wsLabel(size: 8))
                        .tracking(0.8)
                        .foregroundColor(.wsMutedBrass)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.wsChampagne)
                        .cornerRadius(2)
                }
            }
        }
    }

    // MARK: - Confidence Note

    private func confidenceNote(width: CGFloat) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb")
                .font(.system(size: 11))
                .foregroundColor(.wsMutedBrass)
            Text("We cast a wider net — try adding more photos for sharper results.")
                .font(.wsBody(size: 11))
                .foregroundColor(.wsSecondary)
        }
        .padding(14)
        .frame(width: width - 40, alignment: .leading)
        .background(Color.wsChampagne.opacity(0.6))
        .cornerRadius(4)
        .padding(.horizontal, 20)
    }

    // MARK: - Collage Section

    private func collageSection(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Products That Match Your Vibe")
                    .font(.wsDisplay(size: 20))
                    .foregroundColor(.wsCharcoal)
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9))
                        .foregroundColor(.wsMutedBrass)
                    Text("RANKED BY AESTHETIC MATCH  ✦")
                        .font(.wsLabel(size: 8))
                        .tracking(1)
                        .foregroundColor(.wsMutedBrass)
                }
            }
            .padding(.horizontal, 20)

            let tileWidth = width - 40
            let gap: CGFloat = 5

            VStack(spacing: gap) {
                let items = scoredProducts
                let rowCount = collageRowCount(for: items.count)

                ForEach(0..<rowCount, id: \.self) { rowIndex in
                    let pattern = rowIndex % 4
                    let startIdx = consumedIndex(for: rowIndex, total: items.count)
                    let rowItems = collageRowItems(pattern: pattern, startIndex: startIdx, items: items)

                    collageRow(pattern: pattern, items: rowItems, totalWidth: tileWidth, gap: gap)
                }
            }
            .padding(.horizontal, 20)
            .opacity(collageAppeared ? 1 : 0)
            .offset(y: collageAppeared ? 0 : 30)
        }
        .frame(width: width, alignment: .leading)
    }

    // MARK: - Collage Helpers

    private func collageRowCount(for total: Int) -> Int {
        var consumed = 0
        var rows = 0
        let sizes = [2, 1, 3, 2]
        while consumed < total {
            consumed += sizes[rows % 4]
            rows += 1
        }
        return rows
    }

    private func consumedIndex(for rowIndex: Int, total: Int) -> Int {
        let sizes = [2, 1, 3, 2]
        var consumed = 0
        for r in 0..<rowIndex { consumed += sizes[r % 4] }
        return min(consumed, total)
    }

    private func collageRowItems(pattern: Int, startIndex: Int, items: [ScoredProduct]) -> [ScoredProduct] {
        let sizes = [2, 1, 3, 2]
        let count = sizes[pattern]
        let end = min(startIndex + count, items.count)
        guard startIndex < end else { return [] }
        return Array(items[startIndex..<end])
    }

    @ViewBuilder
    private func collageRow(pattern: Int, items: [ScoredProduct], totalWidth: CGFloat, gap: CGFloat) -> some View {
        if items.isEmpty {
            EmptyView()
        } else {
            switch pattern {
            case 0: // Tall + Square
                HStack(spacing: gap) {
                    if items.count > 0 { collageTile(item: items[0], width: totalWidth * 0.55, height: 260) }
                    if items.count > 1 { collageTile(item: items[1], width: totalWidth * 0.45 - gap, height: 260) }
                }
            case 1: // Full width
                if items.count > 0 { collageTile(item: items[0], width: totalWidth, height: 190) }
            case 2: // Three equal
                HStack(spacing: gap) {
                    ForEach(items) { item in
                        collageTile(item: item, width: (totalWidth - gap * 2) / 3, height: 170)
                    }
                }
            case 3: // Square + Tall
                HStack(spacing: gap) {
                    if items.count > 0 { collageTile(item: items[0], width: totalWidth * 0.45, height: 240) }
                    if items.count > 1 { collageTile(item: items[1], width: totalWidth * 0.55 - gap, height: 240) }
                }
            default:
                EmptyView()
            }
        }
    }

    // MARK: - Collage Tile

    private func collageTile(item: ScoredProduct, width: CGFloat, height: CGFloat) -> some View {
        Button(action: { selectedProduct = item.product }) {
            ZStack(alignment: .bottomLeading) {
                CustomAsyncImage(url: item.product.imageURL)
                    .frame(width: width, height: height)
                    .clipped()
                    .cornerRadius(3)

                LinearGradient(
                    colors: [.clear, .clear, Color.black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: width, height: height)
                .cornerRadius(3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.product.name)
                        .font(.wsBody(size: 11))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)

                    if let price = item.product.price {
                        Text("$\(price, specifier: "%.2f")")
                            .font(.wsLabel(size: 10))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(10)
                .frame(width: width, alignment: .leading)
            }
        }
        .buttonStyle(CollageTileButtonStyle())
    }
}

private struct CollageTileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
