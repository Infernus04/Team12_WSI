import SwiftUI

enum ContributionType { case groupGift, celebrationPool }

struct ContributionSuccessView: View {
    let contributionType: ContributionType
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            RegistryTheme.Colors.background.ignoresSafeArea()
            VStack(spacing: RegistryTheme.Spacing.large) {
                Spacer()
                Image(systemName: "heart.fill").resizable().frame(width: 80, height: 80).foregroundColor(RegistryTheme.Colors.accent)
                Text("Thank You!").font(RegistryTheme.Typography.heroTitle)
                
                if contributionType == .celebrationPool {
                    Text("Your contribution helped complete:\n✓ Citron Dinner Plates\n✓ 18% of Pasta Bowl Collection")
                        .font(RegistryTheme.Typography.headline).multilineTextAlignment(.center)
                }
                Text("Your message has been attached to these gifts ❤️\nThe couple will remember you helped build their future home.")
                    .font(RegistryTheme.Typography.body).multilineTextAlignment(.center).padding()
                
                Spacer()
                Button("Back to Registry") { presentationMode.wrappedValue.dismiss() }.buttonStyle(PrimaryButtonStyle()).padding()
            }
        }
    }
}
