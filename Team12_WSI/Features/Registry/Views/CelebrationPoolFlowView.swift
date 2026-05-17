import SwiftUI

struct CelebrationPoolFlowView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var customAmount: String = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                RegistryTheme.Colors.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: RegistryTheme.Spacing.large) {
                        VStack(alignment: .leading) { Text("Help them build their future home ❤️").font(RegistryTheme.Typography.heroTitle); Text("Your contribution goes directly towards their most meaningful registry items.") }.padding(.top)
                        
                        VStack(alignment: .leading) {
                            Text("Select Amount").font(RegistryTheme.Typography.headline)
                            HStack { Text("₹").foregroundColor(.gray); TextField("Custom Amount", text: $customAmount).keyboardType(.numberPad).font(RegistryTheme.Typography.headline) }
                            .padding().background(Color.white).cornerRadius(12).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 1))
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "sparkles").foregroundColor(RegistryTheme.Colors.goldAccent)
                            VStack(alignment: .leading) { Text("AI-Powered Gifting").font(.headline); Text("Your contribution will intelligently help complete their most meaningful registry items.").font(.caption) }
                        }.padding().background(RegistryTheme.Colors.goldAccent.opacity(0.1)).cornerRadius(12)
                        Spacer(minLength: 80)
                    }.padding(.horizontal)
                }
                VStack { Spacer(); Button("Contribute ❤️") { showSuccess = true }.buttonStyle(PrimaryButtonStyle()).padding().background(Color.white) }
            }
            .navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }.foregroundColor(.black))
            .fullScreenCover(isPresented: $showSuccess) { ContributionSuccessView(contributionType: .celebrationPool) }
        }
    }
}
