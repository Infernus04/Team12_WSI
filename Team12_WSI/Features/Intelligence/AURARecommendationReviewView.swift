import SwiftUI

// MARK: - AURA Recommendation Review View

struct AURARecommendationReviewView: View {
    @StateObject private var viewModel: AURARecommendationReviewViewModel
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel

    init(payload: RegistryQuestionnairePayload, registryRepo: RegistryRepository?) {
        _viewModel = StateObject(wrappedValue:
            AURARecommendationReviewViewModel(payload: payload, registryRepo: registryRepo)
        )
    }

    var body: some View {
        ZStack {
            WSRegistryPalette.ivory.ignoresSafeArea()

            if viewModel.isLoading {
                loadingState
            } else if let error = viewModel.errorMessage {
                errorState(error)
            } else {
                recommendationContent
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.regenerate() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.gold)
                }
                .accessibilityLabel("Regenerate recommendations")
            }
        }
        .task {
            await viewModel.loadRecommendations()
        }
    }
}

// MARK: - Content

private extension AURARecommendationReviewView {
    var recommendationContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                headerSection
                contextBanner
                bulkActionsCard

                ForEach(viewModel.sections) { section in
                    categorySection(section)
                }

                if !viewModel.recommendations.isEmpty {
                    aiPicksSection
                }

                if !viewModel.homeBundles.isEmpty {
                    collectionsSection
                }

