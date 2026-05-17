//
//  RegistryView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

enum RegistryRoute: Hashable {
    case create
    case success
    case details
    case findRegistry
    case pastRegistries
    case existingRegistryDetails
    case categoryProducts(String)
}

enum WSRegistryPalette {
    static let ivory = Color(red: 0.975, green: 0.956, blue: 0.922)
    static let cream = Color(red: 0.992, green: 0.984, blue: 0.962)
    static let porcelain = Color(red: 0.998, green: 0.996, blue: 0.988)
    static let espresso = Color(red: 0.185, green: 0.125, blue: 0.086)
    static let cocoa = Color(red: 0.355, green: 0.260, blue: 0.188)
    static let gold = Color(red: 0.680, green: 0.545, blue: 0.285)
    static let sage = Color(red: 0.475, green: 0.545, blue: 0.420)
    static let warmGray = Color(red: 0.500, green: 0.470, blue: 0.425)
    static let hairline = Color(red: 0.855, green: 0.825, blue: 0.770)
}

struct RegistryView: View {

    @StateObject private var viewModel = RegistryViewModel()

    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel

    var body: some View {
        NavigationStack(path: $tabBarVM.registryPath) {
            ZStack {
                WSRegistryPalette.ivory
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        heroImage
                        primaryCTACard
                        if viewModel.hasRegistry {
                            registrySummaryCard
                        }
                        secondaryActions
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.espresso)
                            .frame(width: 36, height: 36)
                            .background(WSRegistryPalette.porcelain, in: Circle())
                            .overlay(
                                Circle()
                                    .stroke(WSRegistryPalette.hairline.opacity(0.55), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Notifications")
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
                case .existingRegistryDetails:
                    ExistingRegistryDetailsView(registry: ExistingRegistry.gayatri)
                case .categoryProducts(let title):
                    RegistryCategoryProductsView(sectionTitle: title)
                }
            }
        }
        .onAppear {
            viewModel.bind(repository: registryRepo)
        }
    }
}

private extension RegistryView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("WILLIAMS SONOMA")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .tracking(1.8)
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            VStack(alignment: .leading, spacing: 8) {
                Text("Home Registry")
                    .font(.system(size: 39, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineSpacing(1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text("Build the home you’ll grow into.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    var heroImage: some View {
        GeometryReader { proxy in
            Image("giftdna_living_room")
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: 218)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: WSRegistryPalette.espresso.opacity(0.10), radius: 18, x: 0, y: 10)
        }
        .frame(height: 218)
        .frame(maxWidth: .infinity)
    }

    var primaryCTACard: some View {
        Button {
            tabBarVM.registryPath.append(RegistryRoute.create)
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                    .frame(width: 48, height: 48)
                    .background(WSRegistryPalette.cream.opacity(0.10), in: Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text("Start Your Home Profile")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.cream)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    Text("Create your intelligent registry")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cream.opacity(0.72))
                        .lineLimit(1)
                        .minimumScaleFactor(0.88)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.gold)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
            .background {
                LinearGradient(
                    colors: [
                        WSRegistryPalette.espresso,
                        Color(red: 0.245, green: 0.165, blue: 0.110),
                        WSRegistryPalette.cocoa
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(WSRegistryPalette.gold.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: WSRegistryPalette.espresso.opacity(0.18), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    var registrySummaryCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Your Registry")
                        .font(.system(size: 23, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(1)
                        .minimumScaleFactor(0.86)
                }

                Spacer(minLength: 8)

                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.gold)
                    .padding(.top, 2)
            }

            VStack(spacing: 0) {
                ForEach(Array(RegistrySummaryItem.samples.enumerated()), id: \.element.id) { index, item in
                    registrySummaryRow(item)

                    if index < RegistrySummaryItem.samples.count - 1 {
                        Divider()
                            .overlay(WSRegistryPalette.hairline.opacity(0.48))
                            .padding(.leading, 64)
                    }
                }
            }

            Button {
                tabBarVM.registryPath.append(RegistryRoute.details)
            } label: {
                HStack(spacing: 12) {
                    Spacer()

                    Text("View Registry")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.cream)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.cream.opacity(0.78))
                }
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity, minHeight: 56)
                .background {
                    LinearGradient(
                        colors: [
                            WSRegistryPalette.espresso,
                            Color(red: 0.245, green: 0.165, blue: 0.110)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("View Registry")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.50), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.05), radius: 16, x: 0, y: 8)
    }

    func registrySummaryRow(_ item: RegistrySummaryItem) -> some View {
        Button {
        } label: {
            HStack(spacing: 13) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(item.tint)
                    .frame(width: 50, height: 50)
                    .background(item.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

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
                    .background(item.tint.opacity(0.13), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

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
                title: "Find a Registry",
                subtitle: "Search by name or email"
            ) {
                tabBarVM.registryPath.append(RegistryRoute.findRegistry)
            }
            actionRow(
                icon: "heart.text.square",
                title: "View Past Registry",
                subtitle: "View and track your past registry"
            ) {
                tabBarVM.registryPath.append(RegistryRoute.pastRegistries)
            }
        }
    }

    func actionRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .frame(width: 42, height: 42)
                    .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .lineLimit(2)
                }

                Spacer(minLength: 10)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.65))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .stroke(WSRegistryPalette.hairline.opacity(0.55), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}


