import SwiftUI

// MARK: - Filter Model

private enum InsightFilter: String, CaseIterable, Identifiable {
    // Budget
    case under5k        = "Under ₹5,000"
    case mid            = "₹5,000–₹20,000"
    case premium        = "Premium Gifts"
    // Category
    case dining         = "Dining"
    case hosting        = "Hosting"
    case bath           = "Bath"
    case bedding        = "Bedding"
    case kitchen        = "Kitchen Essentials"

    var id: String { rawValue }

    var icon: String? {
        switch self {
        case .dining:   return "fork.knife"
        case .hosting:  return "wineglass"
        case .bath:     return "drop"
        case .bedding:  return "bed.double"
        case .kitchen:  return "frying.pan"
        default:        return nil
        }
    }

    var isBudget: Bool {
        switch self { case .under5k, .mid, .premium: return true; default: return false }
    }
}

// MARK: - Insight Card Model

private struct InsightCard: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let filters: Set<InsightFilter>           // which filters surface this card
    let destination: InsightDestination
}

private enum InsightDestination {
    case completeCollection(collectionName: String)
    case groupGift
    case kitchenEssentials
    case hostingCollection
}

// MARK: - Main View

struct RegistryAIInsightsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var registryRepo: RegistryRepository

    @State private var selectedFilters: Set<InsightFilter> = []
    @State private var navigateToCollection: String? = nil
    @State private var showCollectionView = false

    // All insight cards with their filter tags
    private let allCards: [InsightCard] = [
        InsightCard(
            icon: "sparkles",
            title: "Help complete their almost-finished dining collection",
            subtitle: "Only 2 items left in the Citron Collection.",
            color: WSRegistryPalette.gold,
            filters: [.dining, .mid],
            destination: .completeCollection(collectionName: "Citron Dining Collection")
        ),
        InsightCard(
            icon: "person.3.fill",
            title: "4 friends are contributing to the espresso machine",
            subtitle: "Join the group gift to reach the goal.",
            color: WSRegistryPalette.sage,
            filters: [.kitchen, .premium],
            destination: .groupGift
        ),
        InsightCard(
            icon: "house.fill",
            title: "The couple prioritized everyday kitchen essentials",
            subtitle: "They selected 12 items for daily cooking.",
            color: WSRegistryPalette.cocoa,
            filters: [.kitchen, .under5k, .mid],
            destination: .kitchenEssentials
        ),
        InsightCard(
            icon: "heart.text.square.fill",
            title: "This hosting collection is 82% complete",
            subtitle: "Add the final touches for their first dinner party.",
            color: WSRegistryPalette.espresso,
            filters: [.hosting, .mid],
            destination: .hostingCollection
        ),
    ]

    private var visibleCards: [InsightCard] {
        guard !selectedFilters.isEmpty else { return allCards }

        // Budget and category filters work together:
        // A card is shown if it matches ALL selected filter groups (AND between groups, OR within same group)
        let selectedBudget  = selectedFilters.filter { $0.isBudget }
        let selectedCat     = selectedFilters.filter { !$0.isBudget }

        return allCards.filter { card in
            let budgetOK = selectedBudget.isEmpty || !selectedBudget.isDisjoint(with: card.filters)
            let catOK    = selectedCat.isEmpty    || !selectedCat.isDisjoint(with: card.filters)
            return budgetOK && catOK
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                WSRegistryPalette.porcelain.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {

                        Text("Discover meaningful ways to help them build their home.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        // SECTION 1 - SMART FILTERS
                        smartFiltersSection

                        // SECTION 2 - CURATED RECOMMENDATIONS (filtered)
                        aiRecommendationsSection

                        // SECTION 3 - QUICK ACTIONS
                        quickActionCardsSection
                    }
                    .padding(.bottom, 40)
                }

                // Hidden NavigationLink for programmatic push
                NavigationLink(
                    destination: Group {
                        if let name = navigateToCollection {
                            HelpCompleteCollectionView(collectionName: name, registryItems: itemsFor(collectionName: name))
                        }
                    },
                    isActive: $showCollectionView
                ) { EmptyView() }
                .hidden()
            }
            .navigationTitle("AI Registry Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.6))
                    }
                }
            }
        }
    }

    // MARK: - Helper: items for a given collection name
    private func itemsFor(collectionName: String) -> [RegistryItem] {
        // Search the registry for items matching the collection name
        let registryItems = registryRepo.currentRegistry?.items
            .filter { ($0.collectionName ?? "").localizedCaseInsensitiveContains(collectionName) } ?? []

        // Also include items whose pattern or name hints at the collection if registry is empty
        if !registryItems.isEmpty { return registryItems }

        // Fallback: all registry items (so the page is never blank)
        return registryRepo.currentRegistry?.items ?? []
    }

    // MARK: - Section 1: Smart Filters

    private var smartFiltersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Explore by")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cocoa)

                Spacer()

                if !selectedFilters.isEmpty {
                    Button("Clear") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedFilters.removeAll()
                        }
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.gold)
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    // Budget Row
                    HStack(spacing: 10) {
                        ForEach([InsightFilter.under5k, .mid, .premium]) { f in
                            filterChip(f)
                        }
                    }
                    // Category Row
                    HStack(spacing: 10) {
                        ForEach([InsightFilter.dining, .hosting, .bath, .bedding, .kitchen]) { f in
                            filterChip(f)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func filterChip(_ filter: InsightFilter) -> some View {
        let isSelected = selectedFilters.contains(filter)
        return Button {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.78)) {
                if isSelected {
                    selectedFilters.remove(filter)
                } else {
                    selectedFilters.insert(filter)
                }
            }
        } label: {
            HStack(spacing: 6) {
                if let icon = filter.icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(filter.rawValue)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isSelected ? WSRegistryPalette.cream : WSRegistryPalette.espresso)
            .padding(.horizontal, 16)
            .frame(height: 38)
            .background(isSelected ? WSRegistryPalette.espresso : WSRegistryPalette.ivory)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isSelected ? WSRegistryPalette.espresso : WSRegistryPalette.hairline, lineWidth: 1))
            .shadow(color: isSelected ? WSRegistryPalette.espresso.opacity(0.15) : .clear, radius: 6, x: 0, y: 3)
        }
    }

    // MARK: - Section 2: Curated Recommendations

    private var aiRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Curated for You")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cocoa)

                if !selectedFilters.isEmpty {
                    Text("· \(visibleCards.count) results")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                }
            }
            .padding(.horizontal, 20)

            if visibleCards.isEmpty {
                emptyFilterState
            } else {
                VStack(spacing: 12) {
                    ForEach(visibleCards) { card in
                        insightRow(card)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }
                }
                .padding(.horizontal, 20)
                .animation(.spring(response: 0.35, dampingFraction: 0.82), value: visibleCards.map { $0.id })
            }
        }
    }

    private func insightRow(_ card: InsightCard) -> some View {
        Group {
            switch card.destination {
            case .completeCollection(let name):
                NavigationLink(destination: HelpCompleteCollectionView(
                    collectionName: name,
                    registryItems: itemsFor(collectionName: name)
                )) {
                    insightRowContent(card)
                }
                .buttonStyle(.plain)

            case .groupGift:
                NavigationLink(destination: GroupGiftDetailView()) {
                    insightRowContent(card)
                }
                .buttonStyle(.plain)

            case .kitchenEssentials:
                NavigationLink(destination: HelpCompleteCollectionView(
                    collectionName: "Daily Cooking",
                    registryItems: itemsFor(collectionName: "Daily Cooking")
                )) {
                    insightRowContent(card)
                }
                .buttonStyle(.plain)

            case .hostingCollection:
                NavigationLink(destination: HelpCompleteCollectionView(
                    collectionName: "Hosting",
                    registryItems: itemsFor(collectionName: "Hosting")
                )) {
                    insightRowContent(card)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func insightRowContent(_ card: InsightCard) -> some View {
        HStack(spacing: 16) {
            Image(systemName: card.icon)
                .font(.system(size: 20))
                .foregroundStyle(card.color)
                .frame(width: 44, height: 44)
                .background(card.color.opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(card.subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(WSRegistryPalette.hairline)
        }
        .padding(16)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
        .shadow(color: WSRegistryPalette.espresso.opacity(0.02), radius: 5, x: 0, y: 2)
    }

    private var emptyFilterState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles.slash")
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.5))
            Text("No insights match your filters.")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
            Button("Clear Filters") {
                withAnimation { selectedFilters.removeAll() }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(WSRegistryPalette.gold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - Section 3: Quick Actions

    private var quickActionCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ways to Give")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.cocoa)
                .padding(.horizontal, 20)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                // Complete Collection → navigates to HelpCompleteCollectionView
                NavigationLink(destination: HelpCompleteCollectionView(
                    collectionName: "Citron Dining Collection",
                    registryItems: itemsFor(collectionName: "Citron Dining Collection")
                )) {
                    quickActionCardContent(title: "Complete Collection", icon: "tray.full", color: WSRegistryPalette.gold)
                }
                .buttonStyle(.plain)

                // Join Group Gift → GroupGiftDetailView
                NavigationLink(destination: GroupGiftDetailView()) {
                    quickActionCardContent(title: "Join Group Gift", icon: "gift", color: WSRegistryPalette.espresso)
                }
                .buttonStyle(.plain)

                // Celebration Pool → CelebrationPoolFlowView
                NavigationLink(destination: CelebrationPoolFlowView()) {
                    quickActionCardContent(title: "Celebration Pool", icon: "heart", color: WSRegistryPalette.cocoa)
                }
                .buttonStyle(.plain)

                // Priority Gifts → Daily Cooking collection
                NavigationLink(destination: HelpCompleteCollectionView(
                    collectionName: "Daily Cooking",
                    registryItems: itemsFor(collectionName: "Daily Cooking")
                )) {
                    quickActionCardContent(title: "Priority Gifts", icon: "star", color: WSRegistryPalette.warmGray)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
        }
    }

    private func quickActionCardContent(title: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
    }
}
