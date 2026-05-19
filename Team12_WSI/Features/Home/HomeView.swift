// HomeView.swift — AI-Native Luxury Home Tab
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @EnvironmentObject var saveForLaterRepository: SaveForLaterRepository

    @State private var navigationPath = NavigationPath()
    @State private var showSearch = false
    @State private var showConcierge = false
    @State private var showMoodboard = false
    @State private var selectedArticle: EditorialArticle?
    @State private var expandedSceneID: UUID?
    @State private var expandedBundleID: UUID?
    @State private var heroPage = 0
    @State private var conciergeScale: CGFloat = 1.0
    @State private var s1On = false; @State private var s2On = false
    @State private var s4On = false; @State private var s5On = false
    @State private var s6On = false; @State private var s7On = false
    @State private var s8On = false
    @State private var showSaveForLater = false          // Buy Later list
    @State private var showProfile = false               // Profile sheet
    // Hero CTA navigation
    @State private var showHeroCollection = false

    private let heroMoods = SeasonalContextEngine.heroMoods()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottomTrailing) {
                Color.wsWarmIvory.ignoresSafeArea()
                VStack(spacing: 0) {
                    navBar
                    if viewModel.isLoading { loadingView }
                    else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 48) {
                                heroSection.opacity(s1On ? 1 : 0).offset(y: s1On ? 0 : 16).onAppear { withAnimation(.easeOut(duration: 0.5)) { s1On = true } }
                                forYourHomeSection.opacity(s2On ? 1 : 0).offset(y: s2On ? 0 : 20).onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.1)) { s2On = true } }
                                designedTogetherSection.opacity(s4On ? 1 : 0).offset(y: s4On ? 0 : 20).onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.15)) { s4On = true } }
                                moodboardSection.opacity(s5On ? 1 : 0).offset(y: s5On ? 0 : 20).onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.2)) { s5On = true } }
                                editorialSection.opacity(s6On ? 1 : 0).offset(y: s6On ? 0 : 20).onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.25)) { s6On = true } }
                                porterSwivelChairSection.opacity(s7On ? 1 : 0).offset(y: s7On ? 0 : 20).onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.28)) { s7On = true } }
                                seasonalSection.opacity(s8On ? 1 : 0).offset(y: s8On ? 0 : 20).onAppear { withAnimation(.easeOut(duration: 0.5).delay(0.3)) { s8On = true } }
                                Spacer().frame(height: 100)
                            }
                        }
                    }
                }
                conciergeButton
            }
            .navigationBarHidden(true)
            .navigationDestination(for: HomeRoute.self) { route in
                homeDestination(for: route)
            }
            .sheet(isPresented: $showSearch) {
                HomeSearchView(
                    allProducts: viewModel.products,
                    onSelectProduct: { navigateToProduct($0) },
                    onAddToCart: { viewModel.addToCart($0) },
                    onAddToRegistry: { viewModel.addToRegistry($0) }
                )
            }
            .sheet(isPresented: $showConcierge) {
                AIConciergeView(allProducts: viewModel.products, registryRepository: registryRepository, onSelectProduct: { navigateToProduct($0) })
            }
            .sheet(item: $selectedArticle) { article in articleSheet(article) }
            .sheet(isPresented: $showMoodboard) {
                NavigationStack {
                    MoodboardView(
                        allProducts: viewModel.products,
                        onAddToCart: { viewModel.addToCart($0) },
                        onAddToRegistry: { viewModel.addToRegistry($0) }
                    )
                }
            }
            .sheet(isPresented: $showHeroCollection) {
                HomeSearchView(
                    allProducts: viewModel.products,
                    onSelectProduct: { navigateToProduct($0) },
                    onAddToCart: { viewModel.addToCart($0) },
                    onAddToRegistry: { viewModel.addToRegistry($0) }
                )
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showSaveForLater) {
                SaveForLaterView()
                    .environmentObject(saveForLaterRepository)
                    .environmentObject(cartRepository)
            }
            .onAppear {
                Task {
                    viewModel.bind(
                        cartRepository: cartRepository,
                        registryRepository: registryRepository,
                        saveForLaterRepository: saveForLaterRepository
                    )
                    await viewModel.fetchProducts()
                }
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) { conciergeScale = 1.08 }
            }
        }
    }

    private enum HomeRoute: Hashable {
        case product(String)
        case bundle(UUID)
        case scene(UUID)
    }

    private func navigateToProduct(_ product: ProductItem) {
        navigationPath.append(HomeRoute.product(product.id))
    }

    private func navigateToBundle(_ bundle: AestheticBundle) {
        navigationPath.append(HomeRoute.bundle(bundle.id))
    }

    private func navigateToScene(_ scene: LifestyleScene) {
        navigationPath.append(HomeRoute.scene(scene.id))
    }

    @ViewBuilder
    private func homeDestination(for route: HomeRoute) -> some View {
        switch route {
        case .product(let id):
            if let product = viewModel.products.first(where: { $0.id == id }) {
                ProductDetailView(
                    product: product,
                    allProducts: viewModel.products,
                    onAddToCart: { viewModel.addToCart($0) },
                    onAddToRegistry: { viewModel.addToRegistry($0) },
                    onAddToSaveForLater: { viewModel.addToSaveForLater($0) },
                    cartQuantity: viewModel.cartQuantity(for: product),
                    registryQuantity: viewModel.registryQuantity(for: product),
                    isInSaveForLater: viewModel.isInSaveForLater(product),
                    onSelectRelatedProduct: { navigateToProduct($0) }
                )
                .toolbar(.hidden, for: .tabBar)
            } else {
                unavailableDetailView
            }
        case .bundle(let id):
            if let bundle = HomeEditorialData.bundles.first(where: { $0.id == id }) {
                BundleDetailView(
                    bundle: bundle,
                    products: viewModel.bundleProducts(for: bundle),
                    onSelectProduct: { navigateToProduct($0) },
                    onAddToCart: { viewModel.addToCart($0) },
                    onAddToRegistry: { viewModel.addToRegistry($0) }
                )
                .toolbar(.hidden, for: .tabBar)
            } else {
                unavailableDetailView
            }
        case .scene(let id):
            if let scene = HomeEditorialData.scenes.first(where: { $0.id == id }) {
                LifestyleSceneDetailView(
                    scene: scene,
                    allProducts: viewModel.products,
                    onSelectProduct: { navigateToProduct($0) },
                    onAddToCart: { viewModel.addToCart($0) },
                    onAddToRegistry: { viewModel.addToRegistry($0) }
                )
                .toolbar(.hidden, for: .tabBar)
            } else {
                unavailableDetailView
            }
        }
    }

    private var unavailableDetailView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.wsMutedBrass)
            Text("This detail is no longer available.")
                .font(.wsSerif(size: 18))
                .foregroundColor(.wsCharcoal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.wsWarmIvory)
    }

    // MARK: Loading
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView().tint(.wsMutedBrass).scaleEffect(1.3)
            Text("Curating your experience...").font(.wsBody(size: 13)).foregroundColor(.wsSecondary)
            Spacer()
        }
    }

    // MARK: Nav Bar
    private var navBar: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Good Evening, Ausaf")
                    .font(.wsSerif(size: 13))
                    .foregroundColor(.wsSecondary)
                    .lineLimit(1)
                Text("Welcome Home")
                    .font(.wsDisplay(size: 18))
                    .foregroundColor(.wsCharcoal)
                    .lineLimit(1)
            }
            .layoutPriority(1)
            
            Spacer(minLength: 8)
            
            Text("WILLIAMS\nSONOMA")
                .font(.system(size: 8, weight: .bold))
                .tracking(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.wsCharcoal)
                .fixedSize()
            
            Spacer(minLength: 8)
            
            HStack(spacing: 14) {
                // Buy Later list button
                ZStack(alignment: .topTrailing) {
                    Button(action: { showSaveForLater = true }) {
                        Image(systemName: "bookmark")
                            .foregroundColor(.wsMutedBrass)
                            .font(.system(size: 16))
                    }
                    if saveForLaterRepository.totalItems > 0 {
                        Text("\(saveForLaterRepository.totalItems)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 14, height: 14)
                            .background(Color.wsCrimson)
                            .clipShape(Circle())
                            .offset(x: 6, y: -6)
                    }
                }
                Button(action: { showSearch = true }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.wsCharcoal)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.wsWarmIvory)
    }

    // MARK: Section 1 — Hero
    private var heroSection: some View {
        TabView(selection: $heroPage) {
            ForEach(heroMoods.indices, id: \.self) { i in
                heroCard(mood: heroMoods[i], productIndex: i).tag(i)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 500)
        // Clip so the TabView page dots don't bleed outside
        .clipped()
    }

    private func heroCard(mood: SeasonalMood, productIndex: Int) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                // Background image fills the card exactly
                Group {
                    if let url = viewModel.product(at: productIndex)?.imageURL {
                        CustomAsyncImage(url: url)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    } else {
                        LinearGradient(
                            colors: [Color(hex: "#C9C0B3"), Color.wsChampagne],
                            startPoint: .top, endPoint: .bottom
                        )
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }

                // Scrim gradient
                LinearGradient(
                    colors: [.clear, Color.wsCharcoal.opacity(0.75)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geo.size.width, height: geo.size.height)

                // Text + CTA — fixed to bottom-left, consistent across all cards
                VStack(alignment: .leading, spacing: 12) {
                    Text("THE SEASONAL MOOD")
                        .font(.wsLabel(size: 9))
                        .tracking(2)
                        .foregroundColor(.wsMutedBrass)

                    Text(mood.headline)
                        .font(.wsDisplay(size: 32))
                        .foregroundColor(.white)
                        .lineSpacing(3)
                        .lineLimit(3)

                    Text(mood.subtitle)
                        .font(.wsSerif(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)

                    Button(action: { showHeroCollection = true }) {
                        Text(mood.cta)
                            .font(.wsLabel(size: 11))
                            .tracking(1.5)
                            .foregroundColor(.wsCharcoal)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 13)
                            .background(Color.white)
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .frame(maxWidth: geo.size.width, alignment: .leading)
            }
        }
        // GeometryReader needs an explicit height or it collapses
        .frame(height: 500)
    }

    // MARK: Section 2 — For Your Home
    private var forYourHomeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("For Your Home").font(.wsDisplay(size: 24)).foregroundColor(.wsCharcoal)
                    HStack(spacing: 5) { Image(systemName: "sparkles").font(.system(size: 9)).foregroundColor(.wsMutedBrass); Text("CURATED FOR YOUR AESTHETIC").font(.wsLabel(size: 9)).tracking(1).foregroundColor(.wsMutedBrass) }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(HomeEditorialData.scenes) { scene in
                        Button(action: { navigateToScene(scene) }) {
                            sceneCard(scene)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func sceneCard(_ scene: LifestyleScene) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottom) {
                if let url = viewModel.product(at: scene.productOffset)?.imageURL {
                    CustomAsyncImage(url: url).frame(width: 300, height: 400).clipped().cornerRadius(2)
                } else {
                    RoundedRectangle(cornerRadius: 2).fill(Color.wsChampagne).frame(width: 300, height: 400)
                }
                LinearGradient(colors: [.clear, Color.wsCharcoal.opacity(0.78)], startPoint: .center, endPoint: .bottom).frame(width: 300, height: 400).cornerRadius(2)
                VStack(alignment: .leading, spacing: 8) {
                    Text(scene.title).font(.wsSerif(size: 18, weight: .bold)).foregroundColor(.white)
                    Text(scene.subtitle).font(.wsBody(size: 13)).foregroundColor(.white.opacity(0.8))
                    // Mini product thumbnails
                    HStack(spacing: 6) {
                        ForEach(Array([(scene.productOffset+1)%max(1,viewModel.products.count), (scene.productOffset+2)%max(1,viewModel.products.count)].enumerated()), id: \.offset) { index, idx in
                            if let url = viewModel.product(at: idx)?.imageURL {
                                CustomAsyncImage(url: url).frame(width: 36, height: 36).clipped().clipShape(Circle()).overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 1))
                            }
                        }
                        Spacer()
                        Button(action: { withAnimation(.spring()) { expandedSceneID = expandedSceneID == scene.id ? nil : scene.id } }) {
                            HStack(spacing: 4) { Image(systemName: "sparkles").font(.system(size: 9)); Text("WHY THIS WORKS").font(.wsLabel(size: 9)).tracking(0.5) }
                                .foregroundColor(.wsMutedBrass)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(2)
                        }
                    }
                    if expandedSceneID == scene.id {
                        Text(scene.reason).font(.wsBody(size: 12)).foregroundColor(.white.opacity(0.85)).lineSpacing(3).transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .padding(18).frame(width: 300, alignment: .leading)
            }
        }
    }

    // MARK: Section 4 — Designed Together
    private var designedTogetherSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Designed Together").font(.wsDisplay(size: 24)).foregroundColor(.wsCharcoal)
                    HStack(spacing: 5) { Image(systemName: "sparkles").font(.system(size: 9)).foregroundColor(.wsMutedBrass); Text("AI AESTHETIC BUNDLES").font(.wsLabel(size: 9)).tracking(1).foregroundColor(.wsMutedBrass) }
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(HomeEditorialData.bundles) { bundle in bundleCard(bundle) }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func bundleCard(_ bundle: AestheticBundle) -> some View {
        let prods = viewModel.bundleProducts(for: bundle)
        return VStack(alignment: .leading, spacing: 14) {
            // 2x2 image grid — tappable → BundleDetailView
            Button(action: { navigateToBundle(bundle) }) {
                ZStack(alignment: .topTrailing) {
                    LazyVGrid(
                        columns: [GridItem(.fixed(129), spacing: 3), GridItem(.fixed(129), spacing: 3)],
                        spacing: 3
                    ) {
                        ForEach(prods.prefix(4)) { p in
                            CustomAsyncImage(url: p.imageURL)
                                .frame(width: 129, height: 129)
                                .clipped()
                        }
                        if prods.count < 4 {
                            ForEach(0..<(4 - prods.count), id: \.self) { _ in
                                Rectangle().fill(Color.wsChampagne).frame(width: 129, height: 129)
                            }
                        }
                    }
                    .frame(width: 261)
                    .cornerRadius(2)

                    Text("\(bundle.compatibilityScore)% MATCH")
                        .font(.wsLabel(size: 9))
                        .tracking(0.5)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.wsMutedBrass)
                        .padding(10)
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                Text(bundle.title)
                    .font(.wsSerif(size: 16, weight: .semibold))
                    .foregroundColor(.wsCharcoal)

                Text(bundle.description)
                    .font(.wsBody(size: 12))
                    .foregroundColor(.wsSecondary)
                    .lineLimit(2)

                Button(action: {
                    withAnimation(.spring()) {
                        expandedBundleID = expandedBundleID == bundle.id ? nil : bundle.id
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 9))
                        Text("WHY THIS WORKS")
                            .font(.wsLabel(size: 9))
                            .tracking(0.5)
                    }
                    .foregroundColor(.wsMutedBrass)
                }

                if expandedBundleID == bundle.id {
                    Text(bundle.aiReason)
                        .font(.wsBody(size: 12))
                        .foregroundColor(.wsSecondary)
                        .lineSpacing(3)
                        .transition(.opacity)
                }

                HStack(spacing: 8) {
                    Button(action: { viewModel.addBundleToCart(bundle) }) {
                        Text("ADD ALL")
                            .font(.wsLabel(size: 11))
                            .tracking(1.5)
                            .foregroundColor(.wsCharcoal)
                            .frame(maxWidth: .infinity, minHeight: 38)
                            .overlay(Rectangle().stroke(Color.wsCharcoal, lineWidth: 1))
                    }

                    Button(action: { navigateToBundle(bundle) }) {
                        Text("VIEW")
                            .font(.wsLabel(size: 11))
                            .tracking(1.5)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 38)
                            .background(Color.wsCharcoal)
                    }
                }
                .frame(width: 261)
            }
        }
        .frame(width: 261)
    }

    // MARK: Section 5 — AI Moodboard Teaser
    private var moodboardSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Inspired By Your Style").font(.wsDisplay(size: 24)).foregroundColor(.wsCharcoal)
                    HStack(spacing: 5) { Image(systemName: "sparkles").font(.system(size: 9)).foregroundColor(.wsMutedBrass); Text("AI MOODBOARD ENGINE").font(.wsLabel(size: 9)).tracking(1).foregroundColor(.wsMutedBrass) }
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            Button(action: { showMoodboard = true }) {
                ZStack(alignment: .bottomLeading) {
                    // Mini 3x2 product grid preview
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 3), spacing: 2) {
                        ForEach(viewModel.products.prefix(6)) { p in
                            CustomAsyncImage(url: p.imageURL).frame(maxWidth: .infinity).aspectRatio(1, contentMode: .fill).clipped()
                        }
                        if viewModel.products.count < 6 {
                            ForEach(0..<(6-min(viewModel.products.count, 6)), id: \.self) { _ in Rectangle().fill(Color.wsChampagne).aspectRatio(1, contentMode: .fit) }
                        }
                    }
                    .frame(maxWidth: .infinity).cornerRadius(2)
                    .overlay(LinearGradient(colors: [.clear, Color.wsCharcoal.opacity(0.82)], startPoint: .center, endPoint: .bottom).cornerRadius(2))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Moodboard").font(.wsSerif(size: 22, weight: .bold)).foregroundColor(.white)
                        Text("Upload photos & describe your vibe to discover matching products.").font(.wsBody(size: 13)).foregroundColor(.white.opacity(0.8)).lineSpacing(3)
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled").font(.system(size: 11)).foregroundColor(.wsMutedBrass)
                            Text("TAP TO OPEN AI MOODBOARD").font(.wsLabel(size: 10)).tracking(1.5).foregroundColor(.wsMutedBrass)
                        }
                    }
                    .padding(24)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
    }

    // MARK: Section 6 — Editorial
    private var editorialSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Editorial Intelligence").font(.wsDisplay(size: 24)).foregroundColor(.wsCharcoal)
                    HStack(spacing: 5) {
                        Image(systemName: "text.page")
                            .font(.system(size: 9))
                            .foregroundColor(.wsMutedBrass)
                        Text("STORIES FROM THE COLLECTION")
                            .font(.wsLabel(size: 9))
                            .tracking(1)
                            .foregroundColor(.wsMutedBrass)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(HomeEditorialData.articles) { article in
                        Button(action: { selectedArticle = article }) {
                            editorialCard(article)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 320)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func editorialCard(_ article: EditorialArticle) -> some View {
        ZStack(alignment: .bottom) {
            if let url = viewModel.product(at: article.productOffset)?.imageURL {
                CustomAsyncImage(url: url)
                    .frame(maxWidth: .infinity)
                    .frame(height: 380)
                    .clipped()
                    .cornerRadius(4)
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.wsChampagne)
                    .frame(height: 380)
            }

            // Stronger scrim for readability — starts at 40% down the card
            LinearGradient(
                colors: [
                    .clear,
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.82)
                ],
                startPoint: .init(x: 0.5, y: 0.35),
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity)
            .frame(height: 380)
            .cornerRadius(4)

            // Text block — opaque dark panel for maximum legibility
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(article.category)
                        .font(.wsLabel(size: 9))
                        .tracking(2)
                        .foregroundColor(.wsMutedBrass)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.35))
                        .cornerRadius(2)

                    Text(article.readTime)
                        .font(.wsBody(size: 11))
                        .foregroundColor(.white.opacity(0.75))
                }

                Text(article.title)
                    .font(.wsSerif(size: 21, weight: .bold))
                    .foregroundColor(.white)
                    .lineSpacing(3)
                    .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 1)

                Text(article.subtitle)
                    .font(.wsSerif(size: 13))
                    .foregroundColor(.white.opacity(0.88))
                    .italic()
                    .shadow(color: Color.black.opacity(0.4), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0), Color.black.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(4)
            )
        }
        .cornerRadius(4)
    }

    // MARK: Section 7 — Porter Swivel Chair (Featured New Arrival + AR)
    private var porterSwivelChairSection: some View {
        PorterSwivelChairSection(
            onAddToCart: {
                // Static product — create a placeholder ProductItem for the cart
                let porterChair = ProductItem(
                    id: "porter-swivel-chair-static",
                    name: "Porter Swivel Chair",
                    price: 995.0,
                    path: nil
                )
                viewModel.addToCart(porterChair)
            },
            onAddToRegistry: {
                let porterChair = ProductItem(
                    id: "porter-swivel-chair-static",
                    name: "Porter Swivel Chair",
                    price: 995.0,
                    path: nil
                )
                viewModel.addToRegistry(porterChair)
            }
        )
    }

    // MARK: Section 8 — Seasonal
    private var seasonalSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(SeasonalContextEngine.seasonalSectionHeader()).font(.wsDisplay(size: 24)).foregroundColor(.wsCharcoal)
                    HStack(spacing: 5) {
                        Circle().fill(SeasonalContextEngine.seasonalAccentColor()).frame(width: 8, height: 8)
                        Text("CURATED FOR THIS SEASON  ✦").font(.wsLabel(size: 9)).tracking(1).foregroundColor(.wsMutedBrass)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(viewModel.seasonalProducts().prefix(8)) { product in
                        Button(action: { navigateToProduct(product) }) {
                            seasonalProductTile(product)
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func seasonalProductTile(_ product: ProductItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                CustomAsyncImage(url: product.imageURL).frame(width: 170, height: 210).clipped().cornerRadius(2)
                SeasonalContextEngine.seasonalAccentColor().opacity(0.25).frame(width: 170, height: 210).cornerRadius(2)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(product.name).font(.wsBody(size: 12)).foregroundColor(.wsCharcoal).lineLimit(2).frame(width: 170, alignment: .leading)
                if let price = product.price { Text("$\(price, specifier: "%.2f")").font(.system(size: 12, weight: .semibold)).foregroundColor(.wsCrimson) }
            }
        }
    }

    // MARK: AI Concierge Button
    private var conciergeButton: some View {
        Button(action: { showConcierge = true }) {
            ZStack {
                Circle().fill(Color.wsCharcoal).frame(width: 60, height: 60).wsShadow()
                Circle().stroke(Color.wsSoftGold.opacity(0.6), lineWidth: 1.5).frame(width: 66, height: 66).scaleEffect(conciergeScale)
                Image(systemName: "sparkles").foregroundColor(.wsSoftGold).font(.system(size: 20, weight: .light))
            }
        }
        .padding(24)
    }

    // MARK: Article Sheet
    private func articleSheet(_ article: EditorialArticle) -> some View {
        ZStack {
            Color.wsWarmIvory.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if let url = viewModel.product(at: article.productOffset)?.imageURL {
                        CustomAsyncImage(url: url).frame(maxWidth: .infinity).frame(height: 300).clipped()
                    }
                    VStack(alignment: .leading, spacing: 20) {
                        HStack { Text(article.category).font(.wsLabel(size: 9)).tracking(2).foregroundColor(.wsMutedBrass); Spacer(); Text(article.readTime).font(.wsBody(size: 11)).foregroundColor(.wsSecondary) }
                        Text(article.title).font(.wsDisplay(size: 28)).foregroundColor(.wsCharcoal).lineSpacing(4)
                        Text(article.subtitle).font(.wsSerif(size: 16)).foregroundColor(.wsSecondary).italic().lineSpacing(4)
                        WSDivider()
                        Text(article.body).font(.wsSerif(size: 15)).foregroundColor(.wsCharcoal).lineSpacing(7)
                        WSDivider()
                        Text("Related Products").font(.wsSerif(size: 18, weight: .semibold)).foregroundColor(.wsCharcoal)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.products.prefix(4)) { p in
                                    Button(action: { navigateToProduct(p) }) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            CustomAsyncImage(url: p.imageURL).frame(width: 130, height: 130).clipped().cornerRadius(2)
                                            Text(p.name).font(.wsBody(size: 11)).foregroundColor(.wsCharcoal).lineLimit(2).frame(width: 130, alignment: .leading)
                                            if let pr = p.price { Text("$\(pr, specifier: "%.2f")").font(.wsLabel(size: 10)).foregroundColor(.wsCrimson) }
                                        }
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                        Spacer().frame(height: 40)
                    }
                    .padding(24)
                }
            }
        }
        .presentationDetents([.large])
    }

    // AI Explain Sheet removed per design decision
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(CartRepository())
            .environmentObject(RegistryRepository())
            .environmentObject(WSTabBarViewModel())
            .environmentObject(SaveForLaterRepository())
    }
}
