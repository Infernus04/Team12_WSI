//
//  RegistryView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI
import UIKit

enum RegistryRoute: Hashable {
    case create
    case success
    case details
    case findRegistry
    case pastRegistries
    case existingRegistryDetails(UUID)
    case categoryProducts(String)
    case recommendations(RegistryQuestionnairePayload)
    case bundlePreview(bundleID: String)
    case allProducts
    case chronicle
    case activity
    case registryInsights
}

private enum RegistryOrigin: String, Hashable {
    case own = "Mine"
    case participated = "Participated"
}

enum WSRegistryPalette {
    static let ivory = Color.wsWarmIvory
    static let cream = Color.wsSurface
    static let porcelain = Color.wsSurface
    static let espresso = Color.wsCharcoal
    static let cocoa = Color.wsSecondary
    static let gold = Color.wsMutedBrass
    static let sage = Color(hex: "#6F8768")
    static let warmGray = Color.wsSecondary
    static let hairline = Color.wsDivider
}

struct RegistryView: View {

    @StateObject private var viewModel = RegistryViewModel()

    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel

    @State private var s1On = false
    @State private var s2On = false
    @State private var s3On = false
    @State private var s4On = false
    @State private var showActivitySheet = false
    @State private var showReceiverFlowDemo = false
    /// Flag set when the user completes gifting and taps "Continue Browsing".
    /// Checked in onDismiss of the receiver flow to present Browse Registry cleanly.
    @State private var pendingBrowseAfterGifting = false
    /// Controls the Browse Registry fullScreenCover (presented from RegistryView root).
    @State private var showBrowseRegistryFromRoot = false
    @State private var registryToDelete: Registry?
    @State private var showDeleteRegistryDialog = false

    var body: some View {
        NavigationStack(path: $tabBarVM.registryPath) {
            ZStack {
                WSRegistryPalette.ivory
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        headerSection
                            .opacity(s1On ? 1 : 0).offset(y: s1On ? 0 : 16)
                            .onAppear { withAnimation(.easeOut(duration: 0.5)) { s1On = true } }

                        createRegistryButton
                            .opacity(s2On ? 1 : 0).offset(y: s2On ? 0 : 20)
                            .onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.1)) { s2On = true } }

                        if viewModel.hasRegistry {
                            currentRegistriesSection
                                .opacity(s3On ? 1 : 0).offset(y: s3On ? 0 : 20)
                                .onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.15)) { s3On = true } }
                        }

                        secondaryActions
                            .opacity(s4On ? 1 : 0).offset(y: s4On ? 0 : 20)
                            .onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.2)) { s4On = true } }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 116)
                }
                .scrollClipDisabled(false)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showActivitySheet = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(WSRegistryPalette.espresso)
                                .frame(width: 34, height: 34)
                                .background(WSRegistryPalette.porcelain, in: Circle())
                                .overlay(
                                    Circle()
                                        .stroke(WSRegistryPalette.hairline.opacity(0.55), lineWidth: 1)
                                )

                            if !registryRepo.activities.isEmpty {
                                Circle()
                                    .fill(WSRegistryPalette.gold)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 0, y: -2)
                            }
                        }
                    }
                    .accessibilityLabel("Activity")
                }

                ToolbarItem(placement: .principal) {
                    Text("REGISTRY")
                        .font(.system(size: 15, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(WSRegistryPalette.espresso)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    AsyncImage(url: URL(string: "https://randomuser.me/api/portraits/women/44.jpg")) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.3))
                        }
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(WSRegistryPalette.hairline, lineWidth: 1))
                }
            }
            .sheet(isPresented: $showActivitySheet) {
                NavigationStack {
                    RegistryActivityView()
                        .environmentObject(registryRepo)
                }
            }
            .navigationDestination(for: RegistryRoute.self) { route in
                switch route {
                case .create:
                    CreateRegistryView()
                case .success:
                    RegistrySuccessView()
                case .details:
                    RegistryDetailsView()
                case .findRegistry:
                    FindRegistryView()
                case .pastRegistries:
                    PastRegistriesView()
                case .existingRegistryDetails(let registryID):
                    ExistingRegistryDetailsView(registry: ExistingRegistry.lookup(registryID, ownedRegistries: registryRepo.registries))
                case .categoryProducts(let title):
                    RegistryCategoryProductsView(sectionTitle: title)
                case .recommendations(let payload):
                    AURARecommendationReviewView(payload: payload, registryRepo: registryRepo)
                case .bundlePreview(let bundleID):
                    BundlePreviewView(bundleID: bundleID)
                case .allProducts:
                    AllRegistryProductsView()
                case .chronicle:
                    HomeChronicleView()
                case .activity:
                    RegistryActivityView()
                case .registryInsights:
                    if let currentRegistry = registryRepo.currentRegistry {
                        OwnerRegistryInsightsView(registry: currentRegistry)
                    }
                }
            }
        }
        // TEMP DEMO ENTRY POINT FOR RECEIVER FLOW
        .fullScreenCover(isPresented: $showReceiverFlowDemo, onDismiss: {
            // Called after the RegistryLandingView fullScreenCover has fully animated away.
            // If the user completed gifting and tapped "Continue Browsing", open Browse
            // Registry cleanly from RegistryView — no stacked covers, clean back navigation.
            if pendingBrowseAfterGifting {
                pendingBrowseAfterGifting = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showBrowseRegistryFromRoot = true
                }
            }
        }) {
            NavigationView {
                RegistryLandingView()
                    .environmentObject(registryRepo)
            }
        }
        // Browse Registry presented cleanly from RegistryView (root level).
        // Back chevron dismisses this → returns to RegistryView (the owner tab).
        .fullScreenCover(isPresented: $showBrowseRegistryFromRoot) {
            NavigationView {
                RegistryProductListView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenBrowseRegistryFromRoot"))) { _ in
            // Step 1: Flag that Browse Registry should open after the receiver cover dismisses.
            pendingBrowseAfterGifting = true
            // Step 2: Dismiss the receiver landing flow (RegistryLandingView fullScreenCover).
            // This triggers the onDismiss callback above after the animation completes.
            showReceiverFlowDemo = false
        }
        .onAppear {
            viewModel.bind(repository: registryRepo)
        }
        .confirmationDialog(
            "Delete Registry?",
            isPresented: $showDeleteRegistryDialog,
            presenting: registryToDelete
        ) { registry in
            Button("Delete Registry", role: .destructive) {
                registryRepo.deleteRegistry(id: registry.id)
                registryToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                registryToDelete = nil
            }
        } message: { registry in
            Text("This will remove \"\(registry.displayName)\" from your registries.")
        }
    }
}

