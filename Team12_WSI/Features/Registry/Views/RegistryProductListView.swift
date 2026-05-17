import SwiftUI

struct RegistryProductListView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var showAIInsights = false
    
    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // 1. TOP HEADER
                    headerSection
                    
                    // 2. SMART SEARCH BAR
                    searchBar
                    
                    // 3. AI INSIGHTS CARD
                    aiInsightsCard
                    
                    // 4. PRIORITY REGISTRY PRODUCTS
                    priorityProductsSection
                    
                    // 5. VIEW ALL CTA
                    viewAllCTA
                    
                    // 6. CELEBRATION POOL QUICK CONTRIBUTION
                    celebrationPoolSection
                    
                    // 7. ACTIVE GROUP CONTRIBUTIONS SECTION
                    activeGroupGiftsSection
                }
                .padding(.bottom, 60)
            }
        }
        .toolbar(.hidden, for: .navigationBar) // Custom header used instead
        .sheet(isPresented: $showAIInsights) {
            RegistryAIInsightsView()
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .frame(width: 44, height: 44)
                    .background(WSRegistryPalette.ivory)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
            }
            
            Spacer()
            
            Text("Registry")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
            
            Spacer()
            
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(WSRegistryPalette.warmGray)
                .font(.system(size: 16, weight: .medium))
            
            TextField("Search their registry...", text: $searchText)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(WSRegistryPalette.espresso)
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
        .background(WSRegistryPalette.ivory)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1)
        )
        .padding(.horizontal, 24)
        .shadow(color: WSRegistryPalette.espresso.opacity(0.02), radius: 5, x: 0, y: 2)
    }
    
    private var aiInsightsCard: some View {
        Button(action: { showAIInsights = true }) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("✨ AI Insights")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.cocoa)
                    
                    Text("Help complete their almost-finished dining collection")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .lineSpacing(3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .padding(.top, 12)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [WSRegistryPalette.ivory, Color(red: 0.98, green: 0.96, blue: 0.91)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(WSRegistryPalette.gold.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: WSRegistryPalette.gold.opacity(0.06), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
    }
    
    private var priorityProductsSection: some View {
        VStack(spacing: 20) {
            // Collection Progress Header
            VStack(spacing: 8) {
                HStack {
                    Text("Citron Dining Collection")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Spacer()
                    Text("82% Complete")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.gold)
                }
                
                ProgressView(value: 82, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: WSRegistryPalette.gold))
                    .scaleEffect(x: 1, y: 0.8, anchor: .center)
            }
            .padding(.horizontal, 20)
            
            // Product List
            LazyVStack(spacing: 16) {
                ForEach(RegistryMockData.items) { item in
                    NavigationLink(destination: ProductDetailView(item: item)) {
                        RegistryProductCardView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var viewAllCTA: some View {
        Button(action: {}) {
            HStack(spacing: 4) {
                Text("View Full Registry")
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: "arrow.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(WSRegistryPalette.cocoa)
        }
        .padding(.top, 4)
    }
    
    private var celebrationPoolSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Celebrate Their Future Together ❤️")
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                Text("Contribute meaningfully toward the home they’re building together.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.9))
                    .lineSpacing(2)
                Text("Every contribution helps complete something special.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .padding(.top, 4)
            }
            
            NavigationLink(destination: CelebrationPoolFlowView()) {
                Text("Contribute to Celebration Pool")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cream)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(WSRegistryPalette.espresso)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: WSRegistryPalette.espresso.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color(red: 0.98, green: 0.97, blue: 0.94), Color(red: 0.96, green: 0.94, blue: 0.90)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(WSRegistryPalette.gold.opacity(0.3), lineWidth: 1))
        .shadow(color: WSRegistryPalette.espresso.opacity(0.05), radius: 15, x: 0, y: 6)
        .padding(.horizontal, 20)
    }
    
    private var activeGroupGiftsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Group Gifts")
                .font(.system(size: 20, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(RegistryMockData.items.filter { $0.state == .groupGiftActive }) { item in
                        GroupGiftCardView(item: item)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.top, 10)
    }
}

// MARK: - Product Card Subview
struct RegistryProductCardView: View {
    let item: ReceiverRegistryItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Image
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(WSRegistryPalette.ivory)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                Image(systemName: item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.5))
                    .frame(width: 80, height: 80)
                
                if item.isPriority {
                    Text("Essential")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(WSRegistryPalette.gold.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                        .padding(6)
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                if let collection = item.collection {
                    Text("Part of: \(collection.name)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.cocoa)
                        .lineLimit(1)
                }
                
                Text(item.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(2)
                
                Text("₹\(Int(item.price))")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.espresso)
                
                Spacer(minLength: 2)
                
                // Status mapping
                if item.state == .celebrationPoolAssisted {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                        Text("Celebration Pool helped complete this")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(WSRegistryPalette.gold)
                } else if item.state == .groupGiftActive, let groupGift = item.groupGift {
                    VStack(alignment: .leading, spacing: 2) {
                        ProgressView(value: groupGift.currentContribution, total: groupGift.totalAmountNeeded)
                            .progressViewStyle(LinearProgressViewStyle(tint: WSRegistryPalette.gold))
                        Text("₹\(Int(groupGift.currentContribution)) / ₹\(Int(groupGift.totalAmountNeeded)) contributed")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 2)
        }
        .padding(10)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
        .shadow(color: WSRegistryPalette.espresso.opacity(0.02), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Active Group Gift Card Subview
struct GroupGiftCardView: View {
    let item: ReceiverRegistryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Rectangle()
                    .fill(WSRegistryPalette.porcelain)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                Image(systemName: item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.6))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineLimit(2)
                    .frame(height: 36, alignment: .topLeading)
                
                if let groupGift = item.groupGift {
                    VStack(alignment: .leading, spacing: 4) {
                        ProgressView(value: groupGift.currentContribution, total: groupGift.totalAmountNeeded)
                            .progressViewStyle(LinearProgressViewStyle(tint: WSRegistryPalette.gold))
                        Text("₹\(Int(groupGift.currentContribution)) / ₹\(Int(groupGift.totalAmountNeeded)) funded")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                        Text("3 friends contributing")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.cocoa)
                    }
                    .padding(.top, 4)
                }
            }
            
            Button(action: {}) {
                Text("Join Group Gift")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cream)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(WSRegistryPalette.espresso)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(.top, 4)
        }
        .padding(16)
        .frame(width: 220)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.8), lineWidth: 1))
        .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}