                viewRegistryButton
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 120)
        }
        .scrollClipDisabled(false)
    }

    // MARK: Header

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("AURA")
                    .font(.system(size: 14, weight: .bold))
                    .tracking(2.4)
                    .foregroundStyle(WSRegistryPalette.gold)
            }

            Text("Curated for\nyour registry")
                .font(.system(size: 36, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineSpacing(2)

            Text("AI-powered recommendations based on your registry profile. Review and add the pieces that fit your event.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    // MARK: Context Banner

    var contextBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(WSRegistryPalette.sage)

            Text(viewModel.contextSummary)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.88))
                .lineSpacing(3)

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.sage.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(WSRegistryPalette.sage.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: Category Section

    func categorySection(_ section: RegistryRecommendationSection) -> some View {
        let sectionRecs = viewModel.recommendations(for: section)

        return VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(section.title.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(WSRegistryPalette.warmGray)

                Text(section.category)
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(sectionRecs) { rec in
                        recommendationCard(rec)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
    }

    var bulkActionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)

            HStack(spacing: 10) {
                Button {
                    viewModel.addTopEssentials()
                } label: {
                    quickAddLabel(
                        icon: "shippingbox",
                        title: viewModel.canAddTopEssentials() ? "Add Top 100 Essentials" : "Top Essentials Added",
                        subtitle: "Best-selling registry fundamentals"
                    )
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canAddTopEssentials())
                .opacity(viewModel.canAddTopEssentials() ? 1 : 0.55)

                Button {
                    viewModel.addPersonalizedSet()
                } label: {
                    quickAddLabel(
                        icon: "sparkles",
                        title: viewModel.canAddPersonalizedSet() ? "Add AI Personalized Set" : "AI Set Added",
                        subtitle: "Your full curated recommendation set"
                    )
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.canAddPersonalizedSet())
                .opacity(viewModel.canAddPersonalizedSet() ? 1 : 0.55)
            }
        }
    }

    func quickAddLabel(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.gold)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(2)
            Text(subtitle)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
    }

    // MARK: AI Individual Picks

    var aiPicksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.gold)
                    Text("AI PICKS FOR YOU")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.8)
                        .foregroundStyle(WSRegistryPalette.gold)
                }

                Text("Individual Recommendations")
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.recommendations.prefix(8)) { rec in
                        aiPickCard(rec)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
    }

    func aiPickCard(_ rec: RankedRecommendation) -> some View {
        let product = ProductItem(
            id: rec.product.id,
            name: rec.product.name,
            price: rec.product.effectivePrice,
            path: rec.product.imagePath,
            productType: rec.product.productType,
            brand: brandDisplayName(rec.product.brand)
        )
        let registryQty = registryRepo.currentRegistry?.items.first(where: { $0.id == product.id })?.quantity ?? 0

        return VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                CustomAsyncImage(url: product.imageURL)
                    .frame(width: 170, height: 170)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(rec.confidenceLabel.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(confidenceForeground(rec.confidenceLabel), in: Capsule())
                    .padding(8)
            }

            Text(product.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(2)
                .frame(width: 170, alignment: .leading)

            if let price = product.price {
                Text("$\(price, specifier: "%.2f")")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#C8102E"))
            }

            Text(rec.explanation)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineLimit(2)
                .frame(width: 170, alignment: .leading)

            Button {
                if registryQty > 0 {
                    viewModel.removeFromRegistry(rec)
                } else {
                    viewModel.addToRegistry(rec)
                }
            } label: {
                Text(registryQty > 0 ? "ADDED ✓" : "ADD TO REGISTRY")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(registryQty > 0 ? WSRegistryPalette.sage : WSRegistryPalette.espresso)
                    .frame(width: 170, height: 34)
                    .background(
                        registryQty > 0
                            ? WSRegistryPalette.sage.opacity(0.14)
                            : Color.clear,
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(
                                registryQty > 0 ? WSRegistryPalette.sage.opacity(0.4) : WSRegistryPalette.espresso.opacity(0.5),
                                lineWidth: 1
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Aesthetic Bundles (Home-Style)

    var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.gold)
                    Text("DESIGNED TOGETHER")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(1.8)
                        .foregroundStyle(WSRegistryPalette.gold)
                }

                Text("AI Aesthetic Bundles")
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.homeBundles) { bundle in
                        bundleCard(bundle)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    func bundleCard(_ bundle: HomeInspiredBundle) -> some View {
        let isAdded = viewModel.isCollectionAdded(bundle)
        let bundleProducts = viewModel.products(for: bundle)

        VStack(alignment: .leading, spacing: 0) {
            // 2×2 product image grid
            ZStack(alignment: .topTrailing) {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 2), GridItem(.flexible(), spacing: 2)],
                    spacing: 2
                ) {
                    ForEach(Array(bundleProducts.prefix(4).enumerated()), id: \.offset) { _, product in
                        if let path = product.imagePath {
                            CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + path))
                                .frame(height: 120)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(WSRegistryPalette.ivory)
                                .frame(height: 120)
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                // Match badge
                Text("\(bundle.compatibilityScore)% MATCH")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.5)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        LinearGradient(
                            colors: [WSRegistryPalette.gold, WSRegistryPalette.gold.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .padding(10)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(bundle.title)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(2)

                Text(bundle.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .lineLimit(2)

                // WHY THIS WORKS
                DisclosureGroup {
                    Text(bundle.aiReason)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.85))
                        .lineSpacing(3)
                        .padding(.top, 4)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                        Text("WHY THIS WORKS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.0)
                    }
                    .foregroundStyle(WSRegistryPalette.gold)
                }
                .tint(WSRegistryPalette.gold)

                Button {
                    viewModel.addCollection(bundle)
                } label: {
                    Text(isAdded ? "Bundle Added ✓" : "ADD BUNDLE")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.0)
                        .foregroundStyle(isAdded ? WSRegistryPalette.sage : WSRegistryPalette.cream)
                        .frame(maxWidth: .infinity, minHeight: 42)
                        .background(
                            isAdded
                                ? WSRegistryPalette.sage.opacity(0.16)
                                : WSRegistryPalette.espresso,
                            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
                .disabled(isAdded)
            }
            .padding(14)
        }
        .frame(width: 262)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.06), radius: 14, x: 0, y: 6)
    }

    // MARK: Product Card

    func recommendationCard(_ rec: RankedRecommendation) -> some View {
        let product = ProductItem(
            id: rec.product.id,
            name: rec.product.name,
            price: rec.product.effectivePrice,
            path: rec.product.imagePath,
            productType: rec.product.productType,
            brand: brandDisplayName(rec.product.brand)
        )
        let cartQty = cartRepo.items.first(where: { $0.id == product.id })?.quantity ?? 0
        let registryQty = registryRepo.currentRegistry?.items.first(where: { $0.id == product.id })?.quantity ?? 0

        return VStack(alignment: .leading, spacing: 6) {
            ProductCardView(
                product: product,
                quantity: cartQty,
                registryQuantity: registryQty,
                onAdd: { cartRepo.add(product: product) },
                onRemove: { cartRepo.remove(productId: product.id) },
                onAddToRegistry: { viewModel.addToRegistry(rec) },
                onRemoveFromRegistry: { viewModel.removeFromRegistry(rec) }
            )
            .frame(width: 170)

            HStack(spacing: 4) {
                Text(rec.confidenceLabel.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(confidenceForeground(rec.confidenceLabel), in: Capsule())
                Text(rec.explanation)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .lineLimit(2)
            }
            .frame(width: 170, alignment: .leading)
        }
    }

    // MARK: View Registry Button

    var viewRegistryButton: some View {
        Button {
            tabBarVM.resetRegistryFlow()
            tabBarVM.registryPath.append(RegistryRoute.details)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 20, weight: .semibold))
                Text("View Your Registry")
                    .font(.system(size: 17, weight: .semibold))
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(WSRegistryPalette.cream)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 60)
            .background(
                LinearGradient(
                    colors: [WSRegistryPalette.espresso, Color(red: 0.245, green: 0.165, blue: 0.110)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
            .shadow(color: WSRegistryPalette.espresso.opacity(0.18), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    // MARK: Loading State

    var loadingState: some View {
        VStack(spacing: 28) {
            Image(systemName: "sparkles")
                .font(.system(size: 38, weight: .regular))
                .foregroundStyle(WSRegistryPalette.gold.opacity(0.72))
                .symbolEffect(.pulse, options: .repeating.speed(0.5))

            VStack(spacing: 14) {
                Text("Curating your\nrecommendations...")
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .multilineTextAlignment(.center)

                Text("AURA is analyzing your preferences to find the right gifts for your registry.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .frame(maxWidth: 280)

            // Shimmer placeholders
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    shimmerCard
                }
            }
            .padding(.horizontal, 18)
        }
    }

    var shimmerCard: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(WSRegistryPalette.hairline.opacity(0.35))
                .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(WSRegistryPalette.hairline.opacity(0.35))
                    .frame(height: 14)
                    .frame(maxWidth: 160)

                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(WSRegistryPalette.hairline.opacity(0.25))
                    .frame(height: 12)
                    .frame(maxWidth: 120)
            }
            Spacer()
        }
        .padding(16)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
    }

    // MARK: Error State

    func errorState(_ message: String) -> some View {
        VStack(spacing: 22) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(WSRegistryPalette.warmGray)

            Text(message)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(WSRegistryPalette.cocoa)
                .multilineTextAlignment(.center)

            Button {
                Task { await viewModel.loadRecommendations() }
            } label: {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cream)
                    .padding(.horizontal, 32)
                    .frame(height: 48)
                    .background(WSRegistryPalette.espresso, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(40)
    }

    // MARK: Helpers

    func brandDisplayName(_ brand: WSIBrand) -> String {
        switch brand {
        case .williamsSonoma: return "Williams Sonoma"
        case .potteryBarn: return "Pottery Barn"
        case .westElm: return "West Elm"
        case .rejuvenation: return "Rejuvenation"
        case .markAndGraham: return "Mark & Graham"
        case .greenRow: return "GreenRow"
        case .unknown: return "WSI"
        }
    }

    func confidenceForeground(_ label: String) -> Color {
        switch label {
        case "High": return WSRegistryPalette.sage
        case "Medium": return WSRegistryPalette.gold
        default: return WSRegistryPalette.warmGray
        }
    }
}

#Preview {
    NavigationStack {
        AURARecommendationReviewView(
            payload: RegistryQuestionnairePayload(
                registryID: UUID(),
                createdAt: Date(),
                selections: [
                    .answered(.homeVision, values: ["warm-cozy"]),
                    .answered(.productCategories, values: ["cookware-bakeware", "dinnerware-serveware"]),
                    .answered(.budgetPreference, values: ["$50-to-$150"])
                ]
            ),
            registryRepo: nil
        )
    }
}