private extension RegistryView {
    var headerSection: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("Create, manage, and share registries\nfor every milestone.")
                .font(.wsSerif(size: 17))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }

    // MARK: - Create Registry Button

    var createRegistryButton: some View {
        Button {
            tabBarVM.registryPath.append(RegistryRoute.create)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .background(Circle().fill(Color.black.opacity(0.2)).frame(width: 24, height: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Create New Registry")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Start a registry for a wedding, housewarming, or more")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, minHeight: 74, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [WSRegistryPalette.espresso, Color(red: 0.35, green: 0.25, blue: 0.20)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .shadow(color: WSRegistryPalette.espresso.opacity(0.25), radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Current Registries (Horizontal Scroll)

    var currentRegistriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "list.clipboard")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.gold)
                    Text("Manage My Registry")
                        .font(.wsSerif(size: 22, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }
                Spacer()
                Text("\(registryRepo.registries.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.warmGray)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(registryRepo.registries.sorted(by: { $0.date > $1.date })) { registry in
                        registryHorizontalCard(registry)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
        }
    }

    func registryHorizontalCard(_ registry: Registry) -> some View {
        let items = registry.items
        let isActive = registryRepo.activeRegistryID == registry.id

        return Button {
            registryRepo.selectRegistry(id: registry.id)
            tabBarVM.registryPath.append(RegistryRoute.details)
        } label: {
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let data = registry.coverImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image("giftdna_living_room")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 280, height: 190)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.1), WSRegistryPalette.espresso.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                VStack(alignment: .leading, spacing: 10) {
                    if isActive {
                        Text("ACTIVE")
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(1.5)
                            .foregroundStyle(WSRegistryPalette.espresso)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(WSRegistryPalette.gold.opacity(0.9), in: Capsule())
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(registry.displayName)
                            .font(.wsSerif(size: 20, weight: .bold))
                            .foregroundStyle(WSRegistryPalette.ivory)
                            .lineLimit(2)

                        Text(registry.event.rawValue + " • " + registry.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(WSRegistryPalette.ivory.opacity(0.85))
                    }

                    HStack(spacing: 16) {
                        registryHeroStat(value: "\(RegistryDetailContent.totalItems(from: items))", label: "Items")
                        Rectangle()
                            .fill(WSRegistryPalette.ivory.opacity(0.4))
                            .frame(width: 1, height: 24)
                        registryHeroStat(value: "\(RegistryDetailContent.collectionCount(from: items))", label: "Collections")
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .frame(width: 280, height: 190)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: WSRegistryPalette.espresso.opacity(0.2), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                registryToDelete = registry
                showDeleteRegistryDialog = true
            } label: {
                Label("Delete Registry", systemImage: "trash")
            }
        }
    }

    func registryHeroStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    // MARK: - Recent Activity Feed

    var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.gold)
                    Text("Recent Activity")
                        .font(.wsSerif(size: 20, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }
                Spacer()
                Button {
                    tabBarVM.registryPath.append(RegistryRoute.activity)
                } label: {
                    Text("View All")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.gold)
                }
            }

            VStack(spacing: 0) {
                ForEach(Array(registryRepo.activities.prefix(5).enumerated()), id: \.element.id) { index, activity in
                    activityFeedRow(activity, isLast: index == min(4, registryRepo.activities.count - 1))
                }
            }
            .padding(14)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1)
            )
            .shadow(color: WSRegistryPalette.espresso.opacity(0.03), radius: 12, x: 0, y: 5)
        }
    }

    func activityFeedRow(_ activity: RegistryActivity, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(activity.type.accentColor.opacity(0.18))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Image(systemName: activity.type.systemImage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(activity.type.accentColor)
                    )
                if !isLast {
                    Rectangle()
                        .fill(WSRegistryPalette.hairline.opacity(0.45))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(activity.productName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(activity.relativeTimeText)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                }
                Text(activity.detail)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.82))
                    .lineLimit(1)
            }
            .padding(.bottom, isLast ? 0 : 14)
        }
    }

    func statPill(value: String, label: String) -> some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.wsLabel(size: 10))
                .foregroundStyle(WSRegistryPalette.espresso)
            Text(label.uppercased())
                .font(.wsLabel(size: 9))
                .foregroundStyle(WSRegistryPalette.warmGray)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
    }

    func registrySummaryRow(_ item: RegistrySummaryItem) -> some View {
        Button {
        } label: {
            HStack(spacing: 13) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(item.tint)
                    .frame(width: 50, height: 50)
                    .background(item.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 2, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(1)
                        .minimumScaleFactor(0.86)

                    Text(item.subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.82))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Text(item.status)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(item.tint)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
                    .padding(.horizontal, 10)
                    .frame(width: 74, height: 32)
                    .background(item.tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 2, style: .continuous))

            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    var secondaryActions: some View {
        VStack(spacing: 12) {
            actionRow(
                icon: "magnifyingglass",
                title: "Find Other Registries",
                subtitle: "Search by name or email"
            ) {
                tabBarVM.registryPath.append(RegistryRoute.findRegistry)
            }

            actionRow(
                icon: "clock.arrow.circlepath",
                title: "Past Registries",
                subtitle: "Registries you created or participated in"
            ) {
                tabBarVM.registryPath.append(RegistryRoute.pastRegistries)
            }

            actionRow(
                icon: "gift",
                title: "Trial Registries",
                subtitle: "Explore and try creating a registry"
            ) {
                registryRepo.prepareTrialDemoRegistry()
                showReceiverFlowDemo = true
            }
        }
    }

    func actionRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .lineLimit(2)
                }

                Spacer(minLength: 10)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.7))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}


private struct ExistingRegistry: Identifiable, Hashable {
    let id: UUID
    let coupleName: String
    let email: String
    let relationship: RegistryRelationship
    let origin: RegistryOrigin
    let event: String
    let eventDate: String
    let shortDate: String
    let message: String
    let about: String
    let status: String
    let stats: [RegistryStat]
    let products: [RegistryDisplayProduct]
    let contributions: [RegistryContribution]

    var itemCount: String { stats.first(where: { $0.label == "Items" })?.value ?? "0" }
    var purchasedCount: String { stats.first(where: { $0.label == "Purchased" })?.value ?? "0" }
    var fulfilledText: String { stats.first(where: { $0.label == "Fulfilled" })?.value ?? "-" }
    var contributionsCountText: String { "\(contributions.count) gift\(contributions.count == 1 ? "" : "s")" }
    var featuredProductsText: String { "\(products.count) products" }
    var topContributionDetail: String { contributions.first?.detail ?? "No recent contributions yet" }
    var topContributionTime: String { contributions.first?.time ?? "—" }

    static let gayatri = ExistingRegistry(
        id: UUID(),
        coupleName: "Priya & Arjun",
        email: "priya.arjun@example.com",
        relationship: .friends,
        origin: .participated,
        event: "Wedding",
        eventDate: "August 24, 2024",
        shortDate: "Aug 24, 2024",
        message: "Thank you so much for being part of our special day and helping us build our future together. We are creating a warm home filled with love, good food, and unforgettable memories.",
        about: "We love hosting family and friends, trying new recipes, and creating a cozy home filled with laughter, good food, and great memories.",
        status: "Completed",
        stats: [
            RegistryStat(value: "86", label: "Items"),
            RegistryStat(value: "18", label: "Purchased"),
            RegistryStat(value: "100%", label: "Fulfilled"),
            RegistryStat(value: "Aug 24, 2024", label: "Event Date")
        ],
        products: Array(RegistryDetailSection.samples.flatMap(\.products).prefix(3)),
        contributions: [
            RegistryContribution(name: "Olivia Johnson", detail: "Contributed to Kitchen Essentials", time: "2d ago"),
            RegistryContribution(name: "William Anderson", detail: "Purchased Le Creuset Dutch Oven", time: "5d ago")
        ]
    )

    static let pastSamples: [ExistingRegistry] = [
        .gayatri,
        ExistingRegistry(
            id: UUID(),
            coupleName: "Priya’s Housewarming",
            email: "priya.housewarming@example.com",
            relationship: .family,
            origin: .participated,
            event: "Housewarming",
            eventDate: "January 15, 2023",
            shortDate: "Jan 15, 2023",
            message: "Thank you for helping make this new space feel like home.",
            about: "A cozy first home built around cooking, quiet evenings, and hosting close friends.",
            status: "Completed",
            stats: [RegistryStat(value: "42", label: "Items"), RegistryStat(value: "29", label: "Purchased"), RegistryStat(value: "100%", label: "Fulfilled"), RegistryStat(value: "Jan 15, 2023", label: "Event Date")],
            products: Array(RegistryDetailSection.samples.flatMap(\.products).prefix(3)),
            contributions: []
        ),
        ExistingRegistry(
            id: UUID(),
            coupleName: "Engagement Celebration",
            email: "engagement@example.com",
            relationship: .friends,
            origin: .participated,
            event: "Special Occasion",
            eventDate: "May 10, 2022",
            shortDate: "May 10, 2022",
            message: "We are grateful for every note, gift, and moment shared with us.",
            about: "A simple celebration with friends, fresh flowers, and pieces for a future home.",
            status: "Completed",
            stats: [RegistryStat(value: "28", label: "Items"), RegistryStat(value: "20", label: "Purchased"), RegistryStat(value: "100%", label: "Fulfilled"), RegistryStat(value: "May 10, 2022", label: "Event Date")],
            products: Array(RegistryDetailSection.samples.flatMap(\.products).prefix(3)),
            contributions: []
        ),
        ExistingRegistry(
            id: UUID(),
            coupleName: "Holiday Registry",
            email: "holiday.registry@example.com",
            relationship: .family,
            origin: .participated,
            event: "Holiday",
            eventDate: "December 1, 2021",
            shortDate: "Dec 1, 2021",
            message: "Thank you for making the holidays brighter.",
            about: "Holiday hosting essentials and cozy seasonal favorites.",
            status: "Archived",
            stats: [RegistryStat(value: "24", label: "Items"), RegistryStat(value: "16", label: "Purchased"), RegistryStat(value: "-", label: "Fulfilled"), RegistryStat(value: "Dec 1, 2021", label: "Event Date")],
            products: Array(RegistryDetailSection.samples.flatMap(\.products).prefix(3)),
            contributions: []
        )
    ]

