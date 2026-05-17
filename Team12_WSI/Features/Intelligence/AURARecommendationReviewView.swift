import SwiftUI

// MARK: - AURA Recommendation Review View

struct AURARecommendationReviewView: View {
    @StateObject private var viewModel: AURARecommendationReviewViewModel
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

                if !viewModel.collectionBundles.isEmpty {
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

            Text("AI-powered recommendations based on your home profile. Review and add the pieces that speak to you.")
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
        .background(WSRegistryPalette.sage.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                        title: "Add Top 100 Essentials",
                        subtitle: "Best-selling registry fundamentals"
                    )
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.addPersonalizedSet()
                } label: {
                    quickAddLabel(
                        icon: "sparkles",
                        title: "Add AI Personalized Set",
                        subtitle: "Your full curated recommendation set"
                    )
                }
                .buttonStyle(.plain)
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

    var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Collections")
                .font(.system(size: 24, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)

            ForEach(viewModel.collectionBundles) { bundle in
                let isAdded = viewModel.isCollectionAdded(bundle)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(bundle.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.espresso)
                        Text(bundle.subtitle)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                        Text("\(bundle.productIDs.count) items")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.85))
                    }
                    Spacer()
                    Button {
                        viewModel.addCollection(bundle)
                    } label: {
                        Text(isAdded ? "Added" : "Add Set")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(isAdded ? WSRegistryPalette.sage : WSRegistryPalette.cream)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                isAdded ? WSRegistryPalette.sage.opacity(0.16) : WSRegistryPalette.espresso,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isAdded)
                }
                .padding(12)
                .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
                )
            }
        }
    }

    // MARK: Product Card

    func recommendationCard(_ rec: RankedRecommendation) -> some View {
        let isAdded = viewModel.isAdded(rec)

        return VStack(alignment: .leading, spacing: 10) {
            // Image
            ZStack(alignment: .topTrailing) {
                CustomAsyncImage(url: productImageURL(rec.product))
                    .frame(width: 172, height: 172)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                // Confidence badge
                Text(rec.confidenceLabel)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(confidenceForeground(rec.confidenceLabel))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(confidenceBackground(rec.confidenceLabel), in: Capsule())
                    .padding(8)
            }

            // Brand
            Text(brandDisplayName(rec.product.brand))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(1)

            // Name
            Text(rec.product.name)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.88))
                .lineLimit(2)
                .frame(height: 36, alignment: .top)

            // Price
            Text(formatPrice(rec.product.effectivePrice))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(WSRegistryPalette.espresso)

            // Rationale
            Text(rec.explanation)
                .font(.system(size: 12, weight: .regular))
                .italic()
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineLimit(2)
                .frame(height: 30, alignment: .top)

            // Add button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    viewModel.addToRegistry(rec)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isAdded ? "checkmark" : "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text(isAdded ? "Added" : "Add to Registry")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(isAdded ? WSRegistryPalette.sage : WSRegistryPalette.cream)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(
                    isAdded
                        ? WSRegistryPalette.sage.opacity(0.15)
                        : WSRegistryPalette.espresso,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isAdded ? WSRegistryPalette.sage.opacity(0.35) : Color.clear, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(isAdded)
        }
        .frame(width: 172)
        .padding(12)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.48), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.06), radius: 14, x: 0, y: 8)
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
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
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

                Text("AURA is analyzing your preferences to find the perfect pieces for your home.")
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
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(WSRegistryPalette.hairline.opacity(0.35))
                .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(WSRegistryPalette.hairline.opacity(0.35))
                    .frame(height: 14)
                    .frame(maxWidth: 160)

                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(WSRegistryPalette.hairline.opacity(0.25))
                    .frame(height: 12)
                    .frame(maxWidth: 120)
            }
            Spacer()
        }
        .padding(16)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                    .background(WSRegistryPalette.espresso, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(40)
    }

    // MARK: Helpers

    func productImageURL(_ product: CatalogProduct) -> URL? {
        guard let path = product.imagePath else { return nil }
        return URL(string: AppConstants.API.imageBasePath + path)
    }

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

    func formatPrice(_ price: Double) -> String {
        price.formatted(.currency(code: "USD"))
    }

    func confidenceForeground(_ label: String) -> Color {
        switch label {
        case "High": return WSRegistryPalette.sage
        case "Medium": return WSRegistryPalette.gold
        default: return WSRegistryPalette.warmGray
        }
    }

    func confidenceBackground(_ label: String) -> Color {
        switch label {
        case "High": return WSRegistryPalette.sage.opacity(0.18)
        case "Medium": return WSRegistryPalette.gold.opacity(0.18)
        default: return WSRegistryPalette.porcelain.opacity(0.92)
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
