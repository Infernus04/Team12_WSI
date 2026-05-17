// MoodboardView.swift
// Team12_WSI — AI Moodboard: photo upload + text + Core Image analysis + product matching

import SwiftUI
import PhotosUI

struct MoodboardView: View {
    let allProducts: [ProductItem]

    @Environment(\.dismiss) private var dismiss

    // Photo state
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var uploadedImages: [UIImage] = []

    // Text input
    @State private var moodText: String = ""

    // Analysis results
    @State private var styleIdentity: StyleIdentity?
    @State private var scoredProducts: [ProductItem] = []
    @State private var isAnalyzing = false
    @State private var hasResults = false
    @State private var showPickerFor: Int? = nil

    // Style bar animation
    @State private var barsVisible = false

    // Selected product for navigation
    @State private var selectedProduct: ProductItem?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.wsWarmIvory.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    // Header
                    headerSection

                    // Photo grid
                    photoGridSection

                    // Text input
                    moodInputSection

                    // Analyze button
                    analyzeButton

                    // Results
                    if hasResults {
                        resultSection
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    Spacer().frame(height: 60)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: $selectedProduct) { product in
            // ProductDetailView will be handled by parent
            EmptyView()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.wsCharcoal)
                        .font(.system(size: 16, weight: .medium))
                }
                Spacer()
                Text("✦ AI MOODBOARD")
                    .font(.wsLabel(size: 10))
                    .tracking(2)
                    .foregroundColor(.wsMutedBrass)
                Spacer()
                Color.clear.frame(width: 20)
            }
            .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 6) {
                Text("Your Moodboard")
                    .font(.wsDisplay(size: 28))
                    .foregroundColor(.wsCharcoal)

                Text("Upload photos of your space or Pinterest\ninspiration to discover your aesthetic.")
                    .font(.wsBody(size: 14))
                    .foregroundColor(.wsSecondary)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Photo Grid

    private var photoGridSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("YOUR INSPIRATION PHOTOS")
                .font(.wsLabel(size: 10))
                .tracking(1.5)
                .foregroundColor(.wsSecondary)
                .padding(.horizontal, 24)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<9, id: \.self) { index in
                    if index < uploadedImages.count {
                        // Filled tile
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: uploadedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(height: 110)
                                .clipped()
                                .cornerRadius(4)

                            Button(action: { removeImage(at: index) }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.black.opacity(0.55))
                                    .clipShape(Circle())
                            }
                            .padding(5)
                        }
                        .frame(height: 110)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                        .animation(.spring(response: 0.4), value: uploadedImages.count)

                    } else if index == uploadedImages.count {
                        // Add tile
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: 9 - uploadedImages.count,
                            matching: .images
                        ) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.wsIvoryShadow, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                    .frame(height: 110)
                                    .background(Color.wsWarmIvory)

                                VStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .light))
                                        .foregroundColor(.wsMutedBrass)
                                    Text("Add Photo")
                                        .font(.wsBody(size: 11))
                                        .foregroundColor(.wsSecondary)
                                }
                            }
                        }
                        .onChange(of: selectedItems) { _ in
                            loadSelectedImages()
                        }

                    } else {
                        // Empty tile
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.wsIvoryShadow, style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .frame(height: 110)
                            .background(Color.wsWarmIvory.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 24)

            if !uploadedImages.isEmpty {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 10))
                        .foregroundColor(.wsMutedBrass)
                    Text("\(uploadedImages.count) photo\(uploadedImages.count == 1 ? "" : "s") added — including saved Pinterest images")
                        .font(.wsBody(size: 11))
                        .foregroundColor(.wsSecondary)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Mood Input

    private var moodInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DESCRIBE YOUR DESIRED VIBE")
                .font(.wsLabel(size: 10))
                .tracking(1.5)
                .foregroundColor(.wsSecondary)

            ZStack(alignment: .topLeading) {
                if moodText.isEmpty {
                    Text("e.g. warm oak, brass accents, minimalist textures, organic linen...")
                        .font(.wsBody(size: 14))
                        .foregroundColor(.wsSecondary.opacity(0.6))
                        .padding(16)
                }
                TextEditor(text: $moodText)
                    .font(.wsBody(size: 14))
                    .foregroundColor(.wsCharcoal)
                    .frame(minHeight: 80)
                    .padding(12)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
            }
            .background(Color.white)
            .overlay(Rectangle().stroke(Color.wsIvoryShadow, lineWidth: 1))
            .cornerRadius(2)

            // Example chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(exampleMoods, id: \.self) { mood in
                        Button(action: {
                            moodText = mood
                        }) {
                            Text(mood)
                                .font(.wsBody(size: 11))
                                .foregroundColor(.wsCharcoal)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(Color.white)
                                .overlay(Rectangle().stroke(Color.wsIvoryShadow, lineWidth: 1))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private let exampleMoods = [
        "Warm oak, brass, minimalist",
        "Coastal linen, airy whites",
        "Parisian eclectic, dark tones",
        "Organic modern, earthy neutrals",
        "Scandinavian calm, natural wood"
    ]

    // MARK: - Analyze Button

    private var analyzeButton: some View {
        Button(action: analyzeStyle) {
            HStack(spacing: 10) {
                if isAnalyzing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                }
                Text(isAnalyzing ? "ANALYZING YOUR STYLE..." : "✦ ANALYZE MY STYLE")
                    .font(.wsLabel(size: 12))
                    .tracking(1.5)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.wsCharcoal)
            .cornerRadius(2)
        }
        .padding(.horizontal, 24)
        .disabled(uploadedImages.isEmpty && moodText.trimmingCharacters(in: .whitespaces).isEmpty)
        .opacity((uploadedImages.isEmpty && moodText.trimmingCharacters(in: .whitespaces).isEmpty) ? 0.5 : 1)
    }

    // MARK: - Results

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Divider
            WSDivider().padding(.horizontal, 24)

            if let identity = styleIdentity {
                // Style Identity Card
                styleIdentityCard(identity: identity)

                // Products
                if !scoredProducts.isEmpty {
                    productsResultSection
                }
            }
        }
    }

    private func styleIdentityCard(identity: StyleIdentity) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("YOUR AESTHETIC IDENTITY")
                    .font(.wsLabel(size: 10))
                    .tracking(1.5)
                    .foregroundColor(.wsMutedBrass)

                Text(identity.name)
                    .font(.wsDisplay(size: 24))
                    .foregroundColor(.wsCharcoal)

                Text(identity.description)
                    .font(.wsSerif(size: 14))
                    .foregroundColor(.wsSecondary)
                    .lineSpacing(4)
            }

            // Color swatches
            HStack(spacing: 8) {
                ForEach(identity.swatches.indices, id: \.self) { i in
                    Circle()
                        .fill(identity.swatches[i])
                        .frame(width: 28, height: 28)
                        .overlay(Circle().stroke(Color.wsIvoryShadow, lineWidth: 1))
                }
                Spacer()
                Text("EXTRACTED PALETTE")
                    .font(.wsLabel(size: 9))
                    .tracking(1)
                    .foregroundColor(.wsSecondary)
            }

            // Style bars
            VStack(spacing: 12) {
                styleBar(label: "Warmth", value: identity.warmth, color: Color(hex: "#C4A882"))
                styleBar(label: "Modern", value: identity.modern, color: Color.wsCharcoal)
                styleBar(label: "Minimalist", value: identity.minimalist, color: Color.wsMutedBrass)
            }

            // AI label
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10))
                    .foregroundColor(.wsMutedBrass)
                Text("MODELED FROM YOUR MOODBOARD")
                    .font(.wsLabel(size: 9))
                    .tracking(1)
                    .foregroundColor(.wsMutedBrass)
            }
        }
        .padding(24)
        .background(Color.white)
        .wsLuxuryShadow()
        .padding(.horizontal, 24)
    }

    private func styleBar(label: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.wsBody(size: 12))
                    .foregroundColor(.wsCharcoal)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.wsLabel(size: 10))
                    .foregroundColor(.wsSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.wsChampagne)
                        .frame(height: 3)
                    Rectangle()
                        .fill(color)
                        .frame(width: barsVisible ? geo.size.width * value : 0, height: 3)
                        .animation(.easeOut(duration: 0.9).delay(Double(label.count) * 0.05), value: barsVisible)
                }
            }
            .frame(height: 3)
        }
    }

    private var productsResultSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Products That Match Your Vibe")
                    .font(.wsDisplay(size: 22))
                    .foregroundColor(.wsCharcoal)
                    .padding(.horizontal, 24)
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10))
                        .foregroundColor(.wsMutedBrass)
                    Text("SCORED BY YOUR AESTHETIC  ✦")
                        .font(.wsLabel(size: 9))
                        .tracking(1)
                        .foregroundColor(.wsMutedBrass)
                }
                .padding(.horizontal, 24)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(scoredProducts.prefix(10)) { product in
                        miniProductCard(product: product)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private func miniProductCard(product: ProductItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            CustomAsyncImage(url: product.imageURL)
                .frame(width: 160, height: 190)
                .clipped()
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.wsBody(size: 12))
                    .foregroundColor(.wsCharcoal)
                    .lineLimit(2)
                if let price = product.price {
                    Text("$\(price, specifier: "%.2f")")
                        .font(.wsLabel(size: 11))
                        .foregroundColor(.wsCrimson)
                }
            }
            .frame(width: 160, alignment: .leading)
        }
    }

    // MARK: - Actions

    private func loadSelectedImages() {
        Task {
            var loaded: [UIImage] = []
            for item in selectedItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    loaded.append(img)
                }
            }
            await MainActor.run {
                withAnimation(.spring(response: 0.4)) {
                    uploadedImages.append(contentsOf: loaded)
                    uploadedImages = Array(uploadedImages.prefix(9))
                }
                selectedItems = []
            }
        }
    }

    private func removeImage(at index: Int) {
        withAnimation(.spring(response: 0.3)) {
            if index < uploadedImages.count {
                uploadedImages.remove(at: index)
            }
        }
    }

    private func analyzeStyle() {
        guard !isAnalyzing else { return }
        isAnalyzing = true
        barsVisible = false

        Task {
            // Extract colors from uploaded images
            var colorTokens: [String] = []
            for image in uploadedImages {
                if let color = HomeAIPersonalizationEngine.dominantColor(from: image) {
                    let token = HomeAIPersonalizationEngine.classifyColor(color)
                    colorTokens.append(token)
                }
            }

            // Tokenize text
            let textKeywords = HomeAIPersonalizationEngine.tokenize(moodText)

            // Generate style identity
            let identity = HomeAIPersonalizationEngine.generateStyleIdentity(
                colorTokens: colorTokens,
                textKeywords: textKeywords
            )

            // Score products
            let allKeywords = textKeywords + SeasonalContextEngine.seasonalKeywords()
            let scored = HomeAIPersonalizationEngine.scoreProducts(
                allProducts,
                keywords: allKeywords,
                colorTokens: colorTokens
            )

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.styleIdentity = identity
                    self.scoredProducts = scored
                    self.hasResults = true
                    self.isAnalyzing = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    barsVisible = true
                }
            }
        }
    }
}