    func matches(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        let needle = trimmed.lowercased()
        return coupleName.lowercased().contains(needle) || email.lowercased().contains(needle)
    }

    static func == (lhs: ExistingRegistry, rhs: ExistingRegistry) -> Bool { lhs.id == rhs.id }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    static func lookup(_ id: UUID, ownedRegistries: [Registry]) -> ExistingRegistry {
        let own = ownedRegistries.map(Self.fromOwnedRegistry)
        return (own + [gayatri] + pastSamples).first(where: { $0.id == id }) ?? gayatri
    }

    static func fromOwnedRegistry(_ registry: Registry) -> ExistingRegistry {
        let dateLabel = registry.date.formatted(date: .long, time: .omitted)
        let shortDate = registry.date.formatted(date: .abbreviated, time: .omitted)
        let totalItems = registry.items.reduce(0) { $0 + $1.quantity }
        let purchasedItems = registry.items
            .filter(\.isPurchased)
            .reduce(0) { $0 + $1.quantity }
        return ExistingRegistry(
            id: registry.id,
            coupleName: "\(registry.firstName) & \(registry.lastName)",
            email: "my.registry@example.com",
            relationship: .friends,
            origin: .own,
            event: registry.event.rawValue,
            eventDate: dateLabel,
            shortDate: shortDate,
            message: "Thanks for celebrating with us and helping us build our registry.",
            about: "Our registry for \(registry.event.rawValue.lowercased()) with curated gift picks.",
            status: "Completed",
            stats: [
                RegistryStat(value: "\(totalItems)", label: "Items"),
                RegistryStat(value: "\(purchasedItems)", label: "Purchased"),
                RegistryStat(value: totalItems == 0 ? "0%" : "-", label: "Fulfilled"),
                RegistryStat(value: shortDate, label: "Event Date")
            ],
            products: registry.items.prefix(3).map { RegistryDisplayProduct(item: $0) },
            contributions: []
        )
    }
}

private enum RegistryRelationship: String, Hashable {
    case friends = "My Friends"
    case family = "Family"
}

private struct RegistryStat: Hashable {
    let value: String
    let label: String
}

private struct RegistryContribution: Hashable, Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let time: String
}

private struct PastRegistriesView: View {
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @EnvironmentObject var registryRepo: RegistryRepository
    @State private var selectedFilter = "All"

    private let filters = ["All", "Mine", "Participated"]

    private var ownPastRegistries: [ExistingRegistry] {
        let today = Calendar.current.startOfDay(for: Date())
        return registryRepo.registries
            .filter { Calendar.current.startOfDay(for: $0.date) < today }
            .map(ExistingRegistry.fromOwnedRegistry)
    }

    private var participatedPastRegistries: [ExistingRegistry] {
        ExistingRegistry.pastSamples.filter { $0.origin == .participated }
    }

    private var visibleRegistries: [ExistingRegistry] {
        let all = ownPastRegistries + participatedPastRegistries
        return all.filter { registry in
            switch selectedFilter {
            case "Mine":
                return registry.origin == .own
            case "Participated":
                return registry.origin == .participated
            default:
                return true
            }
        }
    }

    var body: some View {
        ZStack {
            WSRegistryPalette.ivory.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    pastHero
                    filterTabs
                    registryList
                    missingRegistryCard
                }
                .padding(.horizontal, 18)
                .padding(.top, 8)
                .padding(.bottom, 180)
            }
        }
        .navigationTitle("Past Registries")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pastHero: some View {
        ZStack(alignment: .leading) {
            Image("giftdna_living_room")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 176)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [WSRegistryPalette.ivory, WSRegistryPalette.ivory.opacity(0.92), WSRegistryPalette.ivory.opacity(0.14)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            VStack(alignment: .leading, spacing: 10) {
                Text("Past Registries")
                    .font(.system(size: 30, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text("See your past registries and events where you participated.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.86))
                    .lineSpacing(3)
                    .frame(maxWidth: 250, alignment: .leading)
            }
            .padding(.leading, 16)
        }
        .frame(height: 176)
        .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
    }

    private var filterTabs: some View {
        HStack(spacing: 8) {
            ForEach(filters, id: \.self) { filter in
                Button {
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                        selectedFilter = filter
                    }
                } label: {
                    Text(filter)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(selectedFilter == filter ? WSRegistryPalette.cream : WSRegistryPalette.espresso)
                        .frame(maxWidth: .infinity, minHeight: 42)
                        .background(
                            selectedFilter == filter ? WSRegistryPalette.espresso : WSRegistryPalette.porcelain,
                            in: RoundedRectangle(cornerRadius: 2, style: .continuous)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(WSRegistryPalette.porcelain.opacity(0.92), in: RoundedRectangle(cornerRadius: 2, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 2, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.38), lineWidth: 1))
    }

    private var registryList: some View {
        VStack(spacing: 14) {
            ForEach(Array(visibleRegistries.enumerated()), id: \.element.id) { index, registry in
                pastRegistryRow(registry, imageOffset: index)
            }
        }
    }

    private func pastRegistryRow(_ registry: ExistingRegistry, imageOffset: Int) -> some View {
        Button {
            tabBarVM.registryPath.append(RegistryRoute.existingRegistryDetails(registry.id))
        } label: {
            HStack(spacing: 14) {
                Image("giftdna_living_room")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 118, height: 132)
                    .offset(x: CGFloat(-imageOffset * 16))
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(registry.coupleName)
                                .font(.system(size: 22, weight: .regular, design: .serif))
                                .foregroundStyle(WSRegistryPalette.espresso)
                                .lineLimit(1)
                                .minimumScaleFactor(0.68)
                            Text(registry.event + " • " + registry.shortDate)
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(WSRegistryPalette.warmGray)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.espresso.opacity(0.82))
                            .padding(.top, 12)
                    }

                    Text(registry.status)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(registry.status == "Archived" ? WSRegistryPalette.cocoa : WSRegistryPalette.sage)
                        .padding(.horizontal, 12)
                        .frame(height: 28)
                        .background((registry.status == "Archived" ? WSRegistryPalette.gold.opacity(0.16) : WSRegistryPalette.sage.opacity(0.16)), in: Capsule())

                    HStack(spacing: 0) {
                        pastStat(value: registry.itemCount, label: "Items")
                        pastDivider
                        pastStat(value: registry.purchasedCount, label: "Purchased")
                        pastDivider
                        pastStat(value: registry.fulfilledText, label: "Fulfilled")
                    }
                }
                .padding(.vertical, 16)
                .padding(.trailing, 12)
            }
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .leading)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 2, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1))
            .shadow(color: WSRegistryPalette.espresso.opacity(0.035), radius: 12, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }

    private func pastStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var pastDivider: some View {
        Rectangle()
            .fill(WSRegistryPalette.hairline.opacity(0.45))
            .frame(width: 1, height: 34)
            .padding(.horizontal, 8)
    }

    private var missingRegistryCard: some View {
        HStack(spacing: 16) {
            Image(systemName: "gift")
                .font(.system(size: 27, weight: .regular))
                .foregroundStyle(WSRegistryPalette.gold)
                .frame(width: 60, height: 60)
                .background(WSRegistryPalette.gold.opacity(0.13), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Need help finding an older registry?")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                Text("If it isn’t listed, it may be archived or under a different email.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.84))
                    .lineSpacing(2)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso.opacity(0.72))
        }
        .padding(18)
        .background(WSRegistryPalette.cream, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
    }
}


private struct FindRegistryView: View {
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @State private var searchText = ""
    @State private var selectedFilter = "All"

    private let filters = ["All", "My Friends", "Family", "By Name", "By Email"]
    private let registries: [ExistingRegistry] = {
        var seen = Set<UUID>()
        return ([ExistingRegistry.gayatri] + ExistingRegistry.pastSamples).filter { registry in
            seen.insert(registry.id).inserted
        }
    }()

