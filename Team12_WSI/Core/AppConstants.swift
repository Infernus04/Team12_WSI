import Foundation

enum AppEnvironment {
    case development
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "http://10.21.131.115:3000"
        case .staging:
            return "https://staging-api.example.com"
        case .production:
            return "https://api.example.com"
        }
    }
}

struct AppConstants {
    // Current active environment
    static let currentEnvironment: AppEnvironment = .development
    
    struct API {
<<<<<<< Updated upstream
        static let baseURL = "http://127.0.0.1:3000"
        static let imageBasePath = "http://127.0.0.1:3000/images"
        /// Fetches the Gemini API Key from the local gitignored Keys.plist file.
        static var geminiAPIKey: String {
            APIKeyManager.geminiAPIKey
        }
=======
        static var baseURL: String {
            return AppConstants.currentEnvironment.baseURL
        }
        
        static var imageBasePath: String {
            return "\(baseURL)/images"
        }
        
        // Paste your official Google Gemini API Key here to run live!
        static let geminiAPIKey = "AIzaSyDJlNTVaA2FyRUY8X2QDgdEuS5n8yoifxo"
>>>>>>> Stashed changes
    }
}
