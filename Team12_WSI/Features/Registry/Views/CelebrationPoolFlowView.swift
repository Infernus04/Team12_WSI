import SwiftUI

struct CelebrationPoolFlowView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                        // 1. Emotional Header
                        headerSection
                        
                        // 2. Pool Summary Card
                        poolSummaryCard
                        
                        // 3. Contribution CTA
                        contributionCTA
                        
                        // 4. Active Milestones
                        activeMilestonesSection
                        
                        // 5. Who’s Gifted Section
                        whosGiftedSection
                    }
                    .padding(.bottom, 60)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.espresso)
                            .frame(width: 32, height: 32)
                            .background(WSRegistryPalette.ivory)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PopToRegistryRoot"))) { _ in
                dismiss()
            }
        }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("\(RegistryMockData.coupleName)’s Registry")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .tracking(1.2)
                .textCase(.uppercase)
            
            Text("Celebration Pool")
                .font(.system(size: 32, weight: .regular, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
        }
        .padding(.top, 10)
    }
    
    private var poolSummaryCard: some View {
        VStack(spacing: 12) {
            // 1. Elegant Top Ribbon & Title
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(WSRegistryPalette.gold)
                
                Text("THE CELEBRATION GIFT FUND")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2.0)
                    .foregroundStyle(WSRegistryPalette.gold)
                
                Spacer()
                
                Image(systemName: "sparkles")
                    .font(.system(size: 13))
                    .foregroundStyle(WSRegistryPalette.gold)
            }
            
            // 2. Compact Content Row (Visual Stack on Left, Info on Right)
            HStack(spacing: 16) {
                // overlapping gift thumbnails
                HStack(spacing: -10) {
                    giftThumbnail(imagePath: "/img10s.jpg") // Pasta Bowls
                    giftThumbnail(imagePath: "/img4m.jpg")  // Wine Glasses
                    giftThumbnail(imagePath: "/img23m.jpg") // Dinner Plates
                    
                    Text("+3")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(WSRegistryPalette.cream)
                        .frame(width: 36, height: 36)
                        .background(WSRegistryPalette.espresso)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(WSRegistryPalette.ivory, lineWidth: 1.5))
                        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("6 Gifts Fully Unlocked")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    
                    Text("₹36,900 from 24 friends & family")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            // 3. Ultra-subtle Progress Indicator (Thin golden bar at the bottom)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(WSRegistryPalette.hairline.opacity(0.6))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(WSRegistryPalette.gold)
                        .frame(width: geo.size.width * 0.738, height: 4) // 36900 / 50000 = 73.8%
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(WSRegistryPalette.gold.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.03), radius: 10, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
    
    private func giftThumbnail(imagePath: String) -> some View {
        CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + imagePath))
            .frame(width: 36, height: 36)
            .clipShape(Circle())
            .overlay(Circle().stroke(WSRegistryPalette.ivory, lineWidth: 1.5))
            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
    
    private var contributionCTA: some View {
        NavigationLink(destination: CelebrationPoolContributionView()) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 14, weight: .bold))
                Text("Contribute to Celebration Fund")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(WSRegistryPalette.cream)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(WSRegistryPalette.espresso)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: WSRegistryPalette.espresso.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }
    
    private var activeMilestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What the pool is helping complete")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                // Completed Items
                completedMilestoneRow(name: "Pasta Bowl Collection", imagePath: "/img10s.jpg")
                completedMilestoneRow(name: "Wine Glass Set", imagePath: "/img4m.jpg")
                
                // Current Active Item
                currentMilestoneRow(name: "Espresso Machine", imagePath: "/img122m.jpg", current: 14000, total: 45000)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func completedMilestoneRow(name: String, imagePath: String) -> some View {
        HStack(spacing: 12) {
            CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + imagePath))
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(WSRegistryPalette.hairline, lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(WSRegistryPalette.sage)
                    Text("Fully Completed & Gifted")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.sage)
                }
            }
            
            Spacer()
            
            Text("Completed")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(WSRegistryPalette.sage)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(WSRegistryPalette.sage.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(12)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
    }
    
    private func currentMilestoneRow(name: String, imagePath: String, current: Double, total: Double) -> some View {
        HStack(spacing: 12) {
            CustomAsyncImage(url: URL(string: AppConstants.API.imageBasePath + imagePath))
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous).stroke(WSRegistryPalette.hairline, lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Spacer()
                    Text("₹\(Int(current)) / ₹\(Int(total)) progressing")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                }
                
                ProgressView(value: current, total: total)
                    .progressViewStyle(LinearProgressViewStyle(tint: WSRegistryPalette.gold))
            }
        }
        .padding(12)
        .background(WSRegistryPalette.ivory)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(WSRegistryPalette.gold.opacity(0.4), lineWidth: 1))
        .shadow(color: WSRegistryPalette.gold.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var whosGiftedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Community Love")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundStyle(WSRegistryPalette.espresso)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                giftedRow(name: "Priya M.", emoji: "☕", text: "helped unlock the Smeg Espresso Machine", time: "2h ago")
                giftedRow(name: "Rahul & Sneha", emoji: "🍽️", text: "helped complete the Dinner Set", time: "Yesterday")
                giftedRow(name: "Ananya K.", emoji: "🍜", text: "helped unlock the Pasta Bowl Collection", time: "2 days ago")
                giftedRow(name: "The Sharma Family", emoji: "🥂", text: "contributed to future celebrations", time: "3 days ago")
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func giftedRow(name: String, emoji: String, text: String, time: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji)
                .font(.system(size: 20))
                .frame(width: 44, height: 44)
                .background(WSRegistryPalette.porcelain)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                
                Text(text)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.cocoa.opacity(0.9))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(WSRegistryPalette.warmGray)
                .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Dedicated Contribution Full Screen
