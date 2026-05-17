import UIKit
import SwiftUI

class RegistryHostingController: UIHostingController<RegistryLandingView> {
    init(eventID: String? = nil) {
        super.init(rootView: RegistryLandingView())
        self.modalPresentationStyle = .fullScreen
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: RegistryLandingView())
    }
}
