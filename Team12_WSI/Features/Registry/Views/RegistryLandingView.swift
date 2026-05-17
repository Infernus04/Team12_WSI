import SwiftUI

struct RegistryLandingView: View {
    @State private var daysRemaining: Int = 45
    @State private var showRegistryList = false
    @State private var showCelebrationPool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // HERO IMAGE
                    ZStack(alignment: .bottom) {
                        Image("giftdna_living_room") // Premium wedding/lifestyle placeholder
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.38)
                            .clipped()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, WSRegistryPalette.espresso.opacity(0.55)]),
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .frame(height: 160)
                    }
                    .clipShape(
                        RoundedCorner(radius: 36, corners: [.bottomLeft, .bottomRight])
                    )
                    .shadow(color: WSRegistryPalette.espresso.opacity(0.12), radius: 18, x: 0, y: 8)
                    
                    VStack(spacing: 36) {
                        // COUPLE IDENTITY & EVENT CONTEXT
                        VStack(spacing: 8) {
                            Text(RegistryMockData.coupleName)
                                .font(.system(size: 34, weight: .regular, design: .serif))
                                .foregroundStyle(WSRegistryPalette.espresso)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            
                            Text("October 12, 2026 • Florence, Italy")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(WSRegistryPalette.warmGray)
                                .tracking(1.5)
                        }
                        .padding(.top, 28)
                        
                        // COUNTDOWN
                        HStack(spacing: 24) {
                            countdownBox(value: "\(daysRemaining)", label: "Days")
                            countdownBox(value: "14", label: "Hours")
                        }
                        
                        // PERSONAL MESSAGE
                        VStack(spacing: 12) {
                            Text("“")
                                .font(.system(size: 40, weight: .bold, design: .serif))
                                .foregroundStyle(WSRegistryPalette.gold.opacity(0.6))
                                .frame(height: 20)
                            
                            Text("We are so excited to celebrate our special day with you. Your presence is the greatest gift, but if you wish to help us build our future together, we've curated a few things we love.")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .lineSpacing(5)
                                .padding(.horizontal, 32)
                        }
                        
                        // CONTRIBUTION MOMENTUM (PREMIUM CARD)
                        VStack(alignment: .leading, spacing: 18) {
                            Text("₹\(Int(RegistryMockData.totalContributed)) contributed")
                                .font(.system(size: 20, weight: .semibold, design: .serif))
                                .foregroundStyle(WSRegistryPalette.espresso)
                            
                            ProgressView(value: 48000, total: 100000)
                                .progressViewStyle(LinearProgressViewStyle(tint: WSRegistryPalette.gold))
                                .scaleEffect(x: 1, y: 1.2, anchor: .center)
                            
                            Text("Helping \(RegistryMockData.coupleName) build their future home")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(WSRegistryPalette.warmGray)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(WSRegistryPalette.ivory)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(WSRegistryPalette.hairline.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(color: WSRegistryPalette.espresso.opacity(0.05), radius: 15, x: 0, y: 6)
                        .padding(.horizontal, 24)
                        
                        // CTAs
                        VStack(spacing: 16) {
                            // Primary CTA
                            Button {
                                showRegistryList = true
                            } label: {
                                Text("Browse Registry")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(WSRegistryPalette.cream)
                                    .frame(maxWidth: .infinity, minHeight: 58)
                                    .background(WSRegistryPalette.espresso)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .shadow(color: WSRegistryPalette.espresso.opacity(0.15), radius: 10, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                            
                            // Emotional Contribution CTA
                            Button {
                                showCelebrationPool = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 15))
                                        .foregroundStyle(WSRegistryPalette.gold)
                                    
                                    Text("Contribute to Celebration Pool")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(WSRegistryPalette.cocoa)
                                }
                                .frame(maxWidth: .infinity, minHeight: 58)
                                .background(WSRegistryPalette.ivory)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(WSRegistryPalette.gold.opacity(0.4), lineWidth: 1)
                                )
                                .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                    }
                }
            }
        }
        .background(WSRegistryPalette.porcelain.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showRegistryList) { 
            NavigationView { RegistryProductListView() }
        }
        .sheet(isPresented: $showCelebrationPool) { 
            CelebrationPoolFlowView()
        }
    }
    
    private func countdownBox(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .tracking(1.5)
        }
        .frame(width: 86, height: 86)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 12, x: 0, y: 6)
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
