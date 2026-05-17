import SwiftUI

// MARK: - Registry Activity View

struct RegistryActivityView: View {
    @EnvironmentObject var registryRepo: RegistryRepository
    @State private var selectedFilter = "All"

    private let filters = ["All", "Added", "Removed", "Purchased", "Updated"]

    private var filteredActivities: [RegistryActivity] {
        if selectedFilter == "All" { return registryRepo.activities }
        return registryRepo.activities.filter { $0.type.filterCategory == selectedFilter }
    }

    private var groupedActivities: [(key: String, activities: [RegistryActivity])] {
        let grouped = Dictionary(grouping: filteredActivities) { $0.dateGroupKey }
        let order = ["Today", "Yesterday", "This Week", "Earlier"]
        return order.compactMap { key in
            guard let acts = grouped[key], !acts.isEmpty else { return nil }
            return (key: key, activities: acts)
        }
    }

    var body: some View {
        ZStack {
            WSRegistryPalette.ivory.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    heroHeader
                    summaryStats
                    filterTabs

                    if filteredActivities.isEmpty {
                        emptyState
                    } else {
                        ForEach(groupedActivities, id: \.key) { group in
                            dateGroupSection(group.key, activities: group.activities)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 120)
            }
            .scrollClipDisabled(false)
        }
        .navigationTitle("Registry Activity")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }

    // MARK: Hero

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("ACTIVITY")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(2.2)
                    .foregroundStyle(WSRegistryPalette.gold)
            }

            Text("Registry\nChronicle")
                .font(.system(size: 36, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineSpacing(2)

            Text("Every addition, removal, and purchase — tracked in one place.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Stats

    private var summaryStats: some View {
        let added = registryRepo.activities.filter { $0.type == .added || $0.type == .bundleAdded }.count
        let purchased = registryRepo.activities.filter { $0.type == .purchased }.count
        let removed = registryRepo.activities.filter { $0.type == .removed }.count

        return HStack(spacing: 0) {
            activityStat(value: "\(registryRepo.activities.count)", label: "Total")
            activityDivider
            activityStat(value: "\(added)", label: "Added")
            activityDivider
            activityStat(value: "\(purchased)", label: "Purchased")
            activityDivider
            activityStat(value: "\(removed)", label: "Removed")
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.48), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.05), radius: 14, x: 0, y: 8)
    }

    private func activityStat(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso)
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
    }

    private var activityDivider: some View {
        Rectangle()
            .fill(WSRegistryPalette.hairline.opacity(0.55))
            .frame(width: 1, height: 42)
    }

    // MARK: Filter

    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.86)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(selectedFilter == filter ? WSRegistryPalette.cream : WSRegistryPalette.espresso)
                            .padding(.horizontal, 16)
                            .frame(height: 36)
                            .background(
                                selectedFilter == filter ? WSRegistryPalette.espresso : WSRegistryPalette.porcelain,
                                in: Capsule()
                            )
                            .overlay(
                                Capsule().stroke(
                                    selectedFilter == filter ? Color.clear : WSRegistryPalette.hairline.opacity(0.5),
                                    lineWidth: 1
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Date Group

    private func dateGroupSection(_ title: String, activities: [RegistryActivity]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)

            VStack(spacing: 0) {
                ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
                    activityTimelineRow(activity, isLast: index == activities.count - 1)
                }
            }
            .padding(14)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1)
            )
        }
    }

    private func activityTimelineRow(_ activity: RegistryActivity, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(activity.type.accentColor.opacity(0.18))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: activity.type.systemImage)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(activity.type.accentColor)
                    )
                if !isLast {
                    Rectangle()
                        .fill(WSRegistryPalette.hairline.opacity(0.45))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text(activity.productName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(2)
                    Spacer(minLength: 8)
                    Text(activity.relativeTimeText)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                }

                Text(activity.detail)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.82))
                    .lineLimit(2)

                HStack(spacing: 6) {
                    Text(activity.type.displayLabel.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(activity.type.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(activity.type.accentColor.opacity(0.12), in: Capsule())

                    if let collection = activity.collectionName {
                        Text(collection)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                    }
                }
            }
            .padding(.bottom, isLast ? 0 : 16)
        }
    }

    // MARK: Empty

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 38, weight: .light))
                .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.5))
            Text("No activity yet for this filter.")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
