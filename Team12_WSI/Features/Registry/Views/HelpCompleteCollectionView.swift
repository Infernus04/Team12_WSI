import SwiftUI

struct HelpCompleteCollectionView: View {
    @Environment(\.dismiss) var dismiss

    let collectionName: String
    let registryItems: [RegistryItem]

    // Citron fallback (shown when no registry items match)
    private static let citronItems: [(name: String, price: String, path: String, status: ItemStatus)] = [
        ("Citron Dinner Plates, Set of 4", "₹12,000", "/img23m.jpg",  .completed("Celebration Pool helped complete this")),
        ("Pasta Bowls, Set of 4",          "₹6,500",  "/img10s.jpg",  .completed("Gifted by Aarav")),
        ("Smeg Espresso Machine",          "₹45,000", "/img122m.jpg", .active(14000, 45000)),
    ]

    private enum ItemStatus {
        case completed(String)
        case active(Double, Double)
        case available
    }

    private var completionPct: Int {
        guard !registryItems.isEmpty else { return 82 }
        let purchased = registryItems.filter { $0.isPurchased }.count
        return Int(Double(purchased) / Double(registryItems.count) * 100)
    }

    private var itemCount: Int { registryItems.isEmpty ? 3 : registryItems.count }

    // MARK: - Body

    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Back button header ──────────────────────────────
                    backButtonRow

                    // ── Cinematic hero ──────────────────────────────────
                    heroSection

                    // ── Content ─────────────────────────────────────────
                    VStack(spacing: 20) {
                        progressCard
                        itemsSection
                        auraCard
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 52)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Back Button Row

