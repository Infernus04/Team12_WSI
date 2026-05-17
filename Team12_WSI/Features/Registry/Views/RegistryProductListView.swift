import SwiftUI

struct RegistryProductListView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: RegistryTheme.Spacing.large) {
                Text("Registry").font(RegistryTheme.Typography.heroTitle).padding(.horizontal).padding(.top)
                
                // Example of Collection Progress
                VStack(alignment: .leading, spacing: RegistryTheme.Spacing.standard) {
                    HStack { Text(RegistryMockData.citronCollection.name).font(RegistryTheme.Typography.headline); Spacer(); Text("82% Complete").font(RegistryTheme.Typography.caption).foregroundColor(RegistryTheme.Colors.goldAccent) }
                    ProgressView(value: 82, total: 100).progressViewStyle(LinearProgressViewStyle(tint: RegistryTheme.Colors.goldAccent))
                }.padding().cardStyle().padding(.horizontal)
                
                LazyVStack(spacing: RegistryTheme.Spacing.large) {
                    ForEach(RegistryMockData.items) { item in
                        NavigationLink(destination: ProductDetailView(item: item)) { RegistryProductCardView(item: item) }.buttonStyle(PlainButtonStyle())
                    }
                }.padding(.horizontal).padding(.bottom, 40)
            }
        }
        .background(RegistryTheme.Colors.background.ignoresSafeArea())
        .navigationBarItems(leading: Button(action: { presentationMode.wrappedValue.dismiss() }) { Image(systemName: "xmark").foregroundColor(RegistryTheme.Colors.primaryText) })
    }
}

struct RegistryProductCardView: View {
    let item: ReceiverRegistryItem
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                Rectangle().fill(Color(white: 0.95)).aspectRatio(1.2, contentMode: .fit).overlay(Image(systemName: item.imageName).resizable().scaledToFit().padding(40).foregroundColor(.gray))
                if item.isPriority { Text("PRIORITY").font(RegistryTheme.Typography.small).padding(6).background(Color.white.opacity(0.9)).cornerRadius(4).padding(12) }
            }
            VStack(alignment: .leading, spacing: RegistryTheme.Spacing.small) {
                if let collection = item.collection { Text(collection.name.uppercased()).font(RegistryTheme.Typography.small).foregroundColor(RegistryTheme.Colors.secondaryText) }
                HStack { Text(item.name).font(RegistryTheme.Typography.headline).lineLimit(2); Spacer(); Text("₹\(Int(item.price))") }
                
                if item.state == .groupGiftActive, let groupGift = item.groupGift {
                    ProgressView(value: groupGift.currentContribution, total: groupGift.totalAmountNeeded).progressViewStyle(LinearProgressViewStyle(tint: RegistryTheme.Colors.primaryText))
                    Text("₹\(Int(groupGift.currentContribution)) / ₹\(Int(groupGift.totalAmountNeeded)) contributed").font(RegistryTheme.Typography.caption).foregroundColor(RegistryTheme.Colors.secondaryText)
                } else if item.state == .celebrationPoolAssisted {
                    HStack { Image(systemName: "sparkles").foregroundColor(RegistryTheme.Colors.goldAccent); Text("Celebration Pool helped complete this").font(RegistryTheme.Typography.caption) }
                }
            }.padding()
        }.cardStyle()
    }
}
