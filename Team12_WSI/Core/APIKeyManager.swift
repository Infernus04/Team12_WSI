import Foundation

/// Manages fetching the Gemini API Key from a gitignored local Keys.plist file.
/// This prevents credentials from being exposed in source control.
enum APIKeyManager {
    
    /// Resolves the Google Gemini API Key dynamically.
    static var geminiAPIKey: String {
        // 1. Try to read from the local Mac filesystem directly (highly convenient for simulator development)
        #if targetEnvironment(simulator)
        let sourceFile = #filePath
        let sourceURL = URL(fileURLWithPath: sourceFile)
            .deletingLastPathComponent() // Core/
            .appendingPathComponent("Keys.plist")
        
        if let dict = NSDictionary(contentsOf: sourceURL),
           let key = dict["GEMINI_API_KEY"] as? String,
           !key.isEmpty,
           key != "YOUR_GEMINI_API_KEY_HERE" {
            return key
        }
        #endif
        
        // 2. Fall back to bundle resources (for real device builds or CI/CD)
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["GEMINI_API_KEY"] as? String,
           !key.isEmpty,
           key != "YOUR_GEMINI_API_KEY_HERE" {
            return key
        }
        
        // 3. Fallback placeholder (will trigger mock simulation modes)
        print("⚠️ Warning: Gemini API Key not found in local Keys.plist or main bundle. Falling back to Mock/Simulation mode.")
        return ""
    }
}
