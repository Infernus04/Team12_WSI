// MoodboardView.swift
// Team12_WSI — AI Moodboard: input-only (photo upload + text + analyze)
// Results are shown in MoodboardResultsView via NavigationLink.

import SwiftUI
import PhotosUI

struct MoodboardView: View {
    let allProducts: [ProductItem]
    let onAddToCart: (ProductItem) -> Void
    let onAddToRegistry: (ProductItem) -> Void

    @Environment(\.dismiss) private var dismiss

    // Photo state
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var uploadedImages: [UIImage] = []

    // Text input
    @State private var moodText: String = ""

    // Analysis state
    @State private var isAnalyzing = false

    // Navigation to results
    @State private var analysisProfile: MoodboardStyleProfile?
    @State private var analysisProducts: [ScoredProduct] = []
    @State private var showResults = false

    var body: some View {
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

                Spacer().frame(height: 60)
            }
            .padding(.top, 20)
        }
        .background(Color.wsWarmIvory.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showResults) {
            if let profile = analysisProfile {
                MoodboardResultsView(
                    profile: profile,
                    scoredProducts: analysisProducts,
                    allProducts: allProducts,
                    onAddToCart: onAddToCart,
                    onAddToRegistry: onAddToRegistry
                )
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
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

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(exampleMoods, id: \.self) { mood in
                        Button(action: { moodText = mood }) {
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
        .disabled(isAnalyzing || (uploadedImages.isEmpty && moodText.trimmingCharacters(in: .whitespaces).isEmpty))
        .opacity((uploadedImages.isEmpty && moodText.trimmingCharacters(in: .whitespaces).isEmpty) ? 0.5 : 1)
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

        Task {
            let (profile, scored) = await MoodboardStyleAnalyzer.analyze(
                images: uploadedImages,
                vibeText: moodText,
                allProducts: allProducts
            )

            await MainActor.run {
                self.analysisProfile = profile
                self.analysisProducts = scored
                self.isAnalyzing = false
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showResults = true
                }
            }
        }
    }
}