    private var visibleRegistries: [ExistingRegistry] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return registries.filter { registry in
            guard registry.matches(searchText) else { return false }

            switch selectedFilter {
            case "My Friends":
                return registry.relationship == .friends
            case "Family":
                return registry.relationship == .family
            case "By Name":
                return query.isEmpty || registry.coupleName.lowercased().contains(query)
            case "By Email":
                return query.isEmpty || registry.email.lowercased().contains(query)
            default:
                return true
            }
        }
    }

    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    searchField
                    filterBar

                    Text(searchText.isEmpty ? "Suggested" : "Results")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .padding(.top, 8)

                    if visibleRegistries.isEmpty {
                        emptySearchState
                    } else {
                        VStack(spacing: 12) {
                            ForEach(visibleRegistries) { registry in
                                existingRegistryRow(registry)
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Find Registry")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(WSRegistryPalette.warmGray)

            TextField("Search by name or email", text: $searchText)
                .font(.system(size: 15, weight: .regular))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, minHeight: 52)
        .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.5), lineWidth: 1)
        )
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selectedFilter == filter ? WSRegistryPalette.espresso : WSRegistryPalette.cocoa)
                            .padding(.horizontal, 14)
                            .frame(height: 38)
                            .background(
                                selectedFilter == filter ? WSRegistryPalette.gold.opacity(0.24) : WSRegistryPalette.porcelain,
                                in: RoundedRectangle(cornerRadius: 2, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 2, style: .continuous)
                                    .stroke(WSRegistryPalette.hairline.opacity(0.55), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptySearchState: some View {
        Text("No registries match this search.")
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(WSRegistryPalette.warmGray)
            .frame(maxWidth: .infinity, minHeight: 96)
            .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
    }

    private func existingRegistryRow(_ registry: ExistingRegistry) -> some View {
        Button {
            tabBarVM.registryPath.append(RegistryRoute.existingRegistryDetails(registry.id))
        } label: {
            HStack(spacing: 12) {
                Image("giftdna_living_room")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 86, height: 86)
                    .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(registry.coupleName)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(1)
                    Text(registry.email)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .lineLimit(1)
                    Text("\(registry.event) • \(registry.eventDate)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.84))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text("Open")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cream)
                    .frame(width: 70, height: 44)
                    .background(WSRegistryPalette.espresso, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1)
            )
            .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}

private struct ExistingRegistryDetailsView: View {
    let registry: ExistingRegistry

    var body: some View {
        ZStack {
            WSRegistryPalette.ivory.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    summaryHero
                    noteCard
                    overviewCard
                    activityCard
                    timelineCard
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 180)
            }
        }
        .navigationTitle("Registry Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(WSRegistryPalette.ivory, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: "\(registry.coupleName) Registry • \(registry.event) • \(registry.eventDate)") {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }
                .accessibilityLabel("Share registry")
            }
        }
    }

    private var summaryHero: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Image("giftdna_living_room")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 174)
                    .clipped()

                Image("giftdna_living_room")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 112, height: 112)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(WSRegistryPalette.porcelain, lineWidth: 4))
                    .shadow(color: WSRegistryPalette.espresso.opacity(0.12), radius: 10, x: 0, y: 6)
                    .offset(y: 56)
            }

            VStack(spacing: 10) {
                Text(registry.coupleName)
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(registry.event + " • " + registry.eventDate)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(registry.status)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.sage)
                    .padding(.horizontal, 14)
                    .frame(height: 30)
                    .background(WSRegistryPalette.sage.opacity(0.16), in: Capsule())
                    .padding(.top, 2)

                HStack(spacing: 0) {
                    summaryStat(icon: "cart", value: registry.itemCount, label: "Items")
                    summaryDivider
                    summaryStat(icon: "bag", value: registry.purchasedCount, label: "Purchased")
                    summaryDivider
                    summaryStat(icon: "party.popper", value: registry.fulfilledText, label: "Fulfilled")
                    summaryDivider
                    summaryStat(icon: "calendar", value: registry.shortDate, label: "Event Date")
                }
                .padding(.top, 18)
            }
            .padding(.horizontal, 14)
            .padding(.top, 66)
            .padding(.bottom, 18)
        }
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 2, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1))
        .shadow(color: WSRegistryPalette.espresso.opacity(0.035), radius: 14, x: 0, y: 6)
    }

    private func summaryStat(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.86))
            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
            Text(label)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var summaryDivider: some View {
        Rectangle()
            .fill(WSRegistryPalette.hairline.opacity(0.45))
            .frame(width: 1, height: 58)
    }

    private var noteCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Text("“")
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.72))

            VStack(alignment: .leading, spacing: 14) {
                Text(registry.message)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.espresso.opacity(0.92))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                Button("Guest note") { }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.gold)
            }
        }
        .padding(20)
        .background(WSRegistryPalette.cream, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
    }

    private var overviewCard: some View {
        summarySection(title: "Registry Snapshot") {
            summaryRow(icon: "clipboard", title: "Total Items", detail: registry.itemCount + " items")
            summaryRow(icon: "bag", title: "Gifts Purchased", detail: registry.purchasedCount + " items")
            summaryRow(icon: "gift", title: "Contributions", detail: registry.contributionsCountText)
            summaryRow(icon: "square.grid.2x2", title: "Featured Products", detail: registry.featuredProductsText, showDivider: false)
        }
    }

    private var activityCard: some View {
        summarySection(title: "Recent Activity") {
            HStack(spacing: 14) {
                Image(systemName: "gift")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.gold)
                    .frame(width: 44, height: 44)
                    .background(WSRegistryPalette.gold.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Latest contribution")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                    Text(registry.topContributionDetail)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }
                Spacer()
                Text(registry.topContributionTime)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
            }
        }
    }

    private var timelineCard: some View {
        summarySection(title: "Event Timeline") {
            summaryRow(icon: "calendar", title: "Event Date", detail: registry.eventDate)
            summaryRow(icon: "checkmark.seal", title: "Registry Status", detail: registry.status, showDivider: false)
        }
    }

    private func summarySection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso)
            content()
        }
        .padding(18)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 2, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1))
        .shadow(color: WSRegistryPalette.espresso.opacity(0.025), radius: 10, x: 0, y: 5)
    }

    private func summaryRow(icon: String, title: String, detail: String, showDivider: Bool = true) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.88))
                    .frame(width: 26)
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.espresso)
                Spacer()
                Text(detail)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.72))
            }
            .frame(minHeight: 42)

            if showDivider {
                Rectangle()
                    .fill(WSRegistryPalette.hairline.opacity(0.45))
                    .frame(height: 1)
                    .padding(.leading, 40)
            }
        }
    }
}



private struct RegistryDetailsView: View {
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel

    @State private var isProductListExpanded = true

    private var registryItems: [RegistryItem] {
        registryRepo.currentRegistry?.items ?? []
    }

    private var availableRegistries: [Registry] {
        registryRepo.registries.sorted { $0.date > $1.date }
    }

    private var registryDescriptor: String {
        guard let registry = registryRepo.currentRegistry else {
            return "A curated registry built around your gifting priorities."
        }
        let eventLabel = registry.event.rawValue
        let dateLabel = registry.date.formatted(date: .abbreviated, time: .omitted)
        return "\(registry.firstName) & \(registry.lastName) • \(eventLabel) • \(dateLabel)"
    }

    private var sections: [RegistryDetailSection] {
        RegistryDetailContent.sections(from: registryItems)
    }

    private var totalItems: Int {
        RegistryDetailContent.totalItems(from: registryItems)
    }

    private var totalCollections: Int {
        RegistryDetailContent.collectionCount(from: registryItems)
    }

    private var purchasedItems: Int {
        RegistryDetailContent.purchasedItems(from: registryItems)
    }

    private var completionText: String {
        RegistryDetailContent.completionText(from: registryItems)
    }

    private var followupRecommendationPayload: RegistryQuestionnairePayload {
        let existing = registryRepo.currentRegistry
        let categorySeed = Set(
            RegistryDetailContent.sections(from: registryItems)
                .prefix(4)
                .map(\.title)
        )
        return QuestionnaireReducer.buildPayload(
            registryID: existing?.id ?? UUID(),
            moodboardVibe: "timeless functional registry with balanced gifting options",
            moodboardPhotoCount: 0,
            homeType: nil,
            hobbies: [],
            hobbiesSkipped: true,
            productCategories: categorySeed,
            budgetPreference: nil,
            homeVision: nil
        )
    }

