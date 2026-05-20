import SwiftUI

// MARK: - Bundle Preview View (selection-first, grid with sticky CTA)

struct BundlePreviewView: View {
    let bundleID: String

    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel

    @State private var selectedIDs: Set<String> = []
    @State private var selectedProduct: ProductItem?

    private var bundle: HomeInspiredBundle? {
        // Walk up to the AURA view model's bundles — stored in a shared source
        BundleStore.shared.bundles.first(where: { $0.id == bundleID })
    }

    private var products: [ProductItem] {
        guard let bundle else { return [] }
        return bundle.productIDs.compactMap { id in
            guard let catalog = BundleStore.shared.catalogByID[id] else { return nil }
            return ProductItem(
                id: catalog.id,
                name: catalog.name,
                price: catalog.effectivePrice,
                path: catalog.imagePath,
                productType: catalog.productType,
                brand: catalog.brand.rawValue
            )
        }
    }

    private var allIDs: [String] { products.map(\.id) }
    private var allSelected: Bool { Set(allIDs).isSubset(of: selectedIDs) }

    var body: some View {
        ZStack(alignment: .bottom) {
            WSRegistryPalette.ivory.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    if let bundle {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(bundle.title)
                                .font(.system(size: 28, weight: .regular, design: .serif))
                                .foregroundStyle(WSRegistryPalette.espresso)

                            Text(bundle.description)
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(WSRegistryPalette.warmGray)
                                .lineSpacing(3)

                            HStack(spacing: 8) {
                                infoBadge("\(bundle.productCount) Items")
                                infoBadge("$\(String(format: "%.0f", bundle.estimatedTotal)) Est.")
                                infoBadge("\(bundle.compatibilityScore)% Match")
                            }
                            .padding(.top, 4)
                        }
                    }

                    // Select All
                    HStack {
                        Button {
                            if allSelected {
                                selectedIDs.subtract(allIDs)
                            } else {
                                selectedIDs.formUnion(allIDs)
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: allSelected ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 18))
                                    .foregroundStyle(allSelected ? WSRegistryPalette.sage : WSRegistryPalette.warmGray)
                                Text(allSelected ? "Deselect All" : "Select All")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(WSRegistryPalette.espresso)
                            }
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        if !selectedIDs.isEmpty {
                            Text("\(selectedIDs.count) selected")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(WSRegistryPalette.warmGray)
                        }
                    }

                    // Product Grid
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
                        spacing: 14
                    ) {
                        ForEach(products) { product in
                            productGridCard(product)
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
            }

            // Sticky bottom CTA
            if !selectedIDs.isEmpty {
                stickyAddCTA
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.25), value: selectedIDs.count)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .fullScreenCover(item: $selectedProduct) { product in
            NavigationStack {
                ProductDetailView(
                    product: product,
                    allProducts: products,
                    onAddToCart: { _ in },
                    onAddToRegistry: { item in
                        registryRepo.addProduct(item, collectionName: bundle?.title ?? "Collection", sourceTag: "bundle-preview")
                    },
                    onAddToSaveForLater: nil,
                    cartQuantity: 0,
                    registryQuantity: registryRepo.currentRegistry?.items.first(where: { $0.id == product.id })?.quantity ?? 0,
                    isInSaveForLater: false,
                    onSelectRelatedProduct: { related in
                        selectedProduct = related
                    }
                )
            }
        }
    }

    // MARK: - Product Card

    private func productGridCard(_ product: ProductItem) -> some View {
        let isSelected = selectedIDs.contains(product.id)
        let isAdded = registryRepo.currentRegistry?.items.contains(where: { $0.id == product.id }) ?? false

        return Button {
            selectedProduct = product
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    CustomAsyncImage(url: product.imageURL)
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    // Checkbox
                    Button {
                        if isSelected {
                            selectedIDs.remove(product.id)
                        } else {
                            selectedIDs.insert(product.id)
                        }
                    } label: {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(isSelected ? WSRegistryPalette.sage : .white.opacity(0.9))
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                    .padding(8)
                }

                Text(product.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(2)

                if let price = product.price {
                    Text("$\(price, specifier: "%.2f")")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color(hex: "#C8102E"))
                }

                if isAdded {
                    Text("IN REGISTRY ✓")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(WSRegistryPalette.sage)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sticky CTA

    private var stickyAddCTA: some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                let items = selectedIDs
                    .compactMap { id in products.first(where: { $0.id == id }) }
                    .filter { item in
                        !(registryRepo.currentRegistry?.items.contains(where: { $0.id == item.id }) ?? false)
                    }
                guard !items.isEmpty else { return }
                registryRepo.addProducts(items, collectionName: bundle?.title ?? "Collection", sourceTag: "bundle-batch")
                selectedIDs.removeAll()
            } label: {
                Text("ADD \(selectedIDs.count) ITEM\(selectedIDs.count == 1 ? "" : "S") TO REGISTRY")
                    .font(.system(size: 15, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background(
                        WSRegistryPalette.espresso,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }

    // MARK: - Badge

    private func infoBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(WSRegistryPalette.espresso)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(WSRegistryPalette.ivory, in: Capsule())
            .overlay(Capsule().stroke(WSRegistryPalette.hairline.opacity(0.35), lineWidth: 1))
    }
}

// MARK: - Bundle Store (lightweight shared state for bundle data)

final class BundleStore {
    static let shared = BundleStore()
    var bundles: [HomeInspiredBundle] = []
    var catalogByID: [String: CatalogProduct] = [:]
    private init() {}
}
