import SwiftUI

struct RegistryLandingView: View {
    @State private var daysRemaining: Int = 45
    @State private var showRegistryList = false
    @State private var showCelebrationPool = false
    @State private var heroAppeared = false
    @State private var contentAppeared = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Full-page scroll
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // MARK: - IMMERSIVE HERO
                        heroSection(geometry: geometry)
                        
                        // MARK: - CONTENT BELOW HERO
                        contentSection
                    }
                }
                
                // MARK: - STICKY CTAs
                stickyBottomCTAs
            }
            .overlay(alignment: .topLeading) {
                // Floating back button
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.ultraThinMaterial)
                        .background(Color.black.opacity(0.15))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .padding(.top, 56)
                .padding(.leading, 20)
            }
        }
        .background(WSRegistryPalette.porcelain.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(isPresented: $showRegistryList) {
            NavigationView { RegistryProductListView() }
        }
        .sheet(isPresented: $showCelebrationPool) {
            CelebrationPoolFlowView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                heroAppeared = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                contentAppeared = true
            }
        }
    }
    
    // MARK: - Hero Section
    
    private func heroSection(geometry: GeometryProxy) -> some View {
        let heroImageHeight = geometry.size.height * 0.72
        
        return ZStack(alignment: .top) {
            // Full-bleed image flooding behind dynamic island
            Image("giftdna_living_room")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: heroImageHeight)
                .clipped()
                .overlay(
                    // Seamless fade: image dissolves into porcelain background
                    LinearGradient(
                        stops: [
                            .init(color: Color.clear, location: 0.0),
                            .init(color: Color(red: 0.12, green: 0.08, blue: 0.05).opacity(0.08), location: 0.25),
                            .init(color: Color(red: 0.12, green: 0.08, blue: 0.05).opacity(0.30), location: 0.50),
                            .init(color: Color(red: 0.12, green: 0.08, blue: 0.05).opacity(0.55), location: 0.68),
                            .init(color: WSRegistryPalette.porcelain.opacity(0.80), location: 0.85),
                            .init(color: WSRegistryPalette.porcelain, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // All content flows over the fading image
            VStack(spacing: 0) {
                Spacer().frame(height: heroImageHeight * 0.42)
                
                // Couple Names — on the darker gradient zone
                Text(RegistryMockData.coupleName)
                    .font(.system(size: 42, weight: .regular, design: .serif))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 4)
                    .opacity(heroAppeared ? 1 : 0)
                    .offset(y: heroAppeared ? 0 : 20)
                
                Spacer().frame(height: 12)
                
                // Date
                Text("October 12, 2026  •  Florence, Italy")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .tracking(2.0)
                    .textCase(.uppercase)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
                    .opacity(heroAppeared ? 1 : 0)
                    .offset(y: heroAppeared ? 0 : 12)
                
                Spacer().frame(height: 28)
                
                // Countdown Cards — sitting in the transition zone
                HStack(spacing: 20) {
                    countdownCard(value: "\(daysRemaining)", label: "DAYS")
                    countdownCard(value: "14", label: "HOURS")
                }
                .opacity(heroAppeared ? 1 : 0)
                .offset(y: heroAppeared ? 0 : 16)
                
                Spacer().frame(height: 36)
                
                // Quote section — flows seamlessly below the fade
                quoteSection
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 20)
            }
        }
    }
    
    // MARK: - Content Section
    
    private var contentSection: some View {
        VStack(spacing: 0) {
            // Extra space for sticky CTAs
            Spacer().frame(height: 160)
        }
    }
    
    // MARK: - Quote Section
    
    private var quoteSection: some View {
        VStack(spacing: 24) {
            // Decorative quote mark
            Text("\u{201C}")
                .font(.system(size: 56, weight: .bold, design: .serif))
                .foregroundStyle(WSRegistryPalette.gold.opacity(0.45))
                .frame(height: 30)
                .padding(.top, 44)
            
            Text("We are so excited to celebrate our special day with you. Your presence is the greatest gift, but if you wish to help us build our future together, we've curated a few things we love.")
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineSpacing(7)
                .padding(.horizontal, 36)
            
            // Subtle decorative divider
            HStack(spacing: 12) {
                Rectangle()
                    .fill(WSRegistryPalette.hairline.opacity(0.5))
                    .frame(width: 40, height: 0.5)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(WSRegistryPalette.gold.opacity(0.5))
                Rectangle()
                    .fill(WSRegistryPalette.hairline.opacity(0.5))
                    .frame(width: 40, height: 0.5)
            }
            .padding(.top, 8)
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Sticky Bottom CTAs
    
    private var stickyBottomCTAs: some View {
        VStack(spacing: 14) {
            // Primary CTA
            Button {
                showRegistryList = true
            } label: {
                Text("Browse Registry")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cream)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(WSRegistryPalette.espresso)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: WSRegistryPalette.espresso.opacity(0.2), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            
            // Secondary CTA
            Button {
                showCelebrationPool = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(WSRegistryPalette.gold)
                    
                    Text("Contribute to Celebration Pool")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                }
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(WSRegistryPalette.gold.opacity(0.35), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
        .padding(.top, 16)
        .background(
            LinearGradient(
                colors: [
                    WSRegistryPalette.porcelain.opacity(0),
                    WSRegistryPalette.porcelain.opacity(0.85),
                    WSRegistryPalette.porcelain
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }
    
    // MARK: - Countdown Card
    
    private func countdownCard(value: String, label: String) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .tracking(2.0)
        }
        .frame(width: 90, height: 90)
        .background(.ultraThinMaterial)
        .background(WSRegistryPalette.ivory.opacity(0.75))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Helper Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