    private var shareSummaryText: String {
        if let registry = registryRepo.currentRegistry {
            return "\(registry.displayName) • \(registry.date.formatted(date: .abbreviated, time: .omitted)) • \(totalItems) items"
        }
        return "My Williams Sonoma registry"
    }

    private var bundleCompletionSuggestions: [String] {
        let sections = RegistryDetailContent.sections(from: registryItems)
        let thinSections = sections
            .filter { $0.itemCount < 4 }
            .prefix(3)
            .map { "Complete \( $0.title ) bundle (\($0.itemCount) saved)." }

        if !thinSections.isEmpty {
            return Array(thinSections)
        }

        if sections.isEmpty {
            return ["Start with AI Personalized Set or Top 100 Essentials."]
        }

        return ["Your core bundles are in progress. Refresh recommendations for finishing picks."]
    }

    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    if availableRegistries.count > 1 {
                        registrySwitcher
                    }
                    // 1. Registry Story
                    homeStoryCard
                    // 2. Stats (no Collections)
                    statsCard
                    // 3. Browse & Add + Open Recommendations
                    addItemsButton
                    recommendationActionsCard
                    // 4. Collapsible product list
                    if !registryItems.isEmpty {
                        collapsibleProductList
                    } else {
                        emptyRegistryState
                    }
                    // 5. AI Insights
                    aiInsightsCard
                    // 6. Budget Tracker
                    if !registryItems.isEmpty {
                        budgetTrackerCard
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Your Registry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareSummaryText) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.gold)
                }
            }
        }
    }

    private var homeStoryCard: some View {
        ZStack(alignment: .bottomLeading) {
            Image("giftdna_living_room")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [.clear, WSRegistryPalette.espresso.opacity(0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9))
                        .foregroundStyle(WSRegistryPalette.gold)
                    Text("AURA REGISTRY")
                        .font(.wsLabel(size: 9))
                        .tracking(1.5)
                        .foregroundStyle(WSRegistryPalette.gold)
                }

                Text("Your Registry Story")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)

                Text(registryDescriptor)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.85))
                    .lineSpacing(3)
                    .lineLimit(2)
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: WSRegistryPalette.espresso.opacity(0.12), radius: 16, x: 0, y: 8)
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(value: "\(totalItems)", label: "Items")
            divider
            statItem(value: "\(purchasedItems)", label: "Purchased")
            divider
            statItem(value: completionText, label: "Completed")
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.48), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.05), radius: 12, x: 0, y: 6)
    }

    // MARK: - Collapsible Product List

    private var collapsibleProductList: some View {
        let visibleItems = Array(registryItems.prefix(4))
        let hasMore = registryItems.count > 4

        return VStack(alignment: .leading, spacing: 0) {
            // Header row
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isProductListExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.gold)
                    Text("Registry Items")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Spacer()
                    Text("\(totalItems) items")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                    Image(systemName: isProductListExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if isProductListExpanded {
                Divider().padding(.horizontal, 16)

                ForEach(Array(visibleItems.enumerated()), id: \.element.id) { index, item in
                    productListRow(item: item, isLast: !hasMore && index == visibleItems.count - 1)
                }

                // View All button
                if hasMore {
                    Divider().padding(.horizontal, 16)

                    Button {
                        tabBarVM.registryPath.append(RegistryRoute.allProducts)
                    } label: {
                        HStack {
                            Spacer()
                            Text("View All \(registryItems.count) Items")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(WSRegistryPalette.gold)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(WSRegistryPalette.gold)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.48), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 12, x: 0, y: 6)
    }

    private func productListRow(item: RegistryItem, isLast: Bool) -> some View {
        let isPurchased = item.isPurchased

        return VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Purchase checkbox
                Image(systemName: isPurchased ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(isPurchased ? WSRegistryPalette.sage : WSRegistryPalette.hairline)

                // Product image
                CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + item.imageUrl))
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                // Product info
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        if let collection = item.collectionName {
                            Text(collection)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(WSRegistryPalette.warmGray)
                                .lineLimit(1)
                        }
                        Text("Qty: \(item.quantity)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                    }
                }

                Spacer(minLength: 8)

                // Price
                VStack(alignment: .trailing, spacing: 3) {
                    Text(item.price.formatted(.currency(code: "USD")))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    if isPurchased {
                        Text("Purchased")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(WSRegistryPalette.sage)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if !isLast {
                Divider().padding(.leading, 50).padding(.trailing, 16)
            }
        }
    }

    private var addItemsButton: some View {
        Button {
            tabBarVM.selectTab(.home)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(WSRegistryPalette.gold.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "bag.badge.plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.gold)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Browse & Add Gifts")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Text("Explore the catalog and add items to your registry")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.6))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(WSRegistryPalette.hairline.opacity(0.48), lineWidth: 1)
            )
            .shadow(color: WSRegistryPalette.espresso.opacity(0.05), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var aiInsightsCard: some View {
        let items = registryRepo.currentRegistry?.items ?? []
        let hasItems = !items.isEmpty

        // Compute a quick score preview
        let collectionCount = Set(items.compactMap(\.collectionName)).count
        let totalItems = items.reduce(0) { $0 + $1.quantity }
        let prices = items.map(\.price)
        let hasLow = prices.contains(where: { $0 < 3000 })
        let hasMid = prices.contains(where: { $0 >= 3000 && $0 <= 15000 })
        let hasHigh = prices.contains(where: { $0 > 15000 })
        let rangeCount = [hasLow, hasMid, hasHigh].filter { $0 }.count

        let quickScore: Double = hasItems
            ? min(1.0, (Double(rangeCount) / 3.0 * 0.3)
                + (min(1.0, Double(totalItems) / 15.0) * 0.3)
                + (min(1.0, Double(collectionCount) / 3.0) * 0.4))
            : 0.0
        let scoreInt = Int((quickScore * 100).rounded())

        return Button {
            tabBarVM.registryPath.append(RegistryRoute.registryInsights)
        } label: {
            HStack(spacing: 16) {
                // Mini score ring
                ZStack {
                    Circle()
                        .stroke(WSRegistryPalette.hairline.opacity(0.3), lineWidth: 5)
                        .frame(width: 52, height: 52)

                    Circle()
                        .trim(from: 0, to: CGFloat(quickScore))
                        .stroke(
                            AngularGradient(
                                colors: [WSRegistryPalette.gold, WSRegistryPalette.gold.opacity(0.4)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(-90))

                    Text("\(scoreInt)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(WSRegistryPalette.gold)
                        Text("AI REGISTRY INSIGHTS")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(WSRegistryPalette.gold)
                    }

                    Text(hasItems
                        ? "See your budget balance, aesthetic harmony, and completeness score."
                        : "Add items to unlock personalized registry analysis.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.85))
                        .lineSpacing(2)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.65))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [WSRegistryPalette.ivory, Color(red: 0.98, green: 0.96, blue: 0.92)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(WSRegistryPalette.gold.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: WSRegistryPalette.gold.opacity(0.06), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .disabled(!hasItems)
        .opacity(hasItems ? 1.0 : 0.6)
    }

    // MARK: - Budget Tracker by Pattern

    private var budgetTrackerCard: some View {
        let registry = registryRepo.currentRegistry
        let items = registry?.items ?? []
        let grouped = Dictionary(grouping: items) { item -> String in
            let resolved = RegistryRepository.resolvePattern(name: item.name, originalPattern: item.pattern)
            return resolved.replacingOccurrences(of: "-", with: " ").capitalized
        }

        let totalSpend = items.reduce(0.0) { $0 + $1.price * Double($1.quantity) }

        let sortedPatterns = grouped.keys.sorted {
            let a = grouped[$0]!.reduce(0.0) { $0 + $1.price * Double($1.quantity) }
            let b = grouped[$1]!.reduce(0.0) { $0 + $1.price * Double($1.quantity) }
            return a > b
        }

        let patternColors: [Color] = [
            WSRegistryPalette.sage,
            WSRegistryPalette.gold,
            WSRegistryPalette.cocoa,
            Color(hex: "#B85C38"),
            Color(hex: "#5B7065"),
            Color(hex: "#9A8355"),
            Color(hex: "#786049"),
            Color(hex: "#3E2723")
        ]

        return VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("BUDGET TRACKER")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(WSRegistryPalette.gold)
                Spacer()
                Text("$\(Int(totalSpend))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.espresso)
            }

            Text("Spend breakdown by product category pattern")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)

            // Stacked bar
            if totalSpend > 0 {
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(Array(sortedPatterns.enumerated()), id: \.element) { index, pattern in
                            let patternItems = grouped[pattern]!
                            let patternSpend = patternItems.reduce(0.0) { $0 + $1.price * Double($1.quantity) }
                            let fraction = patternSpend / totalSpend
                            let color = patternColors[index % patternColors.count]

                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(color)
                                .frame(width: max(6, geo.size.width * CGFloat(fraction)))
                        }
                    }
                }
                .frame(height: 14)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }

            // Pattern rows
            VStack(spacing: 0) {
                ForEach(Array(sortedPatterns.enumerated()), id: \.element) { index, pattern in
                    let patternItems = grouped[pattern]!
                    let totalQty = patternItems.reduce(0) { $0 + $1.quantity }
                    let patternSpend = patternItems.reduce(0.0) { $0 + $1.price * Double($1.quantity) }
                    let percentage = totalSpend > 0 ? (patternSpend / totalSpend * 100) : 0
                    let color = patternColors[index % patternColors.count]
                    let icon = iconForPattern(pattern)

                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(color.opacity(0.15))
                                    .frame(width: 36, height: 36)

                                Image(systemName: icon)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(color)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(pattern)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(WSRegistryPalette.espresso)

                                Text("\(patternItems.count) product\(patternItems.count == 1 ? "" : "s") · \(totalQty) unit\(totalQty == 1 ? "" : "s")")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundStyle(WSRegistryPalette.warmGray)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("$\(Int(patternSpend))")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(WSRegistryPalette.espresso)

                                Text("\(Int(percentage.rounded()))%")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(color)
                            }
                        }
                        .padding(.vertical, 12)

                        if index < sortedPatterns.count - 1 {
                            Rectangle()
                                .fill(WSRegistryPalette.hairline.opacity(0.4))
                                .frame(height: 1)
                                .padding(.leading, 48)
                        }
                    }
                }
            }

            // Summary row
            HStack(spacing: 12) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                    .foregroundStyle(WSRegistryPalette.warmGray)

                Text("\(sortedPatterns.count) category\(sortedPatterns.count == 1 ? "" : "ies") · \(items.count) product\(items.count == 1 ? "" : "s") · Avg $\(items.isEmpty ? 0 : Int(totalSpend / Double(items.count)))/item")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.warmGray)
            }
            .padding(.top, 4)
        }
        .padding(18)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 12, x: 0, y: 6)
    }

    private func iconForPattern(_ pattern: String) -> String {
        let p = pattern.lowercased()
        if p.contains("cook") || p.contains("kitchen") { return "frying.pan" }
        if p.contains("bake") || p.contains("baking") { return "birthday.cake" }
        if p.contains("dinner") || p.contains("dining") || p.contains("dinnerware") { return "fork.knife" }
        if p.contains("serve") || p.contains("serveware") || p.contains("host") { return "wineglass" }
        if p.contains("homekeep") || p.contains("clean") { return "house" }
        if p.contains("cutlery") || p.contains("knife") || p.contains("knives") { return "scissors" }
        if p.contains("bar") || p.contains("drink") || p.contains("cocktail") { return "wineglass.fill" }
        if p.contains("outdoor") || p.contains("garden") { return "leaf" }
        if p.contains("bed") || p.contains("linen") || p.contains("textile") { return "bed.double" }
        if p.contains("bath") { return "shower" }
        if p.contains("decor") || p.contains("decorat") { return "paintpalette" }
        if p.contains("coffee") || p.contains("tea") || p.contains("morning") { return "cup.and.saucer" }
        if p.contains("electr") || p.contains("applian") { return "bolt.fill" }
        if p.contains("food") || p.contains("gourmet") { return "carrot" }
        return "square.grid.2x2"
    }

    private var registrySwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(availableRegistries) { registry in
                    let isActive = registryRepo.activeRegistryID == registry.id
                    Button {
                        registryRepo.selectRegistry(id: registry.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(registry.event.rawValue)
                                .font(.wsLabel(size: 10))
                            Text(registry.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.wsBody(size: 11))
                        }
                        .foregroundStyle(isActive ? WSRegistryPalette.cream : WSRegistryPalette.espresso)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            isActive ? WSRegistryPalette.espresso : WSRegistryPalette.ivory,
                            in: RoundedRectangle(cornerRadius: 2, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var recommendationActionsCard: some View {
        Button {
            tabBarVM.registryPath.append(RegistryRoute.recommendations(followupRecommendationPayload))
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [WSRegistryPalette.gold.opacity(0.22), WSRegistryPalette.gold.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.gold)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("AI Recommendations")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Text("Personalized picks, bundles & curated essentials")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.6))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [WSRegistryPalette.ivory, Color(red: 0.98, green: 0.96, blue: 0.92)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(WSRegistryPalette.gold.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: WSRegistryPalette.gold.opacity(0.06), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var emptyRegistryState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your registry is ready to curate.")
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
            Text("Add essentials, AI picks, or complete sets to start your registry.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineSpacing(3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.48), lineWidth: 1)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(WSRegistryPalette.hairline.opacity(0.70))
            .frame(width: 1, height: 45)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(label)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
    }

    private func registrySection(_ section: RegistryDetailSection) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title)
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Text("\(section.itemCount) Items")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(section.tint)
                }

                Spacer()

                Button("View All") {
                    tabBarVM.registryPath.append(RegistryRoute.categoryProducts(section.title))
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.gold)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(section.products.prefix(6)) { product in
                        registryProductCard(product)
                            .frame(width: 170)
                    }
                }
                .padding(.horizontal, 2)
                .padding(.vertical, 4)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(WSRegistryPalette.hairline.opacity(0.28))
                    Capsule()
                        .fill(section.tint)
                        .frame(width: proxy.size.width * section.progress)
                }
            }
            .frame(height: 4)
        }
    }

    private func registryProductCard(_ product: RegistryDisplayProduct) -> some View {
        let productItem = ProductItem(
            id: product.id,
            name: product.name,
            price: product.numericPrice,
            path: product.imagePath,
            productType: nil,
            brand: product.brand
        )
        let cartQuantity = cartRepo.items.first(where: { $0.id == product.id })?.quantity ?? 0
        let registryQuantity = registryRepo.currentRegistry?.items.first(where: { $0.id == product.id })?.quantity ?? 0

        return ProductCardView(
            product: productItem,
            quantity: cartQuantity,
            registryQuantity: registryQuantity,
            onAdd: { cartRepo.add(product: productItem) },
            onRemove: { cartRepo.removeOne(productId: product.id) },
            onAddToRegistry: {
                // Opens the registry picker sheet so the user can choose which registry to add to
                registryRepo.presentRegistryPicker(for: productItem)
            },
            onRemoveFromRegistry: { registryRepo.removeItem(product.id) }
        )
    }
}