struct CelebrationPoolContributionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var customAmount: String = ""
    @State private var personalMessage: String = ""
    
    var body: some View {
        ZStack {
            WSRegistryPalette.ivory.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Text("\(RegistryMockData.coupleName)’s Registry")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                            .tracking(1.2)
                            .textCase(.uppercase)
                        
                        Text("Your Gift")
                            .font(.system(size: 28, weight: .regular, design: .serif))
                            .foregroundStyle(WSRegistryPalette.espresso)
                        
                        Text("Join friends and family in helping build their future home.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.warmGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 20)
                    
                    // Amount Entry
                    VStack(spacing: 16) {
                        HStack(alignment: .center, spacing: 4) {
                            Text("₹")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(WSRegistryPalette.warmGray)
                            
                            TextField("0", text: $customAmount)
                                .keyboardType(.numberPad)
                                .font(.system(size: 48, weight: .semibold))
                                .foregroundStyle(WSRegistryPalette.espresso)
                                .multilineTextAlignment(.center)
                                .fixedSize()
                        }
                        .frame(maxWidth: .infinity, minHeight: 80)
                        
                        // Optional Subtle Presets
                        HStack(spacing: 12) {
                            subtlePreset("1,000")
                            subtlePreset("2,500")
                            subtlePreset("5,000")
                        }
                    }
                    
                    // Personal Message
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add a Personal Note (Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(WSRegistryPalette.cocoa)
                        
                        TextField("Wishing you beautiful memories ahead ❤️", text: $personalMessage, axis: .vertical)
                            .lineLimit(3...5)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.espresso)
                            .padding(16)
                            .background(WSRegistryPalette.porcelain)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
            
            // Sticky CTA
            VStack {
                Spacer()
                NavigationLink(destination: PaymentMethodSelectionView(amount: customAmount, note: personalMessage)) {
                    Text("Continue to Payment")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.cream)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(customAmount.isEmpty ? WSRegistryPalette.warmGray.opacity(0.5) : WSRegistryPalette.espresso)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(customAmount.isEmpty)
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [WSRegistryPalette.ivory.opacity(0), WSRegistryPalette.ivory, WSRegistryPalette.ivory],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .ignoresSafeArea(.keyboard)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func subtlePreset(_ amount: String) -> some View {
        Button(action: { customAmount = amount.replacingOccurrences(of: ",", with: "") }) {
            Text("₹\(amount)")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(WSRegistryPalette.cocoa)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(WSRegistryPalette.porcelain)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(WSRegistryPalette.hairline.opacity(0.6), lineWidth: 1))
        }
    }
}

// MARK: - Payment Method Selection View
struct PaymentMethodSelectionView: View {
    let amount: String
    let note: String
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedMethod: String = "UPI"
    @State private var isSimulatingPayment = false
    @State private var showSuccess = false
    
    let methods = [
        ("UPI", "qrcode.viewfinder"),
        ("Credit / Debit Card", "creditcard"),
        ("Net Banking", "building.columns"),
        ("Apple Pay", "applelogo"),
        ("Wallet", "wallet.pass")
    ]
    
    var body: some View {
        ZStack {
            WSRegistryPalette.porcelain.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Choose Payment Method")
                        .font(.system(size: 24, weight: .regular, design: .serif))
                        .foregroundStyle(WSRegistryPalette.espresso)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        ForEach(methods, id: \.0) { method in
                            Button(action: { selectedMethod = method.0 }) {
                                HStack(spacing: 16) {
                                    Image(systemName: method.1)
                                        .font(.system(size: 20))
                                        .foregroundStyle(selectedMethod == method.0 ? WSRegistryPalette.espresso : WSRegistryPalette.warmGray)
                                        .frame(width: 32)
                                    
                                    Text(method.0)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(WSRegistryPalette.espresso)
                                    
                                    Spacer()
                                    
                                    if selectedMethod == method.0 {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundStyle(WSRegistryPalette.espresso)
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(WSRegistryPalette.hairline)
                                    }
                                }
                                .padding(16)
                                .background(WSRegistryPalette.ivory)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(selectedMethod == method.0 ? WSRegistryPalette.espresso : WSRegistryPalette.hairline.opacity(0.6), lineWidth: selectedMethod == method.0 ? 2 : 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Sticky CTA
            VStack {
                Spacer()
                Button(action: {
                    isSimulatingPayment = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isSimulatingPayment = false
                        showSuccess = true
                    }
                }) {
                    HStack {
                        if isSimulatingPayment {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: WSRegistryPalette.cream))
                                .padding(.trailing, 8)
                        }
                        Text("Complete Gift (₹\(amount))")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(WSRegistryPalette.cream)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(isSimulatingPayment ? WSRegistryPalette.espresso.opacity(0.8) : WSRegistryPalette.espresso)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(isSimulatingPayment)
                .padding(24)
                .background(
                    LinearGradient(
                        colors: [WSRegistryPalette.porcelain.opacity(0), WSRegistryPalette.porcelain, WSRegistryPalette.porcelain],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            // Hidden navigation link for programmatic push
            NavigationLink(
                destination: CelebrationPoolSuccessView(amount: amount, note: note),
                isActive: $showSuccess
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Emotional Success Screen
struct CelebrationPoolSuccessView: View {
    let amount: String
    let note: String
    @Environment(\.dismiss) var dismiss
    @State private var isVisible = false
    
    var body: some View {
        ZStack {
            WSRegistryPalette.ivory.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    
                    // 1. Icon & Title
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 56, weight: .light))
                            .foregroundStyle(WSRegistryPalette.gold)
                        
                        Text("Thank You for Your Gift")
                            .font(.system(size: 32, weight: .regular, design: .serif))
                            .foregroundStyle(WSRegistryPalette.espresso)
                        
                        Text("You contributed ₹\(amount) in celebration credits toward \(RegistryMockData.coupleName)’s registry.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(WSRegistryPalette.cocoa)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 40)
                    
                    // 2. Exact Impact Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(WSRegistryPalette.sage)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pasta Bowl Collection Completed")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(WSRegistryPalette.espresso)
                                
                                Text("Your gift helped unlock this meaningful item.")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(WSRegistryPalette.cocoa)
                            }
                        }
                        
                        Divider().background(WSRegistryPalette.hairline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Completed with help from:")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(WSRegistryPalette.warmGray)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("• Priya M.")
                                Text("• Rahul & Sneha")
                                Text("• You ❤️")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(WSRegistryPalette.espresso)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: WSRegistryPalette.espresso.opacity(0.04), radius: 15, x: 0, y: 8)
                    .padding(.horizontal, 24)
                    
                    // 3. Optional Personal Note
                    if !note.isEmpty {
                        VStack(spacing: 12) {
                            Text("Your personal note was attached to this gift.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(WSRegistryPalette.espresso)
                            
                            Text("“\(note)”")
                                .font(.system(size: 15, weight: .regular, design: .serif))
                                .foregroundStyle(WSRegistryPalette.cocoa)
                                .multilineTextAlignment(.center)
                                .italic()
                                .padding(.horizontal, 32)
                        }
                    }
                    
                    // 4. Emotional Anchor
                    Text("The couple will remember you helped build their future home.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 10)
                    
                    Spacer(minLength: 40)
                    
                    // 5. Actions
                    VStack(spacing: 16) {
                        Button(action: {
                            // Dismiss the entire receiver flow and present Browse Registry
                            // cleanly from RegistryView root — no stacked covers.
                            NotificationCenter.default.post(name: NSNotification.Name("OpenBrowseRegistryFromRoot"), object: nil)
                        }) {
                            Text("Continue Browsing Registry")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(WSRegistryPalette.cream)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(WSRegistryPalette.espresso)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        
                        Button(action: { dismiss() }) {
                            Text("View Celebration Pool")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(WSRegistryPalette.espresso)
                                .frame(maxWidth: .infinity, minHeight: 56)
                                .background(Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.96)
            .onAppear {
                withAnimation(.easeOut(duration: 0.8)) {
                    isVisible = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
