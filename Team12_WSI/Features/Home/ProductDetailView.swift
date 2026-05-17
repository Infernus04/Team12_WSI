// ProductDetailView.swift
// Team12_WSI — Full luxury product detail with 5 recommendation sections

import SwiftUI

struct ProductDetailView: View {
    let product: ProductItem
    let allProducts: [ProductItem]
    let onAddToCart: (ProductItem) -> Void
    let onAddToRegistry: (ProductItem) -> Void
    let onAddToSaveForLater: ((ProductItem) -> Void)?   // nil = feature not injected
    let cartQuantity: Int
    let registryQuantity: Int
    let isInSaveForLater: Bool

    @Environment(\.dismiss) private var dismiss

    @State private var showAIModal = false
    @State private var heartPressed = false
    @State private var addedToCart = false
    @State private var showCopiedToast = false
    @State private var sectionAppeared = [false, false, false, false, false]
    // Recommendation card navigation
    @State private var selectedRecommendation: ProductItem?

    // Lazy-compute recommendations
    private var engine: ProductRecommendationEngine {
        ProductRecommendationEngine(allProducts: allProducts, selectedProduct: product)
    }

    private var youMayAlsoNeed: [ProductItem] { engine.youMayAlsoNeed() }
    private var alsoInCollection: [ProductItem] { engine.alsoInThisCollection() }
    private var similarItems: [ProductItem] { engine.similarItems() }

    private var excludedForMore: Set<String> {
        var ids = Set<String>()
        (youMayAlsoNeed + alsoInCollection + similarItems).forEach { ids.insert($0.id) }
        return ids
    }

    private var moreToConsider: [ProductItem] { engine.moreToConsider(excluding: excludedForMore) }
    private var instagramGrid: [ProductItem] { engine.instagramGridProducts() }

    var body: some View {
        ZStack(alignment: .top) {
            Color.wsWarmIvory.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    productHero
                    productInfo
                    actionZone
                    aiContextChip
                    recommendationSections
                    instagramSection
                    Spacer().frame(height: 40)
                }
            }