private struct RegistryCategoryProductsView: View {
    let sectionTitle: String
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository
    @State private var selectedProduct: RegistryDisplayProduct?
    @State private var removedProductIDs = Set<String>()

    private var registryItems: [RegistryItem] {
        registryRepo.currentRegistry?.items ?? []
    }

    private var products: [RegistryDisplayProduct] {
        RegistryDetailContent.sections(from: registryItems)
            .filter { $0.title == sectionTitle }
            .flatMap(\.products)
            .filter { !removedProductIDs.contains($0.id) }
    }

    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    listToolbar

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 14
                    ) {
                        ForEach(products) { product in
                            registryProductListRow(product)
                                .onLongPressGesture {
                                    selectedProduct = product
                                }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(sectionTitle)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedProduct) { product in
            RegistryProductActionSheet(
                product: product,
                onMoveToCollection: { collection in
                    registryRepo.moveToCollection(productId: product.id, collectionName: collection)
                },
                onRemove: { removeProduct(product) }
            )
            .presentationDetents([.height(620), .large])
            .presentationDragIndicator(.visible)
        }
    }

    private func removeProduct(_ product: RegistryDisplayProduct) {
        if registryRepo.currentRegistry?.items.contains(where: { $0.id == product.id }) == true {
            registryRepo.removeItem(product.id)
        }
        removedProductIDs.insert(product.id)
        selectedProduct = nil
    }

    private var listToolbar: some View {
        HStack {
            Menu {
                Button("Recently Added") { }
                Button("Price: Low to High") { }
                Button("Purchased") { }
                Button("Unpurchased") { }
            } label: {
                HStack(spacing: 6) {
                    Text("Sort: Recently Added")
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(WSRegistryPalette.espresso)
            }

            Spacer(minLength: 8)

            Text("\(products.count) items")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
        }
        .padding(.bottom, 6)
    }

    private func registryProductListRow(_ product: RegistryDisplayProduct) -> some View {
        let productItem = ProductItem(
            id: product.id,
            name: product.name,
            price: product.numericPrice,
            path: product.imagePath,
            productType: nil,
            brand: product.brand
        )
        let cartQuantity = cartRepo.items.first(where: { $0.id == product.id })?.quantity ?? 0
        let registryQuantity = registryRepo.currentRegistry?.items.first(where: { $0.id == product.id })?.quantity ?? 0

        return ProductCardView(
            product: productItem,
            quantity: cartQuantity,
            registryQuantity: registryQuantity,
            onAdd: { cartRepo.add(product: productItem) },
            onRemove: { cartRepo.removeOne(productId: product.id) },
            onAddToRegistry: {
                // Opens the registry picker sheet so the user can choose which registry to add to
                registryRepo.presentRegistryPicker(for: productItem)
            },
            onRemoveFromRegistry: { registryRepo.removeItem(product.id) }
        )
    }
}

