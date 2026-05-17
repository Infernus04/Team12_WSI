// HomeSearchView.swift
// Team12_WSI — Luxury natural language search sheet

import SwiftUI

struct HomeSearchView: View {
    let allProducts: [ProductItem]
    let onSelectProduct: (ProductItem) -> Void
    var onAddToCart: ((ProductItem) -> Void)? = nil
    var onAddToRegistry: ((ProductItem) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var appeared = false

    private let moodChips = [
        "Warm Autumn Hosting",
        "Minimalist First Apartment",
        "Luxury Wedding Registry",
        "Organic Modern Dining",
        "Coastal Brunch Hosting",
        "Parisian Kitchen Edit"
    ]

    private var filteredProducts: [ProductItem] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return allProducts
        }
        let q = searchText.lowercased()
        return allProducts.filter {
            $0.name.lowercased().contains(q) ||
            ($0.productType?.lowercased().contains(q) ?? false) ||
            ($0.brand?.lowercased().contains(q) ?? false)
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            Color.wsWarmIvory.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar
                searchHeader

                // Mood chips
                moodChipsRow

                WSDivider()

                // Content
                if filteredProducts.isEmpty {
                    emptyState
                } else {
                    productGrid
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    // MARK: - Search Header

    private var searchHeader: some View {
        HStack(spacing: 14) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.wsCharcoal)
                    .font(.system(size: 16, weight: .light))
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.wsSecondary)
                    .font(.system(size: 14))
                TextField("Search by mood, style, or product...", text: $searchText)
                    .font(.wsBody(size: 15))
                    .foregroundColor(.wsCharcoal)
                    .submitLabel(.search)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.wsSecondary)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.white)
            .overlay(Rectangle().stroke(Color.wsIvoryShadow, lineWidth: 1))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.wsWarmIvory)
    }

    // MARK: - Mood Chips

    private var moodChipsRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SEARCH BY MOOD")
                .font(.wsLabel(size: 9))
                .tracking(1.5)
                .foregroundColor(.wsSecondary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(moodChips, id: \.self) { chip in
                        Button(action: { searchText = chip }) {
                            Text(chip)
                                .font(.wsBody(size: 12))
                                .foregroundColor(searchText == chip ? .white : .wsCharcoal)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(searchText == chip ? Color.wsCharcoal : Color.white)
                                .overlay(
                                    Rectangle().stroke(
                                        searchText == chip ? Color.wsCharcoal : Color.wsIvoryShadow,
                                        lineWidth: 1
                                    )
                                )
                                .animation(.easeInOut(duration: 0.2), value: searchText)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Product Grid

    private var productGrid: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                // Result count
                HStack {
                    Text(searchText.isEmpty ? "ALL PRODUCTS" : "\(filteredProducts.count) RESULTS")
                        .font(.wsLabel(size: 9))
                        .tracking(1.5)
                        .foregroundColor(.wsSecondary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(filteredProducts) { product in
                        SceneProductCard(
                            product: product,
                            onSelect: {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onSelectProduct(product)
                                }
                            },
                            onAddToCart: { onAddToCart?(product) },
                            onAddToRegistry: { onAddToRegistry?(product) },
                            badgeLabel: nil  // No badge in search context
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36, weight: .ultraLight))
                .foregroundColor(.wsIvoryShadow)
            VStack(spacing: 8) {
                Text("No results found")
                    .font(.wsSerif(size: 20))
                    .foregroundColor(.wsCharcoal)
                Text("Try a different mood or browse the collection.")
                    .font(.wsBody(size: 13))
                    .foregroundColor(.wsSecondary)
            }
            Spacer()
        }
    }
}

