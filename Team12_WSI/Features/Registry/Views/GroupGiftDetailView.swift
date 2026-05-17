import SwiftUI

struct GroupGiftDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var customAmount: String = ""
    @State private var selectedAmount: Int? = 5000
    @State private var showSuccess = false
    
    let price: Double = 45000
    let currentContribution: Double = 14000
    
    let presetAmounts = [2000, 5000, 10000]
    
    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - PRODUCT HERO BANNER
                    productHeroSection
                    
                    // MARK: - SOCIAL PROOF: 4 FRIENDS ACTIVITY FEED
                    friendsContributionsSection
                    
                    // MARK: - CONTRIBUTION ACTIONS
                    contributionActionsSection
                    
                    Spacer().frame(height: 40)
                }
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
        .fullScreenCover(isPresented: $showSuccess) {
            ContributionSuccessView(contributionType: .groupGift)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PopToRegistryRoot"))) { _ in
            dismiss()
        }
    }
    
    // MARK: - Product Hero Section
    private var productHeroSection: some View {
        VStack(spacing: 0) {
            // Elegant image of Smeg Espresso Machine
            ZStack(alignment: .bottomTrailing) {
                CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + "/img122m.jpg"))
                    .frame(height: 260)
                    .frame(maxWidth: .infinity)
                    .background(WSRegistryPalette.ivory)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                
                Text("Essential")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(WSRegistryPalette.gold)
                    .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .bottomRight]))
            }
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Smeg Espresso Machine")
                        .font(.system(size: 24, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Spacer()
                }
                
                Text("₹45,000")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.cocoa)
                
                Text("Help Rohan & Ananya wake up to coffee shop quality espresso in their new kitchen. This beautiful group gift lets multiple friends contribute any amount toward the total goal.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .lineSpacing(3)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
    }
    
    // MARK: - 4 Friends Contributions (Social Activity)
    private var friendsContributionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(WSRegistryPalette.gold)
                Text("Friends' Gifts & Contributions")
                    .font(.system(size: 15, weight: .bold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                // Friend 1: Aarav
                friendGiftRow(
                    name: "Aarav",
                    avatarColor: WSRegistryPalette.gold,
                    giftName: "Citron Dinner Plates, Set of 4",
                    giftImage: "/img23m.jpg",
                    message: "Can't wait to come over for dinner!"
                )
                
                // Friend 2: Riya
                friendGiftRow(
                    name: "Riya",
                    avatarColor: WSRegistryPalette.sage,
                    giftName: "Pasta Bowls, Set of 4",
                    giftImage: "/img10s.jpg",
                    message: "Wishing you both a lifetime of happiness."
                )
                
                // Friend 3: Aditya
                friendGiftRow(
                    name: "Aditya",
                    avatarColor: WSRegistryPalette.cocoa,
                    giftName: "Contributed ₹5,000",
                    giftImage: "/img122m.jpg",
                    message: "Mornings start with good coffee! Cheers!"
                )
                
                // Friend 4: Meera
                friendGiftRow(
                    name: "Meera",
                    avatarColor: Color(hex: "#786049"),
                    giftName: "Contributed ₹9,000",
                    giftImage: "/img122m.jpg",
                    message: "So excited for your beautiful future!"
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func friendGiftRow(name: String, avatarColor: Color, giftName: String, giftImage: String, message: String) -> some View {
        HStack(spacing: 12) {
            // Friend Avatar
            Text(String(name.prefix(1)))
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(avatarColor)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    
                    Text("gifted")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                    
                    Text(giftName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.gold)
                        .lineLimit(1)
                }
                
                Text("\"\(message)\"")
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.85))
            }
            
            Spacer()
            
            // Thumbnail Image of what they gifted
            CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + giftImage))
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.4), lineWidth: 0.5))
        }
        .padding(10)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
    }
    
    // MARK: - Contribution Section
    private var contributionActionsSection: some View {
        VStack(spacing: 20) {
            // PROGRESS CARD
            VStack(spacing: 8) {
                HStack {
                    Text("Group Funding Status")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.cocoa)
                    Spacer()
                    Text("31% Completed")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.gold)
                }
                
                ProgressView(value: currentContribution, total: price)
                    .progressViewStyle(LinearProgressViewStyle(tint: WSRegistryPalette.gold))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                
                HStack {
                    Text("₹\(Int(currentContribution)) Funded")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Spacer()
                    Text("₹\(Int(price - currentContribution)) Remaining")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                }
            }
            .padding(18)
            .background(WSRegistryPalette.ivory)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
            .padding(.horizontal, 20)
            
            // SELECT CONTRIBUTION AMOUNT
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Contribution Amount")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .padding(.horizontal, 4)
                
                HStack(spacing: 12) {
                    ForEach(presetAmounts, id: \.self) { amount in
                        Button(action: {
                            selectedAmount = amount
                            customAmount = ""
                        }) {
                            Text("₹\(amount)")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(selectedAmount == amount ? WSRegistryPalette.cream : WSRegistryPalette.espresso)
                                .frame(maxWidth: .infinity, minHeight: 46)
                                .background(selectedAmount == amount ? WSRegistryPalette.espresso : WSRegistryPalette.ivory)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(selectedAmount == amount ? Color.clear : WSRegistryPalette.hairline, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // OR CUSTOM AMOUNT
                HStack {
                    Text("₹")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.cocoa)
                    
                    TextField("Enter custom contribution amount", text: $customAmount)
                        .keyboardType(.numberPad)
                        .font(.system(size: 15, weight: .medium))
                        .onChange(of: customAmount) { _ in
                            selectedAmount = nil
                        }
                }
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(WSRegistryPalette.ivory)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(WSRegistryPalette.hairline, lineWidth: 1))
            }
            .padding(.horizontal, 20)
            
            // CONTRIBUTE BUTTON
            Button(action: {
                showSuccess = true
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                    Text("Contribute to Group Gift")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(WSRegistryPalette.cream)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(WSRegistryPalette.espresso)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: WSRegistryPalette.espresso.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
    }
}
