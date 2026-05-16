//
//  ContentView.swift
//  Team12_WSI
//
//  Created by SDC-USER on 16/05/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    var body: some View {
        TabView(selection: $tabBarVM.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Shop", systemImage: "house")
                }
                .tag(WSTab.home)
            
            RegistryView()
                .tabItem {
                    Label("Registry", systemImage: "heart")
                }
                .tag(WSTab.registry)
            
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .tag(WSTab.cart)
        }
    }
}


#Preview {
    ContentView()
}