private struct RegistryProductActionSheet: View {
    let product: RegistryDisplayProduct
    let onMoveToCollection: (String) -> Void
    let onRemove: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var noteText = ""
    @State private var collection = "Daily Cooking"
    @State private var priority = "Medium"
    @State private var isShowingNoteEditor = false
    @State private var isShowingCollectionPicker = false
    @State private var isShowingPriorityPicker = false
    @State private var isShowingRemoveConfirm = false

    var body: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(WSRegistryPalette.hairline.opacity(0.9))
                .frame(width: 56, height: 5)
                .padding(.top, 8)

            HStack(alignment: .top, spacing: 16) {
                CustomAsyncImage(url: product.imageURL)
                    .frame(width: 126, height: 126)
                    .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.brand)
                        .font(.system(size: 25, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(1)
                    Text(product.name)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.9))
                        .lineLimit(2)
                    if let detail = product.detail {
                        Text(detail)
                            .font(.system(size: 17, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.84))
                    }
                    Text(product.priceText)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }
                Spacer(minLength: 0)
            }

            purchaseStatusCard
            actionList
            closeButton
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(WSRegistryPalette.porcelain.ignoresSafeArea())
        .alert("Add Note", isPresented: $isShowingNoteEditor) {
            TextField("Note", text: $noteText)
            Button("Save") { }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Add a private note for this registry item.")
        }
        .confirmationDialog("Move to Collection", isPresented: $isShowingCollectionPicker, titleVisibility: .visible) {
            Button("Daily Cooking") {
                collection = "Daily Cooking"
                onMoveToCollection(collection)
            }
            Button("Hosting") {
                collection = "Hosting"
                onMoveToCollection(collection)
            }
            Button("Shared Dining") {
                collection = "Shared Dining"
                onMoveToCollection(collection)
            }
            Button("Morning Rituals") {
                collection = "Morning Rituals"
                onMoveToCollection(collection)
            }
            Button("Cancel", role: .cancel) { }
        }
        .confirmationDialog("Edit Priority", isPresented: $isShowingPriorityPicker, titleVisibility: .visible) {
            Button("High") { priority = "High" }
            Button("Medium") { priority = "Medium" }
            Button("Low") { priority = "Low" }
            Button("Cancel", role: .cancel) { }
        }
        .confirmationDialog("Remove from Registry?", isPresented: $isShowingRemoveConfirm, titleVisibility: .visible) {
            Button("Remove from Registry", role: .destructive) {
                onRemove()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This item will be removed from your registry list.")
        }
        .onAppear {
            if let collectionName = product.collectionName, !collectionName.isEmpty {
                collection = collectionName
            }
        }
    }

    private var purchaseStatusCard: some View {
        HStack(spacing: 14) {
            Image(systemName: product.isPurchased ? "checkmark.circle" : "circle")
                .font(.system(size: 27, weight: .medium))
                .foregroundStyle(product.isPurchased ? WSRegistryPalette.sage : WSRegistryPalette.gold)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.isPurchased ? "Purchased" : "Unpurchased")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                Text(product.statusDetailText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.84))
                    .lineLimit(2)
            }

            Spacer(minLength: 10)

            if product.isPurchased {
                Text(product.purchaserInitials)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.porcelain)
                    .frame(width: 42, height: 42)
                    .background(WSRegistryPalette.cocoa.opacity(0.72), in: Circle())
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.ivory.opacity(0.68), in: RoundedRectangle(cornerRadius: 2, style: .continuous))
    }

    private var actionList: some View {
        VStack(spacing: 0) {
            actionRow(icon: "note.text", title: noteText.isEmpty ? "Add Note" : "Edit Note", trailing: noteText.isEmpty ? nil : "Saved") {
                isShowingNoteEditor = true
            }
            actionDivider
            actionRow(icon: "folder", title: "Move to Collection", trailing: collection) {
                isShowingCollectionPicker = true
            }
            actionDivider
            actionRow(icon: "star", title: "Edit Priority", trailing: priority) {
                isShowingPriorityPicker = true
            }
            actionDivider
            actionRow(icon: "trash", title: "Remove from Registry", role: .destructive) {
                isShowingRemoveConfirm = true
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.55), lineWidth: 1)
        )
    }

    private var actionDivider: some View {
        Rectangle()
            .fill(WSRegistryPalette.hairline.opacity(0.52))
            .frame(height: 1)
            .padding(.leading, 42)
    }

    private func actionRow(
        icon: String,
        title: String,
        trailing: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .regular))
                    .foregroundStyle(role == .destructive ? Color.red : WSRegistryPalette.espresso)
                    .frame(width: 28)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(role == .destructive ? Color.red : WSRegistryPalette.espresso)
                Spacer(minLength: 8)
                if let trailing {
                    Text(trailing)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.gold)
                        .lineLimit(1)
                }
                if role != .destructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso.opacity(0.72))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Close")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .frame(maxWidth: .infinity, minHeight: 58)
                .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 2, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .stroke(WSRegistryPalette.hairline.opacity(0.9), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}


private enum RegistryDetailContent {
    static func sections(from registryItems: [RegistryItem]) -> [RegistryDetailSection] {
        guard !registryItems.isEmpty else { return [] }
        return userSections(from: registryItems)
    }

    static func totalItems(from registryItems: [RegistryItem]) -> Int {
        registryItems.reduce(0) { $0 + $1.quantity }
    }

    static func collectionCount(from registryItems: [RegistryItem]) -> Int {
        guard !registryItems.isEmpty else { return 0 }
        return Set(registryItems.map { $0.collectionName ?? "My Registry" }).count
    }

    static func purchasedItems(from registryItems: [RegistryItem]) -> Int {
        guard !registryItems.isEmpty else { return 0 }
        return userSections(from: registryItems)
            .flatMap(\.products)
            .filter(\.isPurchased)
            .reduce(0) { $0 + $1.quantity }
    }

    static func completionText(from registryItems: [RegistryItem]) -> String {
        let total = totalItems(from: registryItems)
        guard total > 0 else { return "0%" }
        let completed = Double(purchasedItems(from: registryItems)) / Double(total) * 100
        return "\(Int(completed.rounded()))%"
    }

