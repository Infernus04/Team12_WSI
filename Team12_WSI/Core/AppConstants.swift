import Foundation

struct AppConstants {
    struct API {
        static let baseURL = "http://127.0.0.1:3000"
        static let imageBasePath = "http://127.0.0.1:3000/images"
        /// Fetches the Gemini API Key from the local gitignored Keys.plist file.
        static var geminiAPIKey: String {
            APIKeyManager.geminiAPIKey
        }
    }
}
