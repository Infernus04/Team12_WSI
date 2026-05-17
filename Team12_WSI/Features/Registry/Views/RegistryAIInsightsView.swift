import SwiftUI

struct RegistryAIInsightsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                WSRegistryPalette.porcelain.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        
                        // Header text to set the tone
                        Text("Discover meaningful ways to help them build their home.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        // SECTION 1 - SMART FILTERS
                        smartFiltersSection
                        
                        // SECTION 2 - AI RECOMMENDATIONS
                        aiRecommendationsSection
                        
                        // SECTION 3 - QUICK ACTION CARDS
                        quickActionCardsSection
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("AI Registry Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.6))
                    }
                }
            }
        }
    }
    
    // MARK: - Section 1: Smart Filters
    private var smartFiltersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Explore by")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.cocoa)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    // Budget Row
                    HStack(spacing: 10) {
                        filterChip("Under ₹5,000")
                        filterChip("₹5,000–₹20,000")
                        filterChip("Premium Gifts")
                    }
                    // Theme Row
                    HStack(spacing: 10) {
                        filterChip("Dining", icon: "fork.knife")
                        filterChip("Hosting", icon: "wineglass")
                        filterChip("Bath", icon: "drop")
                        filterChip("Bedding", icon: "bed.double")
                        filterChip("Kitchen Essentials", icon: "frying.pan")
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func filterChip(_ text: String, icon: String? = nil) -> some View {
        Button(action: {}) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(text)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(WSRegistryPalette.espresso)
            .padding(.horizontal, 16)
            .frame(height: 38)
            .background(WSRegistryPalette.ivory)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(WSRegistryPalette.hairline, lineWidth: 1))
        }
    }
    
    // MARK: - Section 2: AI Recommendations
    private var aiRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Curated for You")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.cocoa)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                insightNavigationLink(
                    icon: "sparkles",
                    title: "Help complete their almost-finished dining collection",
                    subtitle: "Only 2 items left in the Citron Collection.",
                    color: WSRegistryPalette.gold,
                    destination: HelpCompleteCollectionView()
                )
                
                insightNavigationLink(
                    icon: "person.3.fill",
                    title: "4 friends are contributing to the espresso machine",
                    subtitle: "Join the group gift to reach the goal.",
                    color: WSRegistryPalette.sage,
                    destination: GroupGiftDetailView()
                )
                
                insightNavigationLink(
                    icon: "house.fill",
                    title: "The couple prioritized everyday kitchen essentials",
                    subtitle: "They selected 12 items for daily cooking.",
                    color: WSRegistryPalette.cocoa,
                    destination: HelpCompleteCollectionView()
                )
                
                insightNavigationLink(
                    icon: "heart.text.square.fill",
                    title: "This hosting collection is 82% complete",
                    subtitle: "Add the final touches for their first dinner party.",
                    color: WSRegistryPalette.espresso,
                    destination: HelpCompleteCollectionView()
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func insightNavigationLink<Destination: View>(icon: String, title: String, subtitle: String, color: Color, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 8)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.hairline)
            }
            .padding(16)
            .background(WSRegistryPalette.ivory)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
            .shadow(color: WSRegistryPalette.espresso.opacity(0.02), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Section 3: Quick Action Cards
    private var quickActionCardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ways to Give")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.cocoa)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                quickActionCard(title: "Complete Collection", icon: "tray.full", color: WSRegistryPalette.gold)
                quickActionCard(title: "Join Group Gift", icon: "gift", color: WSRegistryPalette.espresso)
                quickActionCard(title: "Celebration Pool", icon: "heart", color: WSRegistryPalette.cocoa)
                quickActionCard(title: "Priority Gifts", icon: "star", color: WSRegistryPalette.warmGray)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func quickActionCard(title: String, icon: String, color: Color) -> some View {
        Button(action: {}) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WSRegistryPalette.ivory)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
