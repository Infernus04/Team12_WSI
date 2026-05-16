// HomeView.swift
// Team12_WSI
// Redesigned AI-Native Luxury Home Tab

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showSearch = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.wsWarmIvory.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Navigation Bar
                luxuryNavBar
                
                ScrollView {
                    VStack(spacing: 40) {
                        // SECTION 1: Adaptive Luxury Hero
                        adaptiveHeroSection
                        
                        // SECTION 2: For Your Home (Lifestyle Scenes)
                        forYourHomeSection
                        
                        // SECTION 3: Occasion Progress Engine
                        occasionProgressSection
                        
                        // SECTION 4: Designed Together (Bundles)
                        designedTogetherSection
                        
                        // SECTION 5: Inspired By Your Style (Aesthetic DNA)
                        aestheticDNASection
                        
                        // SECTION 6: Editorial Intelligence
                        editorialSection
                        
                        // SECTION 7: Registry Insights
                        registryInsightsSection
                        
                        Spacer().frame(height: 100)
                    }
                }
            }
            
            // Floating AI Concierge
            aiConciergeButton
        }
        .onAppear {
            Task {
                viewModel.bind(cartRepository: cartRepository, registryRepository: registryRepository)
                await viewModel.fetchProducts()
            }
        }
    }
    
    // MARK: - Navigation Bar
    private var luxuryNavBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good Evening, Ausaf")
                    .font(.wsSerif(size: 14))
                    .foregroundColor(.wsSecondary)
                Text("Welcome Home")
                    .font(.wsDisplay(size: 18))
                    .foregroundColor(.wsCharcoal)
            }
            
            Spacer()
            
            // Logo (Placeholder)
            Text("WILLIAMS SONOMA")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.wsCharcoal)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {}) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.wsMutedBrass)
                }
                Button(action: { showSearch.toggle() }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.wsCharcoal)
                }
                Button(action: {}) {
                    Image(systemName: "person.circle")
                        .foregroundColor(.wsCharcoal)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.wsWarmIvory)
    }
    
    // MARK: - Section 1: Hero
    private var adaptiveHeroSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Immersive Image Placeholder
            Rectangle()
                .fill(LinearGradient(colors: [Color(hex: "#D9D1C5"), Color.wsWarmIvory], startPoint: .top, endPoint: .bottom))
                .frame(height: 450)
                .overlay(
                    Image(systemName: "house.fill") // Placeholder for cinematic imagery
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(100)
                        .opacity(0.1)
                )
            
            VStack(alignment: .leading, spacing: 12) {
                Text("THE SEASONAL MOOD")
                    .font(.wsLabel(size: 10))
                    .tracking(2)
                    .foregroundColor(.wsMutedBrass)
                
                Text("Warm Autumn\nEntertaining")
                    .font(.wsDisplay(size: 36))
                    .foregroundColor(.wsCharcoal)
                    .lineSpacing(4)
                
                Text("Curated from your saved aesthetics and\nupcoming wedding registry.")
                    .font(.wsSerif(size: 16))
                    .foregroundColor(.wsSecondary)
                    .lineSpacing(4)
                
                Button(action: {}) {
                    Text("BUILD YOUR REGISTRY")
                        .font(.wsLabel(size: 12))
                        .tracking(1.5)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.wsCharcoal)
                        .foregroundColor(.white)
                }
                .padding(.top, 10)
            }
            .padding(30)
        }
    }
    
    // MARK: - Section 2: For Your Home
    private var forYourHomeSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("For Your Home")
                    .font(.wsDisplay(size: 24))
                Spacer()
                Text("WHY THIS WORKS")
                    .font(.wsLabel(size: 10))
                    .foregroundColor(.wsMutedBrass)
                    .tracking(1)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(HomeEditorialData.scenes) { scene in
                        VStack(alignment: .leading, spacing: 15) {
                            Rectangle()
                                .fill(Color.wsChampagne)
                                .frame(width: 300, height: 400)
                                .overlay(
                                    VStack(alignment: .leading) {
                                        Spacer()
                                        Text(scene.title)
                                            .font(.wsSerif(size: 20, weight: .bold))
                                        Text(scene.subtitle)
                                            .font(.wsBody(size: 14))
                                            .foregroundColor(.wsSecondary)
                                    }
                                    .padding(20)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(LinearGradient(colors: [.clear, .white.opacity(0.8)], startPoint: .top, endPoint: .bottom))
                                )
                                .cornerRadius(2)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 10))
                                    .foregroundColor(.wsMutedBrass)
                                Text(scene.reason)
                                    .font(.wsBody(size: 11))
                                    .foregroundColor(.wsSecondary)
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Section 3: Occasion Progress
    private var occasionProgressSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Wedding Is In 54 Days")
                        .font(.wsSerif(size: 18, weight: .semibold))
                    Text("Dining Space 72% Complete")
                        .font(.wsBody(size: 13))
                        .foregroundColor(.wsSecondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.wsChampagne, lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: 0.72)
                        .stroke(Color.wsMutedBrass, lineWidth: 4)
                        .rotationEffect(.degrees(-90))
                    Text("72%")
                        .font(.wsLabel(size: 10))
                }
                .frame(width: 44, height: 44)
            }
            .padding(24)
            .background(Color.white)
            .wsLuxuryShadow()
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Section 4: Designed Together
    private var designedTogetherSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Designed Together")
                .font(.wsDisplay(size: 24))
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(HomeEditorialData.bundles) { bundle in
                        VStack(alignment: .leading, spacing: 12) {
                            Rectangle()
                                .fill(Color.wsChampagne)
                                .frame(width: 260, height: 320)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Text("\(bundle.compatibilityScore)%")
                                                .font(.wsLabel(size: 12))
                                                .padding(6)
                                                .background(Color.wsMutedBrass)
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                    }
                                    .padding(15)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(bundle.title)
                                    .font(.wsSerif(size: 16, weight: .semibold))
                                Text(bundle.description)
                                    .font(.wsBody(size: 12))
                                    .foregroundColor(.wsSecondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Section 5: Aesthetic DNA
    private var aestheticDNASection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Aesthetic DNA")
                .font(.wsDisplay(size: 24))
                .padding(.horizontal, 20)
            
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    dnaTile(color: Color(hex: "#E5E0D8"), label: "Warm Wood")
                    dnaTile(color: Color(hex: "#F5F5F5"), label: "Minimalist")
                }
                HStack(spacing: 15) {
                    dnaTile(color: Color(hex: "#D4AF37").opacity(0.1), label: "Brass Accents")
                    dnaTile(color: Color(hex: "#FDF9F3"), label: "Organic Linen")
                }
                
                Text("MODELED FROM YOUR SAVED ROOMS")
                    .font(.wsLabel(size: 9))
                    .tracking(1)
                    .foregroundColor(.wsMutedBrass)
                    .padding(.top, 10)
            }
            .padding(24)
            .background(Color.white)
            .wsLuxuryShadow()
            .padding(.horizontal, 20)
        }
    }
    
    private func dnaTile(color: Color, label: String) -> some View {
        HStack {
            Circle().fill(color).frame(width: 24, height: 24)
            Text(label).font(.wsBody(size: 13))
            Spacer()
        }
        .padding(12)
        .background(Color.wsWarmIvory)
        .cornerRadius(2)
    }
    
    // MARK: - Section 6: Editorial Intelligence
    private var editorialSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Editorial Intelligence")
                .font(.wsDisplay(size: 24))
                .padding(.horizontal, 20)
            
            ForEach(HomeEditorialData.articles) { article in
                VStack(alignment: .leading, spacing: 15) {
                    Rectangle()
                        .fill(Color.wsChampagne)
                        .frame(height: 400)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(article.title)
                            .font(.wsSerif(size: 22, weight: .bold))
                        Text(article.subtitle)
                            .font(.wsSerif(size: 14))
                            .foregroundColor(.wsSecondary)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // MARK: - Section 7: Registry Insights
    private var registryInsightsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Registry Insights")
                    .font(.wsDisplay(size: 24))
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.wsMutedBrass)
            }
            .padding(.horizontal, 20)
            
            VStack(alignment: .leading, spacing: 16) {
                insightRow(category: "Cookware", score: 92, status: "Strong gifting probability")
                WSDivider()
                insightRow(category: "Dinnerware", score: 45, status: "Consider mid-range items")
            }
            .padding(24)
            .background(Color.wsCharcoal)
            .foregroundColor(.white)
            .cornerRadius(2)
            .padding(.horizontal, 20)
        }
    }
    
    private func insightRow(category: String, score: Int, status: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(category)
                    .font(.wsSerif(size: 16, weight: .semibold))
                Text(status)
                    .font(.wsBody(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
            Text("\(score)%")
                .font(.wsLabel(size: 14))
        }
    }
    
    // MARK: - Floating AI Concierge
    private var aiConciergeButton: some View {
        Button(action: {}) {
            ZStack {
                Circle()
                    .fill(Color.wsCharcoal)
                    .frame(width: 60, height: 60)
                    .wsLuxuryShadow()
                
                Image(systemName: "sparkles")
                    .foregroundColor(.wsSoftGold)
                    .font(.system(size: 20, weight: .light))
            }
        }
        .padding(24)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(CartRepository())
            .environmentObject(RegistryRepository())
            .environmentObject(WSTabBarViewModel())
    }
}
