//
//  RegistryView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 03/04/26.
//

import SwiftUI

enum RegistryRoute: Hashable {
    case create
    case success
}

enum WSRegistryPalette {
    static let ivory = Color(red: 0.975, green: 0.956, blue: 0.922)
    static let cream = Color(red: 0.992, green: 0.984, blue: 0.962)
    static let porcelain = Color(red: 0.998, green: 0.996, blue: 0.988)
    static let espresso = Color(red: 0.185, green: 0.125, blue: 0.086)
    static let cocoa = Color(red: 0.355, green: 0.260, blue: 0.188)
    static let gold = Color(red: 0.680, green: 0.545, blue: 0.285)
    static let sage = Color(red: 0.475, green: 0.545, blue: 0.420)
    static let warmGray = Color(red: 0.500, green: 0.470, blue: 0.425)
    static let hairline = Color(red: 0.855, green: 0.825, blue: 0.770)
}

struct RegistryView: View {
    
    @StateObject private var viewModel = RegistryViewModel()
    
    @EnvironmentObject var registryRepo: RegistryRepository
    @EnvironmentObject var cartRepo: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    var body: some View {
        NavigationStack(path: $tabBarVM.registryPath) {
            ZStack {
                WSRegistryPalette.ivory
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        heroImage
                        primaryCTACard
                        readinessCard
                        secondaryActions
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 116)
                }
                .scrollClipDisabled(false)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(WSRegistryPalette.espresso)
                            .frame(width: 36, height: 36)
                            .background(WSRegistryPalette.porcelain, in: Circle())
                            .overlay(
                                Circle()
                                    .stroke(WSRegistryPalette.hairline.opacity(0.55), lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("Notifications")
                }
            }
            .navigationDestination(for: RegistryRoute.self) { route in
                switch route {
                case .create:
                    CreateRegistryView()
                case .success:
                    RegistrySuccessView()
                }
            }
        }
        .onAppear {
            viewModel.bind(repository: registryRepo)
        }
    }
}

private extension RegistryView {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("WILLIAMS SONOMA")
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .tracking(1.8)
                .foregroundStyle(WSRegistryPalette.espresso)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Home Registry")
                    .font(.system(size: 39, weight: .regular, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .lineSpacing(1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                
                Text("Build the home you’ll grow into.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
    
    var heroImage: some View {
        GeometryReader { proxy in
            Image("giftdna_living_room")
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: 218)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: WSRegistryPalette.espresso.opacity(0.10), radius: 18, x: 0, y: 10)
        }
        .frame(height: 218)
        .frame(maxWidth: .infinity)
    }
    
    var primaryCTACard: some View {
        Button {
            tabBarVM.registryPath.append(RegistryRoute.create)
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.gold)
                    .frame(width: 48, height: 48)
                    .background(WSRegistryPalette.cream.opacity(0.10), in: Circle())
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Start Your Home Profile")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.cream)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    Text("Create your intelligent registry")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.cream.opacity(0.72))
                        .lineLimit(1)
                        .minimumScaleFactor(0.88)
                }
                
                Spacer(minLength: 8)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.gold)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
            .background {
                LinearGradient(
                    colors: [
                        WSRegistryPalette.espresso,
                        Color(red: 0.245, green: 0.165, blue: 0.110),
                        WSRegistryPalette.cocoa
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(WSRegistryPalette.gold.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: WSRegistryPalette.espresso.opacity(0.18), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }
    
    var readinessCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Your Home Readiness")
                    .font(.system(size: 23, weight: .semibold, design: .serif))
                    .foregroundStyle(WSRegistryPalette.espresso)
                Text("AI builds your registry around how you live.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
            }
            
            VStack(spacing: 18) {
                ForEach(RegistryReadinessItem.samples) { item in
                    readinessRow(item)
                }
            }
            
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(WSRegistryPalette.sage)
                    .padding(.top, 1)
                Text("We’ll help you fill the gaps and complete your home.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(WSRegistryPalette.warmGray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(WSRegistryPalette.sage.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(WSRegistryPalette.hairline.opacity(0.78), lineWidth: 1)
        )
        .shadow(color: WSRegistryPalette.espresso.opacity(0.07), radius: 18, x: 0, y: 10)
    }
    
    func readinessRow(_ item: RegistryReadinessItem) -> some View {
        VStack(spacing: 9) {
            HStack(spacing: 12) {
                Image(systemName: item.systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cocoa)
                    .frame(width: 34, height: 34)
                    .background(WSRegistryPalette.ivory, in: Circle())
                
                Text(item.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                
                Spacer()
                
                Text("\(item.percent)%")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.cocoa)
                    .monospacedDigit()
            }
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(WSRegistryPalette.ivory)
                    Capsule()
                        .fill(item.tint)
                        .frame(width: max(8, proxy.size.width * CGFloat(item.percent) / 100))
                }
            }
            .frame(height: 5)
        }
    }
    
    var secondaryActions: some View {
        VStack(spacing: 12) {
            actionRow(
                icon: "magnifyingglass",
                title: "Find a Registry",
                subtitle: "Search by name or email"
            )
            actionRow(
                icon: "heart.text.square",
                title: "Manage My Registry",
                subtitle: "View, edit and track your registry"
            )
            actionRow(
                icon: "link",
                title: "Link a Store Registry",
                subtitle: "Sync your Williams Sonoma store registry"
            )
        }
    }
    
    func actionRow(icon: String, title: String, subtitle: String) -> some View {
        Button {
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(WSRegistryPalette.espresso)
                    .frame(width: 42, height: 42)
                    .background(WSRegistryPalette.ivory, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(WSRegistryPalette.espresso)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(WSRegistryPalette.warmGray)
                        .lineLimit(2)
                }
                
                Spacer(minLength: 10)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(WSRegistryPalette.warmGray.opacity(0.65))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
            .background(WSRegistryPalette.porcelain, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .stroke(WSRegistryPalette.hairline.opacity(0.55), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct RegistryReadinessItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let percent: Int
    let tint: Color
    
    static let samples: [RegistryReadinessItem] = [
        RegistryReadinessItem(title: "Hosting", systemImage: "wineglass", percent: 62, tint: WSRegistryPalette.gold),
        RegistryReadinessItem(title: "Daily Cooking", systemImage: "frying.pan", percent: 89, tint: WSRegistryPalette.sage),
        RegistryReadinessItem(title: "Shared Dining", systemImage: "fork.knife", percent: 40, tint: WSRegistryPalette.cocoa.opacity(0.74)),
        RegistryReadinessItem(title: "Morning Rituals", systemImage: "cup.and.saucer", percent: 58, tint: WSRegistryPalette.gold.opacity(0.78))
    ]
}
