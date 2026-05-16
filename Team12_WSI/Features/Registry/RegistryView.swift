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
                        if viewModel.hasRegistry {
                            registrySummaryCard
                        } else {
                            primaryCTACard
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
            )
            actionRow(
                icon: "heart.text.square",
                title: "View Past Registry",
                subtitle: "View and track your past registry"
            )
        }
    }
    
    func actionRow(icon: String, title: String, subtitle: String) -> some View {
        Button {
        } label: {
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
    
    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    homeStoryCard
                    statsCard
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
                
                Button {
                } label: {
                    HStack(spacing: 8) {
                        Text("Edit Story")
                        Image(systemName: "pencil")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.gold)
                }
                .buttonStyle(.plain)
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
            statItem(value: "12", label: "Collections")
            divider
            statItem(value: "18", label: "Purchased")
            divider
            statItem(value: registryItems.isEmpty ? "68%" : "0%", label: "Completed")
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
    
    private var registryItems: [RegistryItem] {
        registryRepo.currentRegistry?.items ?? []
    }
    
    private var section: RegistryDetailSection {
        let sections = RegistryDetailContent.sections(from: registryItems)
        return sections.first(where: { $0.title == sectionTitle }) ?? RegistryDetailSection.samples[0]
    }
    
    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(section.title)
                            .font(.system(size: 34, weight: .semibold, design: .serif))
                            .foregroundStyle(WSRegistryPalette.espresso)
                        Text("\(section.itemCount) Items")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(section.tint)
                    }
                    .padding(.bottom, 4)
                    
                    ForEach(section.products) { product in
                        registryProductListRow(product)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func registryProductListRow(_ product: RegistryDisplayProduct) -> some View {
        HStack(spacing: 14) {
            CustomAsyncImage(url: product.imageURL)
                .frame(width: 92, height: 92)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(product.brand)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(1)
                
                Text(product.name)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.86))
                    .lineLimit(2)
                
                Text(product.priceText)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.espresso)
            }
            
            Spacer(minLength: 8)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.ivory.opacity(0.62), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.45), lineWidth: 1)
        )
    }
}

private enum RegistryDetailContent {
    static func sections(from registryItems: [RegistryItem]) -> [RegistryDetailSection] {
        guard !registryItems.isEmpty else { return RegistryDetailSection.samples }
        return [
            RegistryDetailSection(
                title: "Daily Cooking",
                itemCount: registryItems.reduce(0) { $0 + $1.quantity },
                tint: WSRegistryPalette.sage,
                products: registryItems.map { RegistryDisplayProduct(item: $0) }
            )
        ] + RegistryDetailSection.samples.dropFirst()
    }
    
    static func totalItems(from registryItems: [RegistryItem]) -> Int {
        guard !registryItems.isEmpty else { return 86 }
        return registryItems.reduce(0) { $0 + $1.quantity }
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
                RegistryDisplayProduct(brand: "Le Creuset", name: "Signature Dutch Oven", priceText: "$420.00", imagePath: "/img122m.jpg"),
                RegistryDisplayProduct(brand: "Wusthof", name: "Classic 8-Piece Set", priceText: "$450.00", imagePath: "/img17m.jpg"),
                RegistryDisplayProduct(brand: "Vitamix", name: "A3500 Blender", priceText: "$699.95", imagePath: "/img83m.jpg")
            ]
        ),
        RegistryDetailSection(
            title: "Hosting",
            itemCount: 18,
            tint: WSRegistryPalette.gold,
            products: [
                RegistryDisplayProduct(brand: "Staub", name: "Serving Bowl Set", priceText: "$179.95", imagePath: "/img64m.jpg"),
                RegistryDisplayProduct(brand: "Marimekko", name: "Oiva Serving Platter", priceText: "$69.00", imagePath: "/img42m.jpg"),
                RegistryDisplayProduct(brand: "LSA International", name: "Wine Carafe", priceText: "$89.00", imagePath: "/img95m.jpg")
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
    let id = UUID()
    let brand: String
    let name: String
    let priceText: String
    let imageURL: URL?
    
    init(brand: String, name: String, priceText: String, imagePath: String) {
        self.brand = brand
        self.name = name
        self.priceText = priceText
        self.imageURL = URL(string: AppConstants.API.imageBasePath + imagePath)
    }
    
    init(item: RegistryItem) {
        let parts = item.name.split(separator: " ", maxSplits: 1).map(String.init)
        self.brand = parts.first ?? "Williams Sonoma"
        self.name = parts.count > 1 ? parts[1] : item.name
        self.priceText = item.price.formatted(.currency(code: "USD"))
        self.imageURL = URL(string: AppConstants.API.imageBasePath + item.imageUrl)
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