private struct ExistingRegistry: Identifiable, Hashable {
    let id = UUID()
    let coupleName: String
    let email: String
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

    static let gayatri = ExistingRegistry(
        coupleName: "Priya & Arjun",
        email: "priya.com",
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
            coupleName: "Priya’s Housewarming",
            email: "priya.com",
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
            coupleName: "Engagement Celebration",
            email: "priya.com",
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
            coupleName: "Holiday Registry",
            email: "priya.com",
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
    @State private var selectedFilter = "All"

    private let filters = ["All", "Completed", "Archived"]

    private var visibleRegistries: [ExistingRegistry] {
        ExistingRegistry.pastSamples.filter { registry in
            selectedFilter == "All" || registry.status == selectedFilter
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
                Text("Your Past Registries")
                    .font(.system(size: 30, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text("View and track your previous celebrations and purchases.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.86))
                    .lineSpacing(3)
                    .frame(maxWidth: 250, alignment: .leading)
            }
            .padding(.leading, 16)
        }
        .frame(height: 176)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(WSRegistryPalette.porcelain.opacity(0.92), in: Capsule())
        .overlay(Capsule().stroke(WSRegistryPalette.hairline.opacity(0.38), lineWidth: 1))
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
            tabBarVM.registryPath.append(RegistryRoute.existingRegistryDetails)
        } label: {
            HStack(spacing: 14) {
                Image("giftdna_living_room")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 118, height: 132)
                    .offset(x: CGFloat(-imageOffset * 16))
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

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
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1))
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
                Text("Can’t find an old registry?")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                Text("If your past registry isn’t listed here, it may have been archived.")
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
        .background(WSRegistryPalette.cream, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}


private struct FindRegistryView: View {
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @State private var searchText = ""
    @State private var selectedFilter = "All"

    private let filters = ["All", "My Friends", "Family", "By Name", "By Email"]
    private let registries = [ExistingRegistry.gayatri]

    private var visibleRegistries: [ExistingRegistry] {
        registries.filter { $0.matches(searchText) }
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
        .navigationTitle("Find a Registry")
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
        .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
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
                                in: RoundedRectangle(cornerRadius: 9, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .stroke(WSRegistryPalette.hairline.opacity(0.55), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptySearchState: some View {
        Text("No registry found for that search.")
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(WSRegistryPalette.warmGray)
            .frame(maxWidth: .infinity, minHeight: 96)
            .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func existingRegistryRow(_ registry: ExistingRegistry) -> some View {
        Button {
            tabBarVM.registryPath.append(RegistryRoute.existingRegistryDetails)
        } label: {
            HStack(spacing: 12) {
                Image("giftdna_living_room")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 86, height: 86)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

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

                Text("View")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cream)
                    .frame(width: 70, height: 44)
                    .background(WSRegistryPalette.espresso, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
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
        .navigationTitle("Registry Summary")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(WSRegistryPalette.ivory, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { } label: {
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
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1))
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

                Button("View Note") { }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.gold)
            }
        }
        .padding(20)
        .background(WSRegistryPalette.cream, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var overviewCard: some View {
        summarySection(title: "Registry Overview") {
            summaryRow(icon: "clipboard", title: "View All Items", detail: registry.itemCount + " Items")
            summaryRow(icon: "bag", title: "Purchased Items", detail: registry.purchasedCount + " Items")
            summaryRow(icon: "gift", title: "Contributions", detail: "18 Gifts")
            summaryRow(icon: "square.grid.2x2", title: "Collections", detail: "12 Collections", showDivider: false)
        }
    }

    private var activityCard: some View {
        summarySection(title: "Activity Summary") {
            HStack(spacing: 14) {
                Image(systemName: "gift")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.gold)
                    .frame(width: 44, height: 44)
                    .background(WSRegistryPalette.gold.opacity(0.12), in: Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text("Most contributed to")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                    Text("Kitchen Essentials")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }
                Spacer()
                Text("12 Gifts")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
            }
        }
    }

    private var timelineCard: some View {
        summarySection(title: "Registry Timeline") {
            summaryRow(icon: "calendar.badge.plus", title: "Created on", detail: "April 20, 2024")
            summaryRow(icon: "calendar.badge.checkmark", title: "Completed on", detail: registry.eventDate, showDivider: false)
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
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1))
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
    @EnvironmentObject var tabBarVM: WSTabBarViewModel

    private var registryItems: [RegistryItem] {
        registryRepo.currentRegistry?.items ?? []
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

    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    homeStoryCard
                    statsCard
                    addItemsButton
                    ForEach(sections) { section in
                        registrySection(section)
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
                Button {
                } label: {
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
        HStack(alignment: .top, spacing: 18) {
            Image("giftdna_living_room")
                .resizable()
                .scaledToFill()
                .frame(width: 112, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 14) {
                Text("Your Home Story")
                    .font(.system(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text("A warm, social home centered around shared meals, intimate hosting, and slow mornings together.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.86))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var statsCard: some View {
        HStack(spacing: 0) {
            statItem(value: "\(totalItems)", label: "Items")
            divider
            statItem(value: "\(totalCollections)", label: "Collections")
            divider
            statItem(value: "\(purchasedItems)", label: "Purchased")
            divider
            statItem(value: completionText, label: "Completed")
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.48), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.05), radius: 12, x: 0, y: 6)
    }

    private var addItemsButton: some View {
        Button {
            tabBarVM.selectTab(.home)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                Text("Add items to your registry")
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundStyle(WSRegistryPalette.porcelain)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
            .background(WSRegistryPalette.espresso, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: WSRegistryPalette.espresso.opacity(0.16), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add items to your registry")
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
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Text("\(section.itemCount) Items")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(section.tint)
                }

                Spacer()

                Button("View All") {
                    tabBarVM.registryPath.append(RegistryRoute.categoryProducts(section.title))
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.gold)
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 3),
                alignment: .leading,
                spacing: 14
            ) {
                ForEach(section.products.prefix(3)) { product in
                    registryProductCard(product)
                }
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
        VStack(alignment: .leading, spacing: 8) {
            CustomAsyncImage(url: product.imageURL)
                .frame(height: 138)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(product.brand)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(product.name)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.88))
                .lineLimit(2)
                .minimumScaleFactor(0.76)

            Text(product.priceText)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(WSRegistryPalette.espresso)
        }
    }
}


private struct RegistryCategoryProductsView: View {
    let sectionTitle: String
    @EnvironmentObject var registryRepo: RegistryRepository
    @State private var selectedProduct: RegistryDisplayProduct?
    @State private var removedProductIDs = Set<String>()

    private var registryItems: [RegistryItem] {
        registryRepo.currentRegistry?.items ?? []
    }

    private var products: [RegistryDisplayProduct] {
        RegistryDetailContent.sections(from: registryItems)
            .flatMap(\.products)
            .filter { !removedProductIDs.contains($0.id) }
    }

    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    listToolbar

                    ForEach(products) { product in
                        registryProductListRow(product)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Registry Items")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedProduct) { product in
            RegistryProductActionSheet(
                product: product,
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
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(WSRegistryPalette.espresso)
            }

            Spacer(minLength: 8)
        }
        .padding(.bottom, 14)
    }

    private func registryProductListRow(_ product: RegistryDisplayProduct) -> some View {
        Button {
            selectedProduct = product
        } label: {
            HStack(spacing: 10) {
                CustomAsyncImage(url: product.imageURL)
                    .frame(width: 86, height: 86)
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                VStack(alignment: .leading, spacing: 7) {
                    Text(product.brand)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(1)

                    Text(product.name)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.86))
                        .lineLimit(2)

                    if let detail = product.detail {
                        Text(detail)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.86))
                            .lineLimit(1)
                    }

                    Text(product.priceText)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text(product.isPurchased ? "Purchased" : "Unpurchased")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(product.isPurchased ? WSRegistryPalette.sage : WSRegistryPalette.cocoa)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(
                            (product.isPurchased ? WSRegistryPalette.sage.opacity(0.14) : WSRegistryPalette.gold.opacity(0.14)),
                            in: Capsule()
                        )

                    if product.isPurchased, let purchaserName = product.purchaserName {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Purchased by")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.86))
                                .lineLimit(1)

                            HStack(spacing: 6) {
                                Text(product.purchaserInitials)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(WSRegistryPalette.porcelain)
                                    .frame(width: 24, height: 24)
                                    .background(WSRegistryPalette.cocoa.opacity(0.72), in: Circle())

                                Text(purchaserName)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.9))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.72)
                            }
                        }
                    }
                }
                .frame(width: 92, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso.opacity(0.85))
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .overlay(
                Rectangle()
                    .fill(WSRegistryPalette.hairline.opacity(0.45))
                    .frame(height: 1)
                    .padding(.leading, 98),
                alignment: .bottom
            )
        }
        .buttonStyle(.plain)
    }
}

private struct RegistryProductActionSheet: View {
    let product: RegistryDisplayProduct
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
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

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
            Button("Daily Cooking") { collection = "Daily Cooking" }
            Button("Hosting") { collection = "Hosting" }
            Button("Shared Dining") { collection = "Shared Dining" }
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
        .background(WSRegistryPalette.ivory.opacity(0.68), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
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
                .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(WSRegistryPalette.hairline.opacity(0.9), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}


private enum RegistryDetailContent {
    static func sections(from registryItems: [RegistryItem]) -> [RegistryDetailSection] {
        guard !registryItems.isEmpty else { return RegistryDetailSection.samples }
        return userSections(from: registryItems) + RegistryDetailSection.samples.dropFirst()
    }

    static func totalItems(from registryItems: [RegistryItem]) -> Int {
        registryItems.reduce(0) { $0 + $1.quantity }
    }

    static func collectionCount(from registryItems: [RegistryItem]) -> Int {
        guard !registryItems.isEmpty else { return 0 }
        return userSections(from: registryItems).filter { !$0.products.isEmpty }.count
    }

    static func purchasedItems(from registryItems: [RegistryItem]) -> Int {
        guard !registryItems.isEmpty else { return 0 }
        return userSections(from: registryItems)
            .flatMap(\.products)
            .filter(\.isPurchased)
            .count
    }

    static func completionText(from registryItems: [RegistryItem]) -> String {
        let total = totalItems(from: registryItems)
        guard total > 0 else { return "0%" }
        let completed = Double(purchasedItems(from: registryItems)) / Double(total) * 100
        return "\(Int(completed.rounded()))%"
    }

    private static func userSections(from registryItems: [RegistryItem]) -> [RegistryDetailSection] {
        [
            RegistryDetailSection(
                title: "Daily Cooking",
                itemCount: registryItems.reduce(0) { $0 + $1.quantity },
                tint: WSRegistryPalette.sage,
                products: registryItems.map { RegistryDisplayProduct(item: $0) }
            )
        ]
    }
}

private struct RegistryDetailSection: Identifiable {
    let id = UUID()
    let title: String
    let itemCount: Int
    let tint: Color
    let products: [RegistryDisplayProduct]

    var progress: CGFloat {
        switch title {
        case "Daily Cooking": return 0.38
        case "Hosting": return 0.30
        case "Shared Dining": return 0.22
        default: return 0.34
        }
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
    let imageURL: URL?
    let isPurchased: Bool
    let purchaserName: String?

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
        purchaserName: String? = nil
    ) {
        self.id = id ?? "\(brand)-\(name)"
        self.brand = brand
        self.name = name
        self.detail = detail
        self.priceText = priceText
        self.imageURL = URL(string: AppConstants.API.imageBasePath + imagePath)
        self.isPurchased = isPurchased
        self.purchaserName = purchaserName
    }

    init(item: RegistryItem) {
        let parts = item.name.split(separator: " ", maxSplits: 1).map(String.init)
        self.id = item.id
        self.brand = parts.first ?? "Williams Sonoma"
        self.name = parts.count > 1 ? parts[1] : item.name
        self.detail = nil
        self.priceText = item.price.formatted(.currency(code: "USD"))
        self.imageURL = URL(string: AppConstants.API.imageBasePath + item.imageUrl)
        self.isPurchased = false
        self.purchaserName = nil
    }
}

private struct RegistrySummaryItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let subtitle: String
    let status: String
    let tint: Color

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
