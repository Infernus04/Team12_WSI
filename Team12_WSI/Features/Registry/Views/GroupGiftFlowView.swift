import SwiftUI

struct GroupGiftFlowView: View {
    let item: ReceiverRegistryItem
    @Environment(\.presentationMode) var presentationMode
    @State private var customAmount: String = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                RegistryTheme.Colors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: RegistryTheme.Spacing.large) {
                        Text("Group Gift for\n\(item.name)").font(RegistryTheme.Typography.sectionTitle).multilineTextAlignment(.center).padding(.top)
                        VStack(alignment: .leading) {
                            Text("Your Contribution").font(RegistryTheme.Typography.headline)
                            HStack { Text("₹").foregroundColor(.gray); TextField("0", text: $customAmount).keyboardType(.numberPad).font(RegistryTheme.Typography.heroTitle) }
                            .padding().background(Color.white).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 1))
                            Text("If goal is not reached, contributions convert into celebration credits.").font(RegistryTheme.Typography.small).foregroundColor(RegistryTheme.Colors.secondaryText)
                        }.padding(.horizontal)
                        Spacer(minLength: 80)
                    }
                }
                VStack { Spacer(); Button("Contribute to Group Gift") { showSuccess = true }.buttonStyle(PrimaryButtonStyle()).padding().background(Color.white) }
            }
            .navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() }.foregroundColor(.black))
            .fullScreenCover(isPresented: $showSuccess) { ContributionSuccessView(contributionType: .groupGift) }
        }
    }
}
