// ContentView.swift
// Team12_WSI

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository

    var body: some View {
        TabView(selection: $tabBarVM.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(WSTab.home)

            RegistryView()
                .tabItem {
                    Label("Registry", systemImage: "heart.text.square")
                }
                .tag(WSTab.registry)

            CartView()
                .tabItem {
                    Label("Bag", systemImage: "bag")
                }
                .badge(cartRepository.items.reduce(0) { $0 + $1.quantity })
                .tag(WSTab.cart)
        }
        .tint(WSRegistryPalette.gold)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(WSRegistryPalette.ivory)
            appearance.shadowColor = UIColor(WSRegistryPalette.hairline)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        // MARK: - Global Registry Picker Sheet
        // Presented whenever any view sets registryRepository.productToShowInRegistryPicker
        .sheet(item: $registryRepository.productToShowInRegistryPicker) { product in
            RegistryPickerView(product: product)
                .environmentObject(registryRepository)
        }
    }
}

#Preview {
    ContentView()
}

