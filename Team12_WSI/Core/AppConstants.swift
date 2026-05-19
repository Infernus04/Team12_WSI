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
        static var baseURL: String {
            return AppConstants.currentEnvironment.baseURL
        }
        
        static var imageBasePath: String {
            return "\(baseURL)/images"
        }
        
        /// Fetches the Gemini API Key from the local gitignored Keys.plist file.
        static var geminiAPIKey: String {
            APIKeyManager.geminiAPIKey
        }
    }
}
