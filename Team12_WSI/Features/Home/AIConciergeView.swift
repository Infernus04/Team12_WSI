// AIConciergeView.swift
// Team12_WSI — Elegant 4-tab AI Concierge panel

import SwiftUI

struct AIConciergeView: View {
    let allProducts: [ProductItem]
    let registryRepository: RegistryRepository
    let onSelectProduct: (ProductItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    private let tabs = [
        ("heart.text.square", "Registry"),
        ("photo.on.rectangle", "Room Styling"),
        ("fork.knife", "Hosting"),
        ("gift", "Gifting")
    ]

    var body: some View {
        ZStack {
            Color.wsWarmIvory.ignoresSafeArea()

            VStack(spacing: 0) {
                conciergeHeader
                tabSelector
                WSDivider()
                tabContent
            }
        }
    }

    // MARK: - Header

    private var conciergeHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11))
                        .foregroundColor(.wsMutedBrass)
                    Text("AURA AI CONCIERGE")
                        .font(.wsLabel(size: 10))
                        .tracking(2)
                        .foregroundColor(.wsMutedBrass)
                }
                Text("Your Home Intelligence")
                    .font(.wsDisplay(size: 22))
                    .foregroundColor(.wsCharcoal)
            }
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.wsCharcoal)
                    .frame(width: 36, height: 36)
                    .background(Color.white)
                    .clipShape(Circle())
                    .wsShadow()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color.wsWarmIvory)
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { i in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = i }
                }) {
                    VStack(spacing: 5) {
                        Image(systemName: tabs[i].0)
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(selectedTab == i ? .wsCharcoal : .wsSecondary)
                        Text(tabs[i].1)
                            .font(.wsLabel(size: 9))
                            .tracking(0.5)
                            .foregroundColor(selectedTab == i ? .wsCharcoal : .wsSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .overlay(
                        Rectangle()
                            .fill(selectedTab == i ? Color.wsCharcoal : Color.clear)
                            .frame(height: 1.5),
                        alignment: .bottom
                    )
                }
            }
        }
        .background(Color.wsWarmIvory)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                switch selectedTab {
                case 0: registryTab
                case 1: roomStylingTab
                case 2: hostingTab
                case 3: giftingTab
                default: EmptyView()
                }
                Spacer().frame(height: 30)
            }
            .padding(.top, 24)
        }
    }

    // MARK: - Tab 0: Registry

    private var registryTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            conciergeCard(
                icon: "heart.text.square",
                headline: "Registry Guidance",
                body: "A well-balanced registry includes pieces across every price tier — from meaningful everyday items to aspirational statement pieces. Aim for 3–5 items per category."
            )

            conciergeCard(
                icon: "checkmark.seal",
                headline: "Registry Best Practice",
                body: "The most-gifted registries include 60–70% items under $100, creating accessibility for all guests while still featuring aspirational pieces above $200."
            )

            conciergeCard(
                icon: "sparkles",
                headline: "Aura AI Insight",
                body: "Based on Williams-Sonoma gifting patterns, cookware and bedding sets have the highest gifting conversion. Consider prioritizing these categories."
            )

            productCarouselSection(title: "Registry Essentials", products: Array(allProducts.prefix(6)))
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Tab 1: Room Styling

    private var roomStylingTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Moodboard entry card
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 10) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.wsMutedBrass)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Room Analysis")
                            .font(.wsSerif(size: 16, weight: .semibold))
                            .foregroundColor(.wsCharcoal)
                        Text("Upload photos of your space for personalized recommendations.")
                            .font(.wsBody(size: 13))
                            .foregroundColor(.wsSecondary)
                    }
                }

                Text("OPEN YOUR MOODBOARD")
                    .font(.wsLabel(size: 11))
                    .tracking(1.5)
                    .foregroundColor(.wsCharcoal)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .overlay(Rectangle().stroke(Color.wsCharcoal, lineWidth: 1))
            }
            .padding(20)
            .background(Color.white)
            .wsShadow()

            conciergeCard(
                icon: "house",
                headline: "Room Intelligence",
                body: "Our AI analyzes your room's lighting, color palette, and spatial density to recommend pieces that integrate seamlessly — not just products that look good in isolation."
            )

            conciergeCard(
                icon: "circle.hexagongrid",
                headline: "Style Compatibility",
                body: "\"These ceramics complement your oak flooring.\" \"Your dining room supports a larger serving table.\" \"This scale of artwork suits your ceiling height.\""
            )

            productCarouselSection(title: "Room-Ready Pieces", products: Array(allProducts.shuffled().prefix(6)))
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Tab 2: Hosting

    private var hostingTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Seasonal bundle preview
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                        .foregroundColor(.wsMutedBrass)
                    Text("SEASONAL RECOMMENDATION")
                        .font(.wsLabel(size: 9))
                        .tracking(1.5)
                        .foregroundColor(.wsMutedBrass)
                }

                Text(SeasonalContextEngine.seasonalSectionHeader())
                    .font(.wsSerif(size: 20, weight: .bold))
                    .foregroundColor(.wsCharcoal)

                Text("A curated hosting collection for this season — selected to work beautifully together.")
                    .font(.wsBody(size: 13))
                    .foregroundColor(.wsSecondary)
                    .lineSpacing(3)
            }
            .padding(20)
            .background(Color.white)
            .wsShadow()

            conciergeCard(
                icon: "fork.knife",
                headline: "Hosting Essentials",
                body: "A memorable dinner party requires three layers: the foundation (linens + dinnerware), the elevation (serving pieces + centerpiece), and the finishing touch (candles + small decorative objects)."
            )

            productCarouselSection(
                title: "Hosting Picks",
                products: seasonalProducts
            )
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Tab 3: Gifting

    private var giftingTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            conciergeCard(
                icon: "gift",
                headline: "Gifting Intelligence",
                body: "The most appreciated gifts feel intentional — a piece the recipient wouldn't buy for themselves but would cherish. Think elevated everyday objects over grand statements."
            )

            conciergeCard(
                icon: "chart.bar",
                headline: "Price Tier Strategy",
                body: "Great registry gifting spans three tiers: the meaningful gesture ($50–$100), the considered gift ($100–$250), and the aspirational present ($250+). Each serves a different relationship."
            )

            productCarouselSection(title: "Top Gifting Items", products: giftingProducts)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Reusable Components

    private func conciergeCard(icon: String, headline: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .ultraLight))
                .foregroundColor(.wsMutedBrass)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 6) {
                Text(headline)
                    .font(.wsSerif(size: 15, weight: .semibold))
                    .foregroundColor(.wsCharcoal)
                Text(body)
                    .font(.wsBody(size: 13))
                    .foregroundColor(.wsSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(Color.white)
        .wsShadow()
    }

    private func productCarouselSection(title: String, products: [ProductItem]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.wsSerif(size: 16, weight: .semibold))
                .foregroundColor(.wsCharcoal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(products) { product in
                        Button(action: {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSelectProduct(product)
                            }
                        }) {
                            conciergeProductTile(product: product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }

    private func conciergeProductTile(product: ProductItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            CustomAsyncImage(url: product.imageURL)
                .frame(width: 130, height: 130)
                .clipped()
                .cornerRadius(2)

            Text(product.name)
                .font(.wsBody(size: 11))
                .foregroundColor(.wsCharcoal)
                .lineLimit(2)
                .frame(width: 130, alignment: .leading)

            if let price = product.price {
                Text("$\(price, specifier: "%.2f")")
                    .font(.wsLabel(size: 10))
                    .foregroundColor(.wsCrimson)
            }
        }
    }

    // MARK: - Computed Data

    private var seasonalProducts: [ProductItem] {
        let keywords = SeasonalContextEngine.seasonalKeywords()
        return HomeAIPersonalizationEngine.scoreProducts(allProducts, keywords: keywords, colorTokens: [])
    }

    private var giftingProducts: [ProductItem] {
        allProducts
            .compactMap { p -> (ProductItem, Double)? in
                guard let price = p.price, price > 0 else { return nil }
                // Score mid-range products higher for gifting
                let score: Double = (price >= 50 && price <= 250) ? price : price * 0.5
                return (p, score)
            }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
            .prefix(8)
            .map { $0 }
    }
}
