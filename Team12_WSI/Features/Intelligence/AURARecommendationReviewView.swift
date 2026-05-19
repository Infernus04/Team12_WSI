import SwiftUI

// MARK: - AURA Recommendation Review View

struct AURARecommendationReviewView: View {
    @StateObject private var viewModel: AURARecommendationReviewViewModel
    @State private var showMinimalHeader = false
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
                minimalHeader
                bulkActionsCard

                if !viewModel.recommendations.isEmpty {
                    aiPicksSection
                }

                if !viewModel.homeBundles.isEmpty {
                    collectionsSection
                }

                ForEach(viewModel.sections) { section in
                    categorySection(section)
                }

                viewRegistryButton
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 120)
        }
        .scrollClipDisabled(false)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showMinimalHeader = true
            }
        }
    }

    // MARK: Header

    var minimalHeader: some View {
        VStack(spacing: 10) {
            Text("Made uniquely for you")
                .font(.system(size: 32, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Text("A personalized registry curated around your style, vibe, and lifestyle.")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.top, 40)
        .padding(.bottom, 24)
        .opacity(showMinimalHeader ? 1 : 0)
        .offset(y: showMinimalHeader ? 0 : 8)
    }

    // MARK: Category Section

    func categorySection(_ section: RegistryRecommendationSection) -> some View {
        let sectionRecs = viewModel.recommendations(for: section)

        return VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(section.title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2.2)
                    .foregroundStyle(WSRegistryPalette.warmGray)

                Text(section.category)
                    .font(.system(size: 26, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
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
                .buttonStyle(PremiumPressButtonStyle())
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
                .buttonStyle(PremiumPressButtonStyle())
                .disabled(!viewModel.canAddPersonalizedSet())
                .opacity(viewModel.canAddPersonalizedSet() ? 1 : 0.55)
            }
        }
        .padding(18)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.06), radius: 20, x: 0, y: 10)
    }

    func quickAddLabel(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
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
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
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

                Text("AI Picks For You")
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)

                Text("Selected individually based on your registry vibe.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.recommendations.prefix(8)) { rec in
                        aiPickCard(rec)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
            .scrollTargetBehavior(.viewAligned)
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

        return VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                CustomAsyncImage(url: product.imageURL)
                    .frame(width: 200, height: 200)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

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
                .frame(width: 200, alignment: .leading)

            HStack(spacing: 6) {
                ForEach(viewModel.vibeTags(for: rec), id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(WSRegistryPalette.ivory, in: Capsule())
                }
            }
            .frame(width: 200, alignment: .leading)

            if let price = product.price {
                Text("$\(price, specifier: "%.2f")")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color(hex: "#C8102E"))
            }

            DisclosureGroup {
                Text(rec.explanation)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .lineSpacing(2)
                    .frame(width: 200, alignment: .leading)
                    .padding(.top, 4)
            } label: {
                Text("Why this pick?")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.gold)
            }
            .tint(WSRegistryPalette.gold)

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
                    .frame(width: 200, height: 34)
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
        .padding(12)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
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

                Text("Curated collections designed around a complete aesthetic.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewModel.homeBundles) { bundle in
                        bundleCard(bundle)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }

    @ViewBuilder
    func bundleCard(_ bundle: HomeInspiredBundle) -> some View {
        let isAdded = viewModel.isCollectionAdded(bundle)
        let bundleProducts = viewModel.products(for: bundle)
        let heroPath = bundleProducts.first?.imagePath

        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                if let heroPath {
                    CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + heroPath))
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(WSRegistryPalette.ivory)
                        .frame(height: 220)
                }

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.72)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 220)

                VStack(alignment: .leading, spacing: 8) {
                    Text(bundle.title)
                        .font(.system(size: 24, weight: .regular, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text(bundle.description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.88))
                        .lineLimit(2)
                }
                .padding(16)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    badge("\(bundle.compatibilityScore)% Match")
                    badge("\(bundle.productCount) Items")
                    badge("$\(String(format: "%.0f", bundle.estimatedTotal))")
                }

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
                        Text("WHY THIS BUNDLE")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.0)
                    }
                    .foregroundStyle(WSRegistryPalette.gold)
                }
                .tint(WSRegistryPalette.gold)

                HStack(spacing: 10) {
                    Button {
                        tabBarVM.registryPath.append(RegistryRoute.categoryProducts(bundle.title))
                    } label: {
                        Text("Preview Collection")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.espresso)
                            .frame(maxWidth: .infinity, minHeight: 42)
                            .background(Color.clear, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(WSRegistryPalette.espresso.opacity(0.55), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PremiumPressButtonStyle())

                    Button {
                        viewModel.addCollection(bundle)
                    } label: {
                        Text(isAdded ? "Bundle Added ✓" : "Add Entire Bundle")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(isAdded ? WSRegistryPalette.sage : WSRegistryPalette.cream)
                            .frame(maxWidth: .infinity, minHeight: 42)
                            .background(
                                isAdded
                                    ? WSRegistryPalette.sage.opacity(0.16)
                                    : WSRegistryPalette.espresso,
                                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                            )
                    }
                    .buttonStyle(PremiumPressButtonStyle())
                    .disabled(isAdded)
                }
            }
            .padding(16)
        }
        .frame(width: UIScreen.main.bounds.width - 36)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.08), radius: 18, x: 0, y: 8)
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
        let registryQty = registryRepo.currentRegistry?.items.first(where: { $0.id == product.id })?.quantity ?? 0

        return VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                CustomAsyncImage(url: product.imageURL)
                    .frame(width: 170, height: 170)
                    .scaledToFill()
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
                Text(registryQty > 0 ? "ADDED \u{2713}" : "ADD TO REGISTRY")
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

    func badge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(WSRegistryPalette.espresso)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(WSRegistryPalette.ivory, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(WSRegistryPalette.hairline.opacity(0.35), lineWidth: 1)
            )
    }
}

private struct PremiumPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
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
