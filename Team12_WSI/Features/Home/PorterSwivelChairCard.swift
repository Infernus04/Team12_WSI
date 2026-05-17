// PorterSwivelChairCard.swift
// Team12_WSI — Static featured product card for Porter Swivel Chair
// Links to thesofa.usdz via AR Quick Look (pinch-to-scale supported natively)

import SwiftUI

// MARK: - Porter Swivel Chair section (drop into any ScrollView)

struct PorterSwivelChairSection: View {
    let onAddToCart: () -> Void
    let onAddToRegistry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("New Arrival")
                        .font(.wsDisplay(size: 24))
                        .foregroundColor(.wsCharcoal)
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9))
                            .foregroundColor(.wsMutedBrass)
                        Text("FEATURED SEATING COLLECTION")
                            .font(.wsLabel(size: 9))
                            .tracking(1)
                            .foregroundColor(.wsMutedBrass)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            PorterSwivelChairCard(
                onAddToCart: onAddToCart,
                onAddToRegistry: onAddToRegistry
            )
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - The card itself

struct PorterSwivelChairCard: View {
    let onAddToCart: () -> Void
    let onAddToRegistry: () -> Void

    @State private var showAR = false
    @State private var addedToCart = false
    @State private var heartPressed = false
    @State private var inRegistry = false

    // Fabric color options from screenshot
    private let fabricOptions: [(name: String, hex: String)] = [
        ("White",  "#F5F3EE"),
        ("Ivory",  "#EDE8DC"),
        ("Lt Grey","#C8C5BF"),
        ("Denim",  "#3B5998"),
        ("Grey",   "#9E9C98")
    ]
    @State private var selectedFabric = 2 // default Light Grey

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Image area ──────────────────────────────────────────────
            ZStack(alignment: .topLeading) {
                // Chair image from Assets — overlay keeps frame identical to old placeholder
                Color.clear
                    .frame(maxWidth: .infinity)
                    .aspectRatio(0.88, contentMode: .fit)
                    .overlay(
                        Image("sofa_image")
                            .resizable()
                            .scaledToFill()
                    )
                    .clipped()

                // "New" badge top-left
                WSBadge(text: "New Arrival")
                    .padding(8)

                // AR camera button — bottom left
                VStack {
                    Spacer()
                    HStack {
                        Button { showAR = true } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("View in AR")
                                    .font(.system(size: 10, weight: .semibold))
                                    .tracking(0.3)
                            }
                            .foregroundColor(.wsPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.94))
                            .clipShape(Capsule())
                        }
                        .padding(10)
                        Spacer()
                    }
                }

                // Heart / registry — top right
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
                            inRegistry.toggle()
                            if inRegistry { onAddToRegistry() }
                        } label: {
                            Image(systemName: inRegistry ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(inRegistry ? .wsCrimson : .wsPrimary)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.92))
                                .clipShape(Circle())
                                .scaleEffect(heartPressed ? 1.25 : 1.0)
                        }
                        .padding(8)
                    }
                }
            }
            .fullScreenCover(isPresented: $showAR) {
                if let url = ARModelLibrary.sofaURL {
                    ARQuickLookScreen(fileURL: url, onExit: { showAR = false })
                } else {
                    arUnavailableFallback
                }
            }

            // ── Product info ─────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 8) {

                Text("Porter Swivel Chair")
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.wsPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 12)

                // Price range
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("Sugg. Price")
                            .font(.wsCaption)
                            .foregroundColor(.wsSecondary)
                        Text("$1,174 – $3,062")
                            .font(.wsCaption)
                            .foregroundColor(.wsSecondary)
                            .strikethrough(true, color: .wsSecondary)
                    }
                    HStack(spacing: 4) {
                        Text("Our Price")
                            .font(.wsCaption)
                            .foregroundColor(.wsSecondary)
                        Text("$995 – $2,595")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.wsCrimson)
                    }
                }

                // Q & A link
                Button(action: {}) {
                    Text("Q & A")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.wsPrimary)
                        .underline()
                }

                // Fabric & Color selector
                fabricSelector

                // Cart button
                Button(action: {
                    onAddToCart()
                    withAnimation(.spring(response: 0.3)) { addedToCart = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { addedToCart = false }
                    }
                }) {
                    Text(addedToCart ? "ADDED TO BAG ✓" : "ADD TO CART")
                        .font(.wsLabel)
                        .tracking(0.8)
                        .foregroundColor(addedToCart ? .white : .wsPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(addedToCart ? Color.wsCrimson : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(addedToCart ? Color.clear : Color.wsPrimary, lineWidth: 1)
                        )
                        .animation(.easeInOut(duration: 0.2), value: addedToCart)
                }
                .padding(.top, 4)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 12)
        }
        .background(Color.wsSurface)
        .cornerRadius(2)
        .wsShadow()
    }

    // MARK: - Fabric Selector

    private var fabricSelector: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text("Select Fabric And Color")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.wsPrimary)
                Text("59 Choices")
                    .font(.system(size: 10))
                    .foregroundColor(.wsSecondary)
            }

            // Colour swatches — Perennials Performance Basketweave
            Text("Perennials Performance Basketweave")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.wsSecondary)
                .tracking(0.2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(fabricOptions.enumerated()), id: \.offset) { index, option in
                        fabricSwatch(index: index, option: option)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func fabricSwatch(index: Int, option: (name: String, hex: String)) -> some View {
        VStack(spacing: 3) {
            Circle()
                .fill(Color(hex: option.hex))
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(
                            selectedFabric == index ? Color.wsPrimary : Color.wsDivider,
                            lineWidth: selectedFabric == index ? 2 : 1
                        )
                )
                .onTapGesture { selectedFabric = index }

            Text(option.name)
                .font(.system(size: 8))
                .foregroundColor(.wsSecondary)
                .frame(width: 34)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - AR unavailable fallback

    private var arUnavailableFallback: some View {
        ZStack {
            Color.wsWarmIvory.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(.wsMutedBrass)
                Text("3D model not found in bundle")
                    .font(.wsSerif(size: 16))
                    .foregroundColor(.wsSecondary)
                Text("Please add thesofa.usdz to the app target's\nCopy Bundle Resources build phase.")
                    .font(.wsBody(size: 12))
                    .foregroundColor(.wsSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("Close") { showAR = false }
                    .buttonStyle(WSPrimaryButtonStyle())
                    .padding(.horizontal, 40)
            }
        }
    }
}
