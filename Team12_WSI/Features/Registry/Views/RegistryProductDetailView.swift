import SwiftUI

struct RegistryProductDetailView: View {
    let item: ReceiverRegistryItem
    @State private var showGroupGiftFlow = false
    @State private var showCelebrationPoolFlow = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + item.imagePath))
                    .aspectRatio(1.0, contentMode: .fit)
                VStack(alignment: .leading, spacing: RegistryTheme.Spacing.large) {
                    HStack {
                        if item.isPriority { Text("PRIORITY").font(RegistryTheme.Typography.caption).padding(6).background(RegistryTheme.Colors.primaryText).foregroundColor(.white).cornerRadius(4) }
                        if let collection = item.collection { Text("Part of \(collection.name)").font(RegistryTheme.Typography.caption).padding(6).background(RegistryTheme.Colors.separator).cornerRadius(4) }
                    }
                    VStack(alignment: .leading) { Text(item.name).font(RegistryTheme.Typography.heroTitle); Text("₹\(Int(item.price))").font(RegistryTheme.Typography.sectionTitle).foregroundColor(RegistryTheme.Colors.secondaryText) }
                    Text(item.description).font(RegistryTheme.Typography.body).foregroundColor(RegistryTheme.Colors.secondaryText).lineSpacing(4)
                    
                    Divider()
                    
                    // Actions
                    VStack(spacing: RegistryTheme.Spacing.large) {
                        Text("Gifting Options").font(RegistryTheme.Typography.headline)
                        Button(action: { showGroupGiftFlow = true }) { HStack { VStack(alignment: .leading) { Text("Join Group Gift").font(RegistryTheme.Typography.headline); Text("Collaborate with others").font(RegistryTheme.Typography.caption) }; Spacer(); Image(systemName: "person.3") } }.buttonStyle(SecondaryButtonStyle())
                        Button(action: { showCelebrationPoolFlow = true }) { HStack { VStack(alignment: .leading) { Text("Contribute via Celebration Pool").font(RegistryTheme.Typography.headline); Text("Let AI allocate to meaningful items").font(RegistryTheme.Typography.caption) }; Spacer(); Image(systemName: "heart.fill").foregroundColor(RegistryTheme.Colors.accent) } }.buttonStyle(PrimaryButtonStyle())
                    }
                }.padding()
            }
        }
        .background(RegistryTheme.Colors.cardBackground.ignoresSafeArea())
        .sheet(isPresented: $showGroupGiftFlow) { GroupGiftFlowView(item: item) }
        .sheet(isPresented: $showCelebrationPoolFlow) { CelebrationPoolFlowView() }
    }
}
