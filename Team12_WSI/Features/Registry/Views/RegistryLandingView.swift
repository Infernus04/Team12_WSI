import SwiftUI

struct RegistryLandingView: View {
    @State private var daysRemaining: Int = 45
    @State private var showRegistryList = false
    @State private var showCelebrationPool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    Image(systemName: "photo").resizable().aspectRatio(contentMode: .fill).frame(height: 400).background(Color.gray.opacity(0.3)).clipped()
                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.4)]), startPoint: .top, endPoint: .bottom).frame(height: 200)
                }
                
                VStack(spacing: RegistryTheme.Spacing.extraLarge) {
                    VStack(spacing: RegistryTheme.Spacing.small) {
                        Text(RegistryMockData.coupleName).font(RegistryTheme.Typography.heroTitle)
                        Text("October 12, 2026 • Florence, Italy").font(RegistryTheme.Typography.body).foregroundColor(RegistryTheme.Colors.secondaryText).tracking(2)
                        
                        HStack(spacing: RegistryTheme.Spacing.standard) {
                            countdownBox(value: "\(daysRemaining)", label: "Days")
                            countdownBox(value: "14", label: "Hours")
                        }
                        .padding(.top, RegistryTheme.Spacing.standard)
                    }
                    
                    Text("We are so excited to celebrate our special day with you. Your presence is the greatest gift, but if you wish to help us build our future together, we've curated a few things we love.")
                        .font(RegistryTheme.Typography.body).multilineTextAlignment(.center).padding(.horizontal)
                    
                    VStack(spacing: RegistryTheme.Spacing.small) {
                        Text("₹\(Int(RegistryMockData.totalContributed)) contributed by friends & family")
                            .font(RegistryTheme.Typography.headline)
                        ProgressView(value: 48000, total: 100000).progressViewStyle(LinearProgressViewStyle(tint: RegistryTheme.Colors.goldAccent)).padding(.horizontal)
                    }
                    .padding(RegistryTheme.Spacing.large).cardStyle()
                    
                    VStack(spacing: RegistryTheme.Spacing.standard) {
                        Button("Browse Registry") { showRegistryList = true }.buttonStyle(PrimaryButtonStyle())
                        Button { showCelebrationPool = true } label: {
                            HStack { Text("Contribute to Celebration Pool"); Image(systemName: "heart.fill").foregroundColor(RegistryTheme.Colors.accent) }
                        }.buttonStyle(SecondaryButtonStyle())
                    }
                }
                .padding(.horizontal, RegistryTheme.Spacing.large).padding(.top, RegistryTheme.Spacing.extraLarge).padding(.bottom, 60)
            }
        }
        .background(RegistryTheme.Colors.background.ignoresSafeArea())
        .fullScreenCover(isPresented: $showRegistryList) { NavigationView { RegistryProductListView() } }
        .sheet(isPresented: $showCelebrationPool) { CelebrationPoolFlowView() }
    }
    
    private func countdownBox(value: String, label: String) -> some View {
        VStack { Text(value).font(RegistryTheme.Typography.sectionTitle); Text(label.uppercased()).font(RegistryTheme.Typography.small).tracking(1) }
        .frame(width: 70, height: 70).background(Color.white).cornerRadius(RegistryTheme.CornerRadius.standard).shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
