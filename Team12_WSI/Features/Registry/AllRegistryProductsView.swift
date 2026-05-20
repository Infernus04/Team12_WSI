import SwiftUI

// MARK: - All Registry Products View

struct AllRegistryProductsView: View {
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository

    @State private var searchText = ""
    @State private var sortOption: SortOption = .recentlyAdded

    private enum SortOption: String, CaseIterable {
        case recentlyAdded = "Recently Added"
        case priceLowHigh = "Price: Low → High"
        case priceHighLow = "Price: High → Low"
        case purchased = "Purchased First"
        case nameAZ = "Name: A → Z"
    }

    private var registryItems: [RegistryItem] {
        var items = registryRepo.currentRegistry?.items ?? []

        // Filter
        if !searchText.isEmpty {
            items = items.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Sort
        switch sortOption {
        case .recentlyAdded:
            break // keep original order
        case .priceLowHigh:
            items.sort { $0.price < $1.price }
        case .priceHighLow:
            items.sort { $0.price > $1.price }
        case .purchased:
            items.sort { ($0.isPurchased ? 0 : 1) < ($1.isPurchased ? 0 : 1) }
        case .nameAZ:
            items.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        }

        return items
    }

    private var totalValue: Double {
        registryItems.reduce(0) { $0 + $1.price * Double($1.quantity) }
    }

    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Summary bar
                    summaryBar

                    // Search
                    searchBar

                    // Product list
                    LazyVStack(spacing: 0) {
                        ForEach(Array(registryItems.enumerated()), id: \.element.id) { index, item in
                            productRow(item: item, isLast: index == registryItems.count - 1)
                        }
                    }
                    .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(WSRegistryPalette.hairline.opacity(0.48), lineWidth: 1)
                    )
                    .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 18)
                }
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("All Items")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                sortMenu
            }
        }
    }

    // MARK: - Summary Bar

    private var summaryBar: some View {
        HStack(spacing: 0) {
            summaryItem(value: "\(registryItems.count)", label: "Items")
            summaryDivider
            summaryItem(value: "$\(Int(totalValue))", label: "Total Value")
            summaryDivider
            let collections = Set(registryItems.compactMap(\.collectionName)).count
            summaryItem(value: "\(collections)", label: "Collections")
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(
            LinearGradient(
                colors: [WSRegistryPalette.ivory, Color(red: 0.98, green: 0.96, blue: 0.93)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    private func summaryItem(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(WSRegistryPalette.warmGray)
        }
        .frame(maxWidth: .infinity)
    }

    private var summaryDivider: some View {
        Rectangle()
            .fill(WSRegistryPalette.hairline.opacity(0.6))
            .frame(width: 1, height: 32)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(WSRegistryPalette.warmGray)
            TextField("Search items...", text: $searchText)
                .font(.system(size: 15))
                .foregroundStyle(WSRegistryPalette.espresso)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.4), lineWidth: 1)
        )
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    // MARK: - Sort Menu

    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    sortOption = option
                } label: {
                    HStack {
                        Text(option.rawValue)
                        if sortOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 13, weight: .semibold))
                Text("Sort")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(WSRegistryPalette.gold)
        }
    }

    // MARK: - Product Row

    private func productRow(item: RegistryItem, isLast: Bool) -> some View {
        let isPurchased = item.isPurchased

        return VStack(spacing: 0) {
            HStack(spacing: 14) {
                // Purchase indicator
                Image(systemName: isPurchased ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(isPurchased ? WSRegistryPalette.sage : WSRegistryPalette.hairline)

                // Product image
                CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + item.imageUrl))
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        if let collection = item.collectionName {
                            Text(collection)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(WSRegistryPalette.warmGray)
                                .lineLimit(1)
                            Text("·")
                                .foregroundStyle(WSRegistryPalette.hairline)
                        }
                        Text("Qty: \(item.quantity)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                    }
                }

                Spacer(minLength: 8)

                // Price + status
                VStack(alignment: .trailing, spacing: 4) {
                    Text(item.price.formatted(.currency(code: "USD")))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso)

                    if isPurchased {
                        Text("Purchased")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(WSRegistryPalette.sage, in: Capsule())
                    } else {
                        Text("Available")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if !isLast {
                Divider()
                    .padding(.leading, 52)
                    .padding(.trailing, 16)
            }
        }
    }
}