            // Top bar overlay
            topBar
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAIModal) {
            aiExplanationModal
        }
        // Tapping any recommendation card opens that product's detail
        .fullScreenCover(item: $selectedRecommendation) { rec in
            ProductDetailView(
                product: rec,
                allProducts: allProducts,
                onAddToCart: onAddToCart,
                onAddToRegistry: onAddToRegistry,
                onAddToSaveForLater: onAddToSaveForLater,
                cartQuantity: 0,
                registryQuantity: 0,
                isInSaveForLater: false
            )
        }
        .overlay(alignment: .bottom) {
            if showCopiedToast {
                toastView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.wsCharcoal)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Circle())
                    .wsShadow()
            }
            Spacer()
            Button(action: shareProduct) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.wsCharcoal)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Circle())
                    .wsShadow()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Hero Image

    private var productHero: some View {
        ZStack(alignment: .bottomLeading) {
            CustomAsyncImage(url: product.imageURL)
                .frame(maxWidth: .infinity)
                .frame(height: 420)
                .clipped()

            // Gradient fade at bottom
            LinearGradient(
                colors: [.clear, Color.wsWarmIvory.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 150)
            .frame(maxWidth: .infinity, alignment: .bottom)
        }
    }

    // MARK: - Product Info

    private var productInfo: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Product type badge
            if let type = product.productType {
                Text(type.uppercased())
                    .font(.wsLabel(size: 9))
                    .tracking(2)
                    .foregroundColor(.wsMutedBrass)
            }

            Text(product.name)
                .font(.wsSerif(size: 24, weight: .semibold))
                .foregroundColor(.wsCharcoal)
                .lineSpacing(3)

            // Pricing
            if let price = product.price {
                let suggested = price * 1.18
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Sugg. Price")
                            .font(.wsBody(size: 12))
                            .foregroundColor(.wsSecondary)
                        Text("$\(suggested, specifier: "%.2f")")
                            .font(.wsBody(size: 12))
                            .foregroundColor(.wsSecondary)
                            .strikethrough(true, color: .wsSecondary)
                    }
                    HStack(spacing: 6) {
                        Text("Our Price")
                            .font(.wsBody(size: 12))
                            .foregroundColor(.wsSecondary)
                        Text("$\(price, specifier: "%.2f")")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.wsCrimson)
                    }
                }
            }

            // Star rating (static)
            HStack(spacing: 3) {
                ForEach(0..<5) { i in
                    Image(systemName: i < 4 ? "star.fill" : "star.leadinghalf.filled")
                        .font(.system(size: 11))
                        .foregroundColor(.wsMutedBrass)
                }
                Text("4.5  (128 reviews)")
                    .font(.wsBody(size: 11))
                    .foregroundColor(.wsSecondary)
            }

            // Editorial description
            Text(editorialDescription)
                .font(.wsSerif(size: 14))
                .foregroundColor(.wsSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Action Zone

    private var actionZone: some View {
        VStack(spacing: 12) {
            // Add to bag
            Button(action: {
                onAddToCart(product)
                withAnimation(.spring(response: 0.3)) { addedToCart = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { addedToCart = false }
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: addedToCart ? "checkmark" : "bag")
                        .font(.system(size: 13))
                    Text(addedToCart ? "ADDED TO BAG" : (cartQuantity > 0 ? "ADD ANOTHER  (\(cartQuantity) IN BAG)" : "ADD TO BAG"))
                        .font(.wsLabel(size: 12))
                        .tracking(1.5)
                }
            }
            .buttonStyle(WSPrimaryButtonStyle())

            // Save for Later
            if let saveAction = onAddToSaveForLater {
                Button(action: { saveAction(product) }) {
                    HStack(spacing: 8) {
                        Image(systemName: isInSaveForLater ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 13))
                            .foregroundColor(isInSaveForLater ? .wsMutedBrass : .wsCharcoal)
                        Text(isInSaveForLater ? "SAVED FOR LATER" : "SAVE FOR LATER")
                            .font(.wsLabel(size: 12))
                            .tracking(1.5)
                    }
                }
                .buttonStyle(WSSecondaryButtonStyle())
            }

            // Save to registry
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { heartPressed = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation { heartPressed = false }
                }
                onAddToRegistry(product)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: registryQuantity > 0 ? "heart.fill" : "heart")
                        .font(.system(size: 13))
                        .foregroundColor(registryQuantity > 0 ? .wsCrimson : .wsCharcoal)
                        .scaleEffect(heartPressed ? 1.3 : 1.0)
                    Text(registryQuantity > 0 ? "SAVED TO REGISTRY" : "SAVE TO REGISTRY")
                        .font(.wsLabel(size: 12))
                        .tracking(1.5)
                }
            }
            .buttonStyle(WSSecondaryButtonStyle())
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
    }

    // MARK: - AI Context Chip

    private var aiContextChip: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 10))
                .foregroundColor(.wsMutedBrass)
            Text("CURATED FOR YOUR AESTHETIC  ✦")
                .font(.wsLabel(size: 9))
                .tracking(1.5)
                .foregroundColor(.wsMutedBrass)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }

    // MARK: - Recommendation Sections

    private var recommendationSections: some View {
        VStack(spacing: 0) {
            WSDivider()

            // Section: You May Also Need
            if !youMayAlsoNeed.isEmpty {
                recommendationSection(
                    index: 0,
                    title: "You May Also Need",
                    subtitle: "DESIGNED TO WORK TOGETHER  ✦",
                    products: youMayAlsoNeed
                )
                WSDivider()
            }

            // Section: Also In This Collection
            if !alsoInCollection.isEmpty {
                recommendationSection(
                    index: 1,
                    title: "Also In This Collection",
                    subtitle: product.productType.map { "FROM THE \($0.uppercased()) COLLECTION" } ?? "FROM THE SAME COLLECTION",
                    products: alsoInCollection
                )
                WSDivider()
            }

            // Section: Similar Items
            if !similarItems.isEmpty {
                recommendationSection(
                    index: 2,
                    title: "Similar Items",
                    subtitle: "BASED ON YOUR SELECTION  ✦",
                    products: similarItems
                )
                WSDivider()
            }

            // Section: More To Consider
            if !moreToConsider.isEmpty {
                recommendationSection(
                    index: 3,
                    title: "More To Consider",
                    subtitle: "HANDPICKED FOR YOU  ✦",
                    products: moreToConsider
                )
                WSDivider()
            }
        }
    }

    private func recommendationSection(index: Int, title: String, subtitle: String, products: [ProductItem]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.wsDisplay(size: 22))
                    .foregroundColor(.wsCharcoal)
                Text(subtitle)
                    .font(.wsLabel(size: 9))
                    .tracking(1.5)
                    .foregroundColor(.wsMutedBrass)
            }
            .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(products) { rec in
                        Button(action: { selectedRecommendation = rec }) {
                            RecommendationProductCard(product: rec)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 28)
        .opacity((sectionAppeared[safe: index] ?? false) ? 1 : 0)
        .offset(y: (sectionAppeared[safe: index] ?? false) ? 0 : 20)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(Double(index) * 0.1)) {
                if index < sectionAppeared.count { sectionAppeared[index] = true }
            }
        }
    }

    // MARK: - Instagram Section

    private var instagramSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            WSDivider()

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "camera")
                        .font(.system(size: 10))
                        .foregroundColor(.wsMutedBrass)
                    Text("SHARE YOUR MOMENTS")
                        .font(.wsLabel(size: 9))
                        .tracking(2)
                        .foregroundColor(.wsMutedBrass)
                }
                Text("@WilliamsSonoma")
                    .font(.wsDisplay(size: 22))
                    .foregroundColor(.wsCharcoal)
                Text("Style this piece and share your home story.")
                    .font(.wsSerif(size: 14))
                    .foregroundColor(.wsSecondary)
            }
            .padding(.horizontal, 24)

            // 3×2 image grid
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3),
                spacing: 3
            ) {
                ForEach(instagramGrid.prefix(6)) { p in
                    CustomAsyncImage(url: p.imageURL)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipped()
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("#WilliamsSonoma  #LuxuryHome  #GiftDNA")
                    .font(.wsBody(size: 12))
                    .foregroundColor(.wsSecondary)
                    .padding(.horizontal, 24)

                // Buttons
                VStack(spacing: 10) {
                    Button(action: shareProduct) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 13))
                            Text("SHARE ON INSTAGRAM")
                                .font(.wsLabel(size: 12))
                                .tracking(1.5)
                        }
                    }
                    .buttonStyle(WSPrimaryButtonStyle())

                    Button(action: copyProductLink) {
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                                .font(.system(size: 13))
                            Text("COPY PRODUCT LINK")
                                .font(.wsLabel(size: 12))
                                .tracking(1.5)
                        }
                    }
                    .buttonStyle(WSSecondaryButtonStyle())
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.vertical, 28)
    }

    // MARK: - AI Explanation Modal

    private var aiExplanationModal: some View {
        ZStack {
            Color.wsWarmIvory.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.wsMutedBrass)
                        Text("AURA AI")
                            .font(.wsLabel(size: 10))
                            .tracking(2)
                            .foregroundColor(.wsMutedBrass)
                    }
                    Spacer()
                    Button(action: { showAIModal = false }) {
                        Image(systemName: "xmark").foregroundColor(.wsCharcoal)
                    }
                }

                Text("Why This Product?")
                    .font(.wsDisplay(size: 22))
                    .foregroundColor(.wsCharcoal)

                Text("This piece was selected based on its alignment with your warm aesthetic preferences, natural material affinity, and the hosting occasions you've engaged with. It complements the organic warmth of your curated home environment.")
                    .font(.wsSerif(size: 15))
                    .foregroundColor(.wsSecondary)
                    .lineSpacing(5)

                Spacer()
            }
            .padding(30)
        }
        .presentationDetents([.medium])
    }

    // MARK: - Toast

    private var toastView: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .semibold))
            Text("Link Copied  ✓")
                .font(.wsLabel(size: 12))
                .tracking(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.wsCharcoal)
        .cornerRadius(2)
        .padding(.bottom, 30)
        .wsShadow()
    }

    // MARK: - Actions

    private func shareProduct() {
        let text = "\(product.name)\n$\(String(format: "%.2f", product.price ?? 0))\n\n#WilliamsSonoma #LuxuryHome"
        let items: [Any] = [text]
        let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?
            .present(av, animated: true)
    }

    private func copyProductLink() {
        let link = "\(AppConstants.API.baseURL)/product/\(product.id)"
        UIPasteboard.general.string = link
        withAnimation(.spring()) { showCopiedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopiedToast = false }
        }
    }

    // MARK: - Editorial Description

    private var editorialDescription: String {
        let name = product.name.lowercased()
        if name.contains("ceramic") || name.contains("dinnerware") || name.contains("plate") {
            return "Crafted with intention, this piece brings an artisanal quality to everyday rituals. The tactile finish and considered form make it equally at home on a set table or a kitchen shelf."
        } else if name.contains("linen") || name.contains("napkin") || name.contains("runner") {
            return "Woven from premium natural fibers, this textile softens any table setting with effortless elegance. Designed to be lived in and laundered with care."
        } else if name.contains("cookware") || name.contains("pan") || name.contains("pot") {
            return "Precision-engineered for professional performance and domestic beauty. The weight, balance, and finish are calibrated for cooks who consider the kitchen a creative space."
        } else if name.contains("candle") || name.contains("holder") {
            return "A considered source of warmth and atmosphere. The scale and material complement both minimal and layered interiors, casting light that transforms the ordinary into the intimate."
        } else {
            return "A carefully considered object that earns its place in a well-curated home. Designed for longevity over trend, this piece will age with the spaces it inhabits."
        }
    }
}

// MARK: - Recommendation Product Card

struct RecommendationProductCard: View {
    let product: ProductItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CustomAsyncImage(url: product.imageURL)
                .frame(width: 175, height: 210)
                .clipped()
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.wsBody(size: 12))
                    .foregroundColor(.wsCharcoal)
                    .lineLimit(2)
                    .frame(width: 175, alignment: .leading)

                if let price = product.price {
                    Text("$\(price, specifier: "%.2f")")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.wsCrimson)
                }

                // Subtle tap hint
                HStack(spacing: 4) {
                    Text("VIEW PRODUCT")
                        .font(.wsLabel(size: 9))
                        .tracking(1)
                        .foregroundColor(.wsMutedBrass)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 8))
                        .foregroundColor(.wsMutedBrass)
                }
            }
        }
    }
}

// MARK: - Safe Array Subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else { return nil }
        return self[index]
    }
}