    private var backButtonRow: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(WSRegistryPalette.espresso)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(WSRegistryPalette.ivory)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(WSRegistryPalette.hairline.opacity(0.7), lineWidth: 1))
                .shadow(color: WSRegistryPalette.espresso.opacity(0.06), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            Image("giftdna_living_room")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .clipped()

            // Multi-stop cinematic fade
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: WSRegistryPalette.porcelain.opacity(0.55), location: 0.55),
                    .init(color: WSRegistryPalette.porcelain.opacity(0.92), location: 0.80),
                    .init(color: WSRegistryPalette.porcelain, location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 8) {
                Text(collectionName)
                    .font(.system(size: 26, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32)

                Text("Curated pieces that complete this beautiful collection.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 36)
            }
            .padding(.bottom, 20)
        }
        .frame(height: 240)
    }

    // MARK: - Progress Card

    private var progressCard: some View {
        HStack(alignment: .center, spacing: 16) {

            // Ring — always visible (track shown even at 0%)
            ZStack {
                Circle()
                    .stroke(WSRegistryPalette.hairline.opacity(0.4), lineWidth: 6)

                if completionPct > 0 {
                    Circle()
                        .trim(from: 0, to: CGFloat(completionPct) / 100)
                        .stroke(
                            AngularGradient(
                                colors: [WSRegistryPalette.gold, Color(hex: "#D4AF37"), WSRegistryPalette.gold],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }

                Text("\(completionPct)%")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
            }
            .frame(width: 60, height: 60)

            // Info text — takes all remaining width
            VStack(alignment: .leading, spacing: 5) {
                Text(collectionName)
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .fixedSize(horizontal: false, vertical: true)

                Text(completionPct >= 100 ? "Fully Complete! 🎉"
                     : completionPct >= 70  ? "Almost Complete!"
                     : "In Progress")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(completionPct >= 100 ? WSRegistryPalette.sage : WSRegistryPalette.gold)

                let remaining = registryItems.filter { !$0.isPurchased }.count
                Text(registryItems.isEmpty
                     ? "Only 1 active gift remains to fully complete this collection."
                     : "\(remaining) item\(remaining == 1 ? "" : "s") remaining to complete.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.65), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.05), radius: 12, x: 0, y: 5)
        .padding(.horizontal, 20)
    }

    // MARK: - Items Section

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            VStack(alignment: .leading, spacing: 3) {
                Text("Collection Pieces")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                Text("\(itemCount) items · \(collectionName)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
            }
            .padding(.horizontal, 20)

            // Item rows
            VStack(spacing: 12) {
                if registryItems.isEmpty {
                    ForEach(Array(Self.citronItems.enumerated()), id: \.offset) { _, item in
                        staticRow(name: item.name, price: item.price,
                                  imagePath: item.path, status: item.status)
                    }
                } else {
                    ForEach(registryItems) { item in
                        dynamicRow(item)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Dynamic Row (live registry items)

    private func dynamicRow(_ item: RegistryItem) -> some View {
        HStack(alignment: .top, spacing: 14) {

            // Thumbnail with status badge
            ZStack(alignment: .topLeading) {
                CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + item.imageUrl))
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(WSRegistryPalette.hairline.opacity(0.5), lineWidth: 1)
                    )

                badge(item.isPurchased ? "GIFTED" : "ACTIVE",
                      color: item.isPurchased ? WSRegistryPalette.sage : WSRegistryPalette.espresso)
            }

            // Text content — maxWidth ensures it never overflows
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(item.isPurchased ? WSRegistryPalette.warmGray : WSRegistryPalette.espresso)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("₹\(Int(item.price))")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(item.isPurchased
                                     ? WSRegistryPalette.warmGray.opacity(0.7)
                                     : WSRegistryPalette.cocoa)
                    .strikethrough(item.isPurchased, color: WSRegistryPalette.warmGray.opacity(0.5))

                if item.isPurchased {
                    statusLine(icon: "checkmark.circle.fill",
                               text: "Already Gifted",
                               color: WSRegistryPalette.sage)
                } else if let col = item.collectionName {
                    Text(col)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.gold.opacity(0.85))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if item.isPurchased {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(WSRegistryPalette.sage.opacity(0.55))
                    .padding(.top, 2)
            }
        }
        .padding(14)
        .background(item.isPurchased ? WSRegistryPalette.porcelain.opacity(0.6) : WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(item.isPurchased ? 0.3 : 0.6), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(item.isPurchased ? 0 : 0.03),
                radius: 8, x: 0, y: 3)
        .opacity(item.isPurchased ? 0.72 : 1)
    }

    // MARK: - Static Row (Citron fallback)

    private func staticRow(name: String, price: String,
                           imagePath: String, status: ItemStatus) -> some View {
        // Split layout: thumbnail+text on top, contribution bar below (full width — fixes clipping)
        VStack(alignment: .leading, spacing: 10) {

            HStack(alignment: .top, spacing: 14) {
                ZStack(alignment: .topLeading) {
                    CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + imagePath))
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(WSRegistryPalette.hairline.opacity(0.5), lineWidth: 1)
                        )

                    switch status {
                    case .completed: badge("COMPLETED", color: WSRegistryPalette.gold)
                    case .active:    badge("ACTIVE",    color: WSRegistryPalette.espresso)
                    case .available: EmptyView()
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(price)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cocoa)

                    if case .completed(let note) = status {
                        statusLine(icon: "checkmark.circle.fill",
                                   text: note,
                                   color: WSRegistryPalette.gold)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Contribution bar lives OUTSIDE the HStack so it gets full card width
            if case .active(let contributed, let total) = status {
                contributionBar(contributed: contributed, total: total)
            }
        }
        .padding(14)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 8, x: 0, y: 3)
    }

    // MARK: - Shared helpers

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 7, weight: .bold))
            .tracking(0.4)
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .padding(5)
    }

    private func statusLine(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(color)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(color)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 1)
    }

    // Full-width bar — outside the thumbnail HStack so it never gets clipped
    private func contributionBar(contributed: Double, total: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(WSRegistryPalette.hairline.opacity(0.3))
                        .frame(height: 4)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [WSRegistryPalette.gold.opacity(0.7), WSRegistryPalette.gold],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(contributed / total), height: 4)
                }
            }
            .frame(height: 4)

            HStack {
                Text("₹\(Int(contributed)) contributed")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.gold)
                Spacer()
                Text("\(Int(contributed / total * 100))% Funded")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.warmGray)
            }
        }
    }

    // MARK: - AURA Card

    private var auraCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("AURA AI COMPLETION INSIGHT")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(WSRegistryPalette.gold)
            }

            Text("By completing the \(collectionName), you are gifting the couple the beautiful privilege of hosting their very first formal dinner in their new home with perfect, curated coordination.")
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso.opacity(0.85))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)

            NavigationLink(destination: GroupGiftDetailView()) {
                Text("Help Complete with a Contribution")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cream)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(WSRegistryPalette.espresso)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [WSRegistryPalette.ivory, Color(red: 0.98, green: 0.96, blue: 0.91)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(WSRegistryPalette.gold.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.gold.opacity(0.08), radius: 14, x: 0, y: 6)
        .padding(.horizontal, 20)
    }
}
