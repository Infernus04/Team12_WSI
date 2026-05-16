import SwiftUI
import Combine
import UIKit

class CustomImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    private var url: URL?
    
    func load(url: URL?) {
        guard let url = url else { return }
        self.url = url
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let loadedImage = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.image = loadedImage
            }
        }.resume()
    }
}
