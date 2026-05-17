import SwiftUI

// MARK: - Home Chronicle View

struct HomeChronicleView: View {
    @StateObject private var viewModel = HomeChronicleViewModel()

    var body: some View {
        ZStack {
            WSRegistryPalette.ivory.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
            } else {
                chronicleContent
            }
        }
        .navigationTitle("Home Chronicle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            viewModel.loadChronicle()
        }
    }
}

// MARK: - Content

private extension HomeChronicleView {
    var chronicleContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                heroHeader
                summaryStats
                replacementAlertsSection
                roomGapsSection
                timelineSection
                completeBundleSection
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .padding(.bottom, 120)
        }
        .scrollClipDisabled(false)
    }

    // MARK: Hero Header

    var heroHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("CHRONICLE")
                    .font(.system(size: 13, weight: .bold))
                    .tracking(2.2)
                    .foregroundStyle(WSRegistryPalette.gold)
            }

            Text("Your Home\nOver Time")
                .font(.system(size: 36, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineSpacing(2)

            Text("Track what you own, when things need replacing, and where your home has gaps.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Summary Stats

    var summaryStats: some View {
        HStack(spacing: 0) {
            chronicleStat(
                value: "\(viewModel.timelineResponse?.summary.totalItemsTracked ?? 0)",
                label: "Items Tracked"
            )
            chronicleDivider
            chronicleStat(
                value: "\(viewModel.timelineResponse?.summary.brandsCovered.count ?? 0)",
                label: "Brands"
            )
            chronicleDivider
            chronicleStat(
                value: "\(viewModel.timelineResponse?.summary.roomsDetected.count ?? 0)",
                label: "Rooms"
            )
            chronicleDivider
            chronicleStat(
                value: "\(viewModel.replacementAlerts.count)",
                label: "Alerts"
            )
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.48), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.05), radius: 14, x: 0, y: 8)
    }

    func chronicleStat(value: String, label: String) -> some View {
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

    var chronicleDivider: some View {
        Rectangle()
            .fill(WSRegistryPalette.hairline.opacity(0.55))
            .frame(width: 1, height: 42)
    }

    // MARK: Replacement Alerts

    var replacementAlertsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "exclamationmark.triangle", title: "Replacement Alerts")

            if viewModel.replacementAlerts.isEmpty {
                emptyStateCard("All items are within their expected lifespan. Nothing to replace yet.")
            } else {
                ForEach(viewModel.replacementAlerts) { alert in
                    replacementAlertCard(alert)
                }
            }
        }
    }

    func replacementAlertCard(_ alert: ReplacementAlert) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(viewModel.urgencyColor(alert.urgencyLabel).opacity(0.18))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: alert.urgencyLabel == "Ready to Replace" ? "arrow.triangle.2.circlepath" : "eye")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(viewModel.urgencyColor(alert.urgencyLabel))
                )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(alert.productName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text(alert.urgencyLabel)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(viewModel.urgencyColor(alert.urgencyLabel))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(viewModel.urgencyColor(alert.urgencyLabel).opacity(0.14), in: Capsule())
                }

                Text("\(alert.ageMonths) months old • Expected lifespan: \(alert.expectedLifespanMonths) months")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)

                // Progress bar
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(WSRegistryPalette.hairline.opacity(0.3))
                        Capsule()
                            .fill(viewModel.urgencyColor(alert.urgencyLabel))
                            .frame(width: proxy.size.width * min(1.0, alert.replacementScore))
                    }
                }
                .frame(height: 4)

                Text(alert.recommendationText)
                    .font(.system(size: 13, weight: .regular))
                    .italic()
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.78))
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1)
        )
    }

    // MARK: Room Gaps

    var roomGapsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "square.grid.2x2", title: "Room & Category Gaps")

            if viewModel.roomGaps.isEmpty {
                emptyStateCard("Your home coverage looks complete across all target rooms.")
            } else {
                ForEach(viewModel.roomGaps) { gap in
                    roomGapCard(gap)
                }
            }
        }
    }

    func roomGapCard(_ gap: RoomGapSignal) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: roomIcon(for: gap.room))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                    .frame(width: 40, height: 40)
                    .background(WSRegistryPalette.gold.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(gap.room.rawValue.capitalized)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Text(gap.recommendationReason)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }

            // Missing categories
            HStack(spacing: 8) {
                ForEach(gap.missingCategories, id: \.self) { cat in
                    Text(cat)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.cocoa)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(WSRegistryPalette.cream, in: Capsule())
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1)
        )
    }

    // MARK: Timeline

    var timelineSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "calendar", title: "Purchase Timeline")

            if let timeline = viewModel.timelineResponse?.timeline {
                ForEach(timeline, id: \.year) { section in
                    yearSection(section)
                }
            }
        }
    }

    func yearSection(_ section: ChronicleTimelineSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(String(section.year))")
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)

            ForEach(section.entries) { entry in
                timelineEntry(entry)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.42), lineWidth: 1)
        )
    }

    func timelineEntry(_ entry: ChroniclePurchaseRecord) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(WSRegistryPalette.gold.opacity(0.18))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.productName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(viewModel.brandDisplayName(entry.brand))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)

                    Text("•")
                        .foregroundStyle(WSRegistryPalette.hairline)

                    Text(entry.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                }
            }

            Spacer(minLength: 0)

            Text(entry.unitPrice.formatted(.currency(code: "USD")))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.espresso)
        }
        .padding(.vertical, 4)
    }

    // MARK: Complete Your Home Bundle

    var completeBundleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(icon: "house.fill", title: "Complete Your Home")

            if let bundle = viewModel.completeBundle {
                VStack(alignment: .leading, spacing: 16) {
                    Text(bundle.title)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)

                    Text(bundle.rationale)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.86))
                        .lineSpacing(4)

                    VStack(spacing: 8) {
                        bundlePriceRow("Estimated Total", value: bundle.estimatedTotal)
                        bundlePriceRow("Store Credit Applied", value: -bundle.appliedStoreCredit, isCredit: true)
                        Divider().overlay(WSRegistryPalette.hairline.opacity(0.5))
                        bundlePriceRow("You Pay", value: bundle.finalPayable, isBold: true)
                    }

                    Button {
                        // Future: navigate to bundle detail
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .semibold))
                            Text("View Bundle")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundStyle(WSRegistryPalette.cream)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(
                            LinearGradient(
                                colors: [WSRegistryPalette.espresso, Color(red: 0.245, green: 0.165, blue: 0.110)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(WSRegistryPalette.gold.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: WSRegistryPalette.espresso.opacity(0.06), radius: 16, x: 0, y: 8)
            }
        }
    }

    func bundlePriceRow(_ label: String, value: Double, isCredit: Bool = false, isBold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: isBold ? .semibold : .regular))
                .foregroundStyle(WSRegistryPalette.espresso)
            Spacer()
            Text(isCredit ? "-\(abs(value).formatted(.currency(code: "USD")))" : value.formatted(.currency(code: "USD")))
                .font(.system(size: 15, weight: isBold ? .bold : .regular))
                .foregroundStyle(isCredit ? WSRegistryPalette.sage : WSRegistryPalette.espresso)
        }
    }

    // MARK: Shared Components

    func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(WSRegistryPalette.gold)
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
        }
    }

    func emptyStateCard(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(WSRegistryPalette.warmGray)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    func roomIcon(for room: AURARoomType) -> String {
        switch room {
        case .kitchen: return "frying.pan"
        case .dining: return "fork.knife"
        case .living: return "sofa"
        case .bedroom: return "bed.double"
        case .bathroom: return "shower"
        case .outdoor: return "sun.max"
        case .entryway: return "door.left.hand.open"
        case .office: return "desktopcomputer"
        case .nursery: return "figure.and.child.holdinghands"
        case .multiRoom, .unknown: return "house"
        }
    }
}

#Preview {
    NavigationStack {
        HomeChronicleView()
    }
}
