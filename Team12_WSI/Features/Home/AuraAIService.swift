import Foundation
import UIKit
import GoogleGenerativeAI

final class AuraAIService {
    static let shared = AuraAIService()
    
    private var isApiKeyConfigured: Bool {
        let key = AppConstants.API.geminiAPIKey
        return !key.isEmpty && key != "YOUR_GEMINI_API_KEY_HERE"
    }
    
    // ✅ SIMPLE FIX: Only send top 20 products with minimal info
    private func buildMinimalCatalogSummary(from catalog: [ProductItem]) -> String {
        let limited = catalog.prefix(20)
        
        return limited.map { item in
            "- ID: \(item.id), Name: \(item.name), Price: $\(item.price ?? 0)"
        }.joined(separator: "\n")
    }
    
    // ✅ SIMPLE FIX: Short, effective system prompt
    private func buildCompactSystemInstruction(catalogSummary: String) -> String {
        """
        You are Aura, Williams-Sonoma's AI Shopping Assistant. Warm and helpful.
        
        INSTRUCTIONS:
        1. Answer questions about the products below
        2. ONLY recommend products that exist in the catalog
        3. Never make up prices or details
        
        Format your answer as:
        [Your answer here]
        ===
        [Product IDs comma-separated, e.g: 123,456,789]
        
        CATALOG:
        \(catalogSummary)
        """
    }
    
    // ✅ SIMPLE WORKING FIX: Minimal prompt sent to Gemini
    func sendMessage(
        _ query: String,
        image: UIImage?,
        catalog: [ProductItem],
        completion: @escaping (String, [ProductItem]) -> Void
    ) {
        guard isApiKeyConfigured else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.runSimulatedFallback(query: query, image: image, catalog: catalog, completion: completion)
            }
            return
        }
        
        // Build minimal prompt only
        let catalogSummary = buildMinimalCatalogSummary(from: catalog)
        let systemInstruction = buildCompactSystemInstruction(catalogSummary: catalogSummary)
        
        let prompt = """
        \(systemInstruction)
        
        [User Query]
        \(query)
        """
        
        let estimatedTokens = prompt.count / 4
        print("📊 Tokens: ~\(estimatedTokens)")
        
        let generativeModel = GenerativeModel(
            name: "gemini-2.0-flash",
            apiKey: AppConstants.API.geminiAPIKey
        )
        
        Task {
            do {
                print("🚀 Sending to Gemini...")
                let response: GenerateContentResponse
                
                if let image = image {
                    response = try await generativeModel.generateContent(image, prompt)
                } else {
                    response = try await generativeModel.generateContent(prompt)
                }
                
                guard let responseText = response.text else {
                    print("❌ No response")
                    DispatchQueue.main.async {
                        self.runSimulatedFallback(query: query, image: image, catalog: catalog, completion: completion)
                    }
                    return
                }
                
                print("✅ Got response!")
                
                // Parse response
                let parts = responseText.components(separatedBy: "===")
                let textReply = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? responseText
                
                var matchedProducts: [ProductItem] = []
                if parts.count > 1 {
                    let ids = parts[1]
                        .components(separatedBy: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                    
                    matchedProducts = catalog.filter { ids.contains($0.id) }
                }
                
                DispatchQueue.main.async {
                    completion(textReply, matchedProducts)
                }
            } catch {
                print("❌ Error: \(error)")
                DispatchQueue.main.async {
                    self.runSimulatedFallback(query: query, image: image, catalog: catalog, completion: completion)
                }
            }
        }
    }
    
    // Fallback when AI fails
    private func runSimulatedFallback(
        query: String,
        image: UIImage?,
        catalog: [ProductItem],
        completion: @escaping (String, [ProductItem]) -> Void
    ) {
        let lower = query.lowercased()
        
        let stopWords: Set<String> = [
            "a", "an", "the", "in", "on", "at", "to", "for", "of", "with", "by",
            "show", "give", "recommend", "suggest", "please", "find", "want", "need"
        ]
        
        let words = lower.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !stopWords.contains($0) && $0.count >= 2 }
        
        var matchedProducts: [ProductItem] = []
        
        if !words.isEmpty {
            let scoredProducts = catalog.map { item -> (item: ProductItem, score: Int) in
                var score = 0
                let searchText = "\(item.name) \(item.productType ?? "") \(item.material ?? "")".lowercased()
                
                for word in words {
                    if searchText.contains(word) {
                        score += 1
                    }
                }
                return (item, score)
            }
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            
            matchedProducts = scoredProducts.map { $0.item }
        }
        
        if matchedProducts.isEmpty {
            matchedProducts = Array(catalog.prefix(5))
        }
        
        let finalMatches = Array(matchedProducts.prefix(10))
        let explanation = "Found great options matching your search"
        
        completion(explanation, finalMatches)
    }
}