import SwiftUI

struct HelpCompleteCollectionView: View {
    @Environment(\.dismiss) var dismiss
    
    // Citron Dining Collection details
    let collectionName = "Citron Dining Collection"
    let completionPercentage = 82
    
    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - EDITORIAL HERO CARD (Inspired by WS dinnerware style)
                    editorialHeroSection
                    
                    // MARK: - COMPLETION STATS CARD
                    completionProgressCard
                    
                    // MARK: - ITEMS IN THE COLLECTION
                    collectionItemsSection
                    
                    // MARK: - AURA EMBELLISHMENT
                    auraInsightCard
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .frame(width: 38, height: 38)
                    .background(WSRegistryPalette.ivory)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            }
            .padding(.top, 16)
            .padding(.leading, 20)
        }
    }
    
    // MARK: - Editorial Hero (Cabbage plate setting theme)
    private var editorialHeroSection: some View {
        VStack(spacing: 16) {
            // High-end Editorial lifestyle dinnerware image
            ZStack(alignment: .bottom) {
                Image("giftdna_living_room") // Using existing premium living room photo
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 240)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [Color.clear, WSRegistryPalette.porcelain.opacity(0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                // Overlay text
                VStack(spacing: 8) {
                    Text("Define Your Dinnerware Style")
                        .font(.system(size: 26, weight: .regular, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .multilineTextAlignment(.center)
                    
                    Text("Set the scene for iconic entertaining with curated tableware.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cocoa)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: - Completion Progress Card
    private var completionProgressCard: some View {
        HStack(spacing: 20) {
            // Elegant progress ring
            ZStack {
                Circle()
                    .stroke(WSRegistryPalette.hairline.opacity(0.4), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(completionPercentage) / 100.0)
                    .stroke(
                        AngularGradient(
                            colors: [WSRegistryPalette.gold, Color(hex: "#D4AF37"), WSRegistryPalette.gold],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Text("\(completionPercentage)%")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Citron Dining Collection")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                
                Text("Almost Complete!")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.gold)
                
                Text("Only 1 active gift remains to fully complete this gorgeous dining experience.")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .lineSpacing(2)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.8), lineWidth: 1))
        .padding(.horizontal, 20)
    }
    
    // MARK: - Collection Items Section
    private var collectionItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Collection Pieces")
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                // Item 1: Citron Dinner Plates (COMPLETED via celebration pool!)
                HStack(spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + "/img23m.jpg"))
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        Text("COMPLETED")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(WSRegistryPalette.gold)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .padding(6)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.5), lineWidth: 1))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Citron Dinner Plates, Set of 4")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.espresso)
                        
                        Text("₹12,000")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.cocoa)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10))
                                .foregroundStyle(WSRegistryPalette.gold)
                            Text("Celebration Pool helped complete this")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(WSRegistryPalette.gold)
                        }
                        .padding(.top, 2)
                    }
                    Spacer()
                }
                .padding(14)
                .background(WSRegistryPalette.ivory.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.4), lineWidth: 1))
                
                // Item 2: Pasta Bowls, Set of 4 (COMPLETED as well!)
                HStack(spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + "/img10s.jpg"))
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        Text("COMPLETED")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(WSRegistryPalette.gold)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .padding(6)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.5), lineWidth: 1))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pasta Bowls, Set of 4")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.espresso)
                        
                        Text("₹6,500")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.cocoa)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(WSRegistryPalette.gold)
                            Text("Gifted by Aarav")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(WSRegistryPalette.gold)
                        }
                        .padding(.top, 2)
                    }
                    Spacer()
                }
                .padding(14)
                .background(WSRegistryPalette.ivory.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.4), lineWidth: 1))
                
                // Item 3: Smeg Espresso Machine (ALMOST COMPLETE - 31% contributed!)
                HStack(spacing: 16) {
                    ZStack(alignment: .topLeading) {
                        CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + "/img122m.jpg"))
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        Text("ACTIVE")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(WSRegistryPalette.espresso)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            .padding(6)
                    }
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.5), lineWidth: 1))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Smeg Espresso Machine")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.espresso)
                        
                        Text("₹45,000")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.cocoa)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            ProgressView(value: 14000, total: 45000)
                                .progressViewStyle(LinearProgressViewStyle(tint: WSRegistryPalette.gold))
                                .scaleEffect(x: 1, y: 0.8, anchor: .center)
                            
                            HStack {
                                Text("₹14,000 contributed")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(WSRegistryPalette.gold)
                                Spacer()
                                Text("31% Funded")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(WSRegistryPalette.warmGray)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(14)
                .background(WSRegistryPalette.ivory)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.8), lineWidth: 1))
                .shadow(color: WSRegistryPalette.espresso.opacity(0.02), radius: 6, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Aura Insight Card
    private var auraInsightCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("AURA AI COMPLETION INSIGHT")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(WSRegistryPalette.gold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("By completing this dinnerware collection, you are gifting Ananya & Rohan the beautiful privilege of hosting their very first formal dinner party in their new home with perfect coordination.")
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso.opacity(0.85))
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
            
            NavigationLink(destination: GroupGiftDetailView()) {
                Text("Help Complete with a Contribution")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cream)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(WSRegistryPalette.espresso)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(.top, 8)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [WSRegistryPalette.ivory, Color(red: 0.98, green: 0.96, blue: 0.91)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(WSRegistryPalette.gold.opacity(0.35), lineWidth: 1))
        .padding(.horizontal, 20)
    }
}
