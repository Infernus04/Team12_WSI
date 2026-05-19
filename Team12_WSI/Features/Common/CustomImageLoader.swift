import SwiftUI
import Combine
import UIKit

class CustomImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    private var url: URL?
    
    func load(url: URL?) {
        guard let url = url else { return }
        self.url = url
        
        #if targetEnvironment(simulator)
        var relativePath = url.path
        if let range = relativePath.range(of: "/images/") {
            relativePath = String(relativePath[range.upperBound...])
        } else if relativePath.hasPrefix("/") {
            relativePath = String(relativePath.dropFirst())
        }
        
        let hostFilePath = "/Users/gayatri/Desktop/Team12_WSI/Backend/Images/" + relativePath
        if FileManager.default.fileExists(atPath: hostFilePath) {
            if let localImage = UIImage(contentsOfFile: hostFilePath) {
                self.image = localImage
                return
            }
        }
        #endif
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let loadedImage = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.image = loadedImage
            }
        }.resume()
    }
}
