//
//  Team12_WSIApp.swift
//  Team12_WSI
//
//  Created by SDC-USER on 16/05/26.
//

import SwiftUI

@main
struct Team12_WSIApp: App {
    @StateObject private var cartRepository = CartRepository()
    @StateObject private var registryRepository = RegistryRepository()
    @StateObject private var tabBarViewModel = WSTabBarViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cartRepository)
                .environmentObject(registryRepository)
                .environmentObject(tabBarViewModel)
        }
    }
}