    private static func userSections(from registryItems: [RegistryItem]) -> [RegistryDetailSection] {
        let grouped = Dictionary(grouping: registryItems) { $0.collectionName ?? "My Registry" }
        let tintPalette: [Color] = [WSRegistryPalette.sage, WSRegistryPalette.gold, WSRegistryPalette.cocoa]
        return grouped
            .keys
            .sorted()
            .enumerated()
            .map { index, collection in
                let items = grouped[collection] ?? []
                return RegistryDetailSection(
                    title: collection,
                    itemCount: items.reduce(0) { $0 + $1.quantity },
                    tint: tintPalette[index % tintPalette.count],
                    products: items.map { RegistryDisplayProduct(item: $0) }
                )
            }
    }
}

private struct RegistryDetailSection: Identifiable {
    let id = UUID()
    let title: String
    let itemCount: Int
    let tint: Color
    let products: [RegistryDisplayProduct]

    var progress: CGFloat {
        guard !products.isEmpty else { return 0.1 }
        let totalQuantity = products.reduce(0) { $0 + $1.quantity }
        guard totalQuantity > 0 else { return 0.2 }
        let purchasedQuantity = products
            .filter(\.isPurchased)
            .reduce(0) { $0 + $1.quantity }
        if purchasedQuantity == 0 { return 0.2 }
        return min(1.0, max(0.2, CGFloat(purchasedQuantity) / CGFloat(totalQuantity)))
    }

    static let samples: [RegistryDetailSection] = [
        RegistryDetailSection(
            title: "Daily Cooking",
            itemCount: 12,
            tint: WSRegistryPalette.sage,
            products: [
                RegistryDisplayProduct(brand: "Le Creuset", name: "Signature Dutch Oven", detail: "7.25 Qt.", priceText: "$420.00", imagePath: "/img122m.jpg", isPurchased: true, purchaserName: "Emma Williams"),
                RegistryDisplayProduct(brand: "Wusthof", name: "Classic 8-Piece Knife Set", priceText: "$450.00", imagePath: "/img17m.jpg"),
                RegistryDisplayProduct(brand: "Vitamix", name: "A3500 Ascent Series Blender", priceText: "$699.95", imagePath: "/img83m.jpg")
            ]
        ),
        RegistryDetailSection(
            title: "Hosting",
            itemCount: 18,
            tint: WSRegistryPalette.gold,
            products: [
                RegistryDisplayProduct(brand: "Staub", name: "Serving Bowl Set", detail: "(4-piece)", priceText: "$179.95", imagePath: "/img64m.jpg", isPurchased: true, purchaserName: "John Smith"),
                RegistryDisplayProduct(brand: "Marimekko", name: "Oiva Serving Platter", priceText: "$69.00", imagePath: "/img42m.jpg"),
                RegistryDisplayProduct(brand: "LSA International", name: "Wine Carafe", priceText: "$89.00", imagePath: "/img95m.jpg", isPurchased: true, purchaserName: "Olivia Johnson")
            ]
        ),
        RegistryDetailSection(
            title: "Shared Dining",
            itemCount: 22,
            tint: WSRegistryPalette.cocoa,
            products: [
                RegistryDisplayProduct(brand: "Crate & Barrel", name: "Marin Dinner Plate", priceText: "$14.95", imagePath: "/img5m.jpg"),
                RegistryDisplayProduct(brand: "Crate & Barrel", name: "Marin Salad Plate", priceText: "$11.95", imagePath: "/img23m.jpg"),
                RegistryDisplayProduct(brand: "Zwiesel Glas", name: "All Purpose Glass", priceText: "$59.95", imagePath: "/img4m.jpg")
            ]
        )
    ]
}

private struct RegistryDisplayProduct: Identifiable {
    let id: String
    let brand: String
    let name: String
    let detail: String?
    let priceText: String
    let numericPrice: Double
    let imagePath: String?
    let imageURL: URL?
    let isPurchased: Bool
    let purchaserName: String?
    let collectionName: String?
    let quantity: Int

    var statusDetailText: String {
        if let purchaserName {
            return "Purchased by \(purchaserName) on May 12, 2024"
        }
        return "Still available for guests to purchase."
    }

    var purchaserInitials: String {
        guard let purchaserName else { return "" }
        let initials = purchaserName
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()
        return initials.isEmpty ? "G" : initials
    }

    init(
        id: String? = nil,
        brand: String,
        name: String,
        detail: String? = nil,
        priceText: String,
        imagePath: String,
        isPurchased: Bool = false,
        purchaserName: String? = nil,
        collectionName: String? = nil,
        quantity: Int = 1
    ) {
        self.id = id ?? "\(brand)-\(name)"
        self.brand = brand
        self.name = name
        self.detail = detail
        self.priceText = priceText
        self.numericPrice = RegistryDisplayProduct.parsePrice(priceText) ?? 0
        self.imagePath = imagePath
        self.imageURL = URL(string: AppConstants.API.imageBasePath + imagePath)
        self.isPurchased = isPurchased
        self.purchaserName = purchaserName
        self.collectionName = collectionName
        self.quantity = max(1, quantity)
    }

    init(item: RegistryItem) {
        self.id = item.id
        self.brand = "WSI Curated"
        self.name = item.name
        self.detail = nil
        self.priceText = item.price.formatted(.currency(code: "USD"))
        self.numericPrice = item.price
        self.imagePath = item.imageUrl
        self.imageURL = URL(string: AppConstants.API.imageBasePath + item.imageUrl)
        self.isPurchased = false
        self.purchaserName = nil
        self.collectionName = item.collectionName
        self.quantity = max(1, item.quantity)
    }

    private static func parsePrice(_ priceText: String) -> Double? {
        let clean = priceText.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        return Double(clean)
    }
}

private struct RegistrySummaryItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let subtitle: String
    let status: String
    let tint: Color

    static func from(registryItems: [RegistryItem]) -> [RegistrySummaryItem] {
        guard !registryItems.isEmpty else {
            return [
                RegistrySummaryItem(
                    title: "Registry Ready",
                    systemImage: "sparkles",
                    subtitle: "Start adding gifts from recommendations, essentials, or your own picks.",
                    status: "Start",
                    tint: WSRegistryPalette.gold
                )
            ]
        }

        let grouped = Dictionary(grouping: registryItems) { $0.collectionName ?? "My Registry" }
        let sorted = grouped.keys.sorted()
        let palette: [Color] = [WSRegistryPalette.sage, WSRegistryPalette.gold, WSRegistryPalette.cocoa]

        return sorted.enumerated().map { index, name in
            let items = grouped[name] ?? []
            let count = items.reduce(0) { $0 + $1.quantity }
            let status = count >= 6 ? "Established" : (count >= 3 ? "Growing" : "Starting")
            return RegistrySummaryItem(
                title: name,
                systemImage: icon(for: name),
                subtitle: "\(count) item\(count == 1 ? "" : "s") saved in this collection.",
                status: status,
                tint: palette[index % palette.count]
            )
        }
        .prefix(4)
        .map { $0 }
    }

    private static func icon(for collection: String) -> String {
        let normalized = collection.lowercased()
        if normalized.contains("cook") || normalized.contains("kitchen") { return "frying.pan" }
        if normalized.contains("host") { return "wineglass" }
        if normalized.contains("dining") || normalized.contains("table") { return "fork.knife" }
        if normalized.contains("morning") || normalized.contains("coffee") { return "cup.and.saucer" }
        return "square.grid.2x2"
    }

    static let samples: [RegistrySummaryItem] = [
        RegistrySummaryItem(
            title: "Daily Cooking",
            systemImage: "frying.pan",
            subtitle: "Your registry strongly supports everyday cooking and shared meal preparation.",
            status: "Strong\nFoundation",
            tint: WSRegistryPalette.sage
        ),
        RegistrySummaryItem(
            title: "Hosting",
            systemImage: "wineglass",
            subtitle: "You are building a great start. Add a few more essentials to host with ease and confidence.",
            status: "Growing",
            tint: WSRegistryPalette.gold
        ),
        RegistrySummaryItem(
            title: "Shared Dining",
            systemImage: "fork.knife",
            subtitle: "Consider adding pieces for shared meals and memorable gatherings.",
            status: "Needs\nAttention",
            tint: WSRegistryPalette.cocoa
        ),
        RegistrySummaryItem(
            title: "Morning Rituals",
            systemImage: "cup.and.saucer",
            subtitle: "You are creating a cozy start to your day.",
            status: "Developing",
            tint: WSRegistryPalette.sage
        )
    ]
}
