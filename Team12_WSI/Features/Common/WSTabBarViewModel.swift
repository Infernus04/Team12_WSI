import SwiftUI
import Combine


enum WSTab: Int {
    case home = 0
    case registry = 1
    case cart = 2
}

class WSTabBarViewModel: ObservableObject {
    @Published var selectedTab: WSTab = .home
    @Published var registryPath = NavigationPath()
    
    func selectTab(_ tab: WSTab) {
        selectedTab = tab
    }
    
    func resetRegistryFlow() {
        registryPath = NavigationPath()
    }
}

