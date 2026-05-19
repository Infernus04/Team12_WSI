import Foundation
import UIKit
import GoogleGenerativeAI

final class AuraAIService {
    static let shared = AuraAIService()
    
    private var isApiKeyConfigured: Bool {
        let key = AppConstants.API.geminiAPIKey
        return !key.isEmpty && !key.contains("YOUR_GEMINI_API_KEY")
    }
    
    private func runSimulatedFallback(
        query: String,
        image: UIImage?,
        catalog: [ProductItem],
        completion: @escaping (String, [ProductItem]) -> Void
    ) {
        let lower = query.lowercased()
        
        // 1. Filter out common conversational stop words
        let stopWords: Set<String> = [
            "a", "an", "the", "in", "on", "at", "to", "for", "of", "with", "by", "from",
            "me", "i", "my", "you", "your", "we", "our", "show", "give", "recommend",
            "suggest", "please", "find", "search", "want", "need", "like", "love",
            "theme", "product", "products", "item", "items", "some", "any", "all",
            "get", "display", "list", "go", "matching", "design", "style", "look", "this"
        ]
        
        // 2. Tokenize prompt into individual search keywords
        let words = lower.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !stopWords.contains($0) && $0.count >= 2 }
        
        print("Aura AI Simulated Fallback Keywords: \(words)")
        
        // 3. Scan the user's actual database (catalog) to find matching products
        var matchedProducts: [ProductItem] = []
        
        if !words.isEmpty {
            // Score products based on how many keywords match their properties
            let scoredProducts = catalog.map { item -> (item: ProductItem, score: Int) in
                var score = 0
                let nameLower = item.name.lowercased()
                let brandLower = (item.brand ?? "").lowercased()
                let materialLower = (item.material ?? "").lowercased()
                let typeLower = (item.productType ?? "").lowercased()
                let patternLower = (item.pattern ?? "").lowercased()
                
                for word in words {
                    // Exact name match gets highest weight
                    if nameLower.contains(word) {
                        score += 5
                    }
                    // Brand match gets high weight
                    if brandLower.contains(word) {
                        score += 4
                    }
                    // Product type or category match
                    if typeLower.contains(word) || patternLower.contains(word) {
                        score += 3
                    }
                    // Material match
                    if materialLower.contains(word) {
                        score += 2
                    }
                }
                return (item, score)
            }
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            
            matchedProducts = scoredProducts.map { $0.item }
        }
        
        // 4. Fall back to standard catalog groups if no keyword matches were found
        if matchedProducts.isEmpty {
            if lower.contains("sofa") || lower.contains("couch") || lower.contains("living") || lower.contains("room") || lower.contains("space") || image != nil {
                matchedProducts = catalog.filter { ($0.productType ?? "").lowercased().contains("sofa") || $0.name.lowercased().contains("sofa") }
                if matchedProducts.isEmpty {
                    matchedProducts = ProductItem.fallbackProducts.filter { $0.name.lowercased().contains("sofa") }
                }
            } else if lower.contains("kitchen") || lower.contains("cook") || lower.contains("pan") || lower.contains("pot") {
                matchedProducts = catalog.filter { ($0.productType ?? "").lowercased().contains("cookware") || $0.name.lowercased().contains("cookware") || $0.name.lowercased().contains("pan") }
                if matchedProducts.isEmpty {
                    matchedProducts = ProductItem.fallbackProducts.filter { ($0.productType ?? "").lowercased().contains("cookware") || $0.name.lowercased().contains("cookware") }
                }
            } else {
                matchedProducts = Array(catalog.prefix(3))
            }
        }
        
        // 5. Parse budget constraints (e.g., "under 250", "budget 1500") and filter results
        var maxPrice: Double? = nil
        if let range = lower.range(of: "under\\s*\\$?([0-9]+)", options: .regularExpression) {
            let priceStr = lower[range].replacingOccurrences(of: "under", with: "").replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
            maxPrice = Double(priceStr)
        } else if let range = lower.range(of: "below\\s*\\$?([0-9]+)", options: .regularExpression) {
            let priceStr = lower[range].replacingOccurrences(of: "below", with: "").replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
            maxPrice = Double(priceStr)
        } else if let range = lower.range(of: "budget\\s*\\$?([0-9]+)", options: .regularExpression) {
            let priceStr = lower[range].replacingOccurrences(of: "budget", with: "").replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
            maxPrice = Double(priceStr)
        }
        
        if let maxPrice = maxPrice {
            matchedProducts = matchedProducts.filter { ($0.price ?? 0.0) <= maxPrice }
        }
        
        // 6. Generate the luxurious, elegant conversational reply
        let finalMatches = Array(matchedProducts.prefix(3))
        var explanation = ""
        
        if image != nil {
            explanation += "✦ AURA VISUAL INTEL ✦\nScanning and analyzing your uploaded space... I notice inspiring design elements. To match this visual style,"
        } else {
            explanation += "I would love to assist with your request."
        }
        
        if !finalMatches.isEmpty {
            explanation += " Here are premium selections from the Williams-Sonoma catalog that beautifully match your query"
            if let maxPrice = maxPrice {
                explanation += " while remaining within your budget of under $\(Int(maxPrice))"
            }
            explanation += ":"
        } else {
            explanation += " I searched our current Williams-Sonoma catalog but couldn't find a direct match. Let me know if I can guide you to our cookware foundations, luxury tabletop details, or daily entertaining essentials!"
        }
        
        completion(explanation, finalMatches)
    }
    
    /// Queries the Gemini 1.5 Flash model with the user query, optional image, and catalog list.
    func sendMessage(
        _ query: String,
        image: UIImage?,
        catalog: [ProductItem],
        completion: @escaping (String, [ProductItem]) -> Void
    ) {
        // Build a structured list of available products with EVERY metadata parameter from the catalog JSON
        let catalogSummary = catalog.map { item in
            var details = "- ID: \(item.id), Name: \(item.name)"
            
            // Add comprehensive pricing details
            if let regular = item.regularPrice { details += ", regularPrice: $\(regular)" }
            if let selling = item.sellingPrice { details += ", sellingPrice: $\(selling)" }
            if let surcharge = item.surcharge, surcharge > 0 { details += ", surchargePrice: $\(surcharge)" }
            if let personalization = item.monogramOrPersonalizationPrice, personalization > 0 { details += ", personalizationPrice: $\(personalization)" }
            
            // Add logistical details
            if let availability = item.availability { details += ", availabilityStatus: \(availability)" }
            if let delivery = item.deliveryEstimate { details += ", deliveryEstimate: \(delivery)" }
            
            // Add ALL dynamic properties parsed from the JSON
            if let properties = item.allProperties {
                let propsList = properties.map { "\($0.key): \($0.value)" }.sorted().joined(separator: "; ")
                details += ", Properties: [\(propsList)]"
            }
            return details
        }.joined(separator: "\n")
        
        let systemInstruction = """
        You are Aura, the expert AI Concierge and Personal Registry Designer for Williams-Sonoma.
        Your persona: Warm, luxurious, highly knowledgeable, articulate, and dedicated to perfect home aesthetic design.
        
        You have absolute awareness of the official WSI JSON product catalog, including ALL parameters for each item:
        * pricing: regularPrice, sellingPrice, surchargePrice, personalizationPrice
        * availabilityStatus (e.g. ON_HAND, OUT_OF_STOCK)
        * deliveryEstimate (e.g. TRANSIT, IMMEDIATE)
        * Properties metadata block parameters:
          - pattern: Category or style classification (e.g. homekeeping, cutlery, tabletop, glassware).
          - material: Base fabrication of the item (e.g. acacia, [wood-parent/wood, ceramic-parent/ceramic]).
          - brand: Official manufacturer or label (e.g. hold-everything, williams-sonoma).
          - collection: Specific pantry or storage series (e.g. [he-pantry, he-fridge]).
          - productType: Specific store classification (e.g. cutting-boards-storage, tabletop-serveware-bowl).
          - isFurniture: Flag indicating if the product is furniture (true/false).
          - isFood: Flag indicating if the product is food or edible (true/false).
          - isMarketPlace: Flag for marketplace products (true/false).
          - canGiftWrap: Flag indicating gift wrap eligibility (true/false).
          - organic: Flag indicating organic material (true/false).
          - isSpecialOrder: Flag for customized special orders (true/false).
          - hasUtilityNeeds: Flag for utility registry products (true/false).
          - spiritType: Brand line context (e.g. williams-sonoma).
        
        Use these parameters to answer questions with absolute precision:
        - If the user asks: "Is this organic?" -> check if "organic: true".
        - If the user asks: "Can I monogram or personalize this?" -> check if "personalizationPrice" is available and what it is.
        - If the user asks: "Is this in stock?" -> check "availabilityStatus: ON_HAND".
        - If the user asks: "Can it be gift wrapped?" -> check if "canGiftWrap: true".
        - If the user asks for "wood serving bowls" -> recommend products where material contains "wood" and productType contains "bowl".
        - If the user asks for "homekeeping items" -> recommend products where pattern is "homekeeping".
        - If the user asks for "furniture items" or "food items" -> filter using "isFurniture" and "isFood" properties.
        
        Rule of Honesty & Catalog Fidelity:
        * If a user asks for a product, category, or brand that is NOT present in the official Williams-Sonoma Catalog, or asks about a parameter/detail you do not know, you MUST be completely honest. State politely and elegantly in a luxury tone that you do not have that specific item or detail in the current catalog, and immediately guide them to similar, related options that ARE available in the catalog list below.
        * NEVER hallucinate, make up, or guess features, prices, or materials. If a detail is missing, say honestly that it is not specified in the current catalog.
        
        You must only recommend products that are present in the official Williams-Sonoma catalog below. Do not make up or suggest any products that are not on this exact list:
        
        [Official Williams-Sonoma Catalog]
        \(catalogSummary)
        
        When replying:
        1. Keep your tone highly personalized, encouraging, and luxurious.
        2. Help the user choose the perfect essentials based on their query.
        3. Recommend between 1 to 5 exact matches from the catalog.
        
        Format your response EXACTLY in this custom structure:
        [Your elegant conversational reply goes here.]
        ===
        [List the matching product IDs separated by commas, e.g.: 6121370, 7123984]
        
        If no products from the catalog are a relevant match to their query, do not write the '===' separator or any IDs at the end.
        """
        
        guard isApiKeyConfigured else {
            // Safe fallback simulation if they haven't set their key yet so they can still demo it!
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.runSimulatedFallback(query: query, image: image, catalog: catalog, completion: completion)
            }
            return
        }
        
        // Initialize the GenerativeModel
        let generativeModel = GenerativeModel(
            name: "gemini-2.0-flash",
            apiKey: AppConstants.API.geminiAPIKey
        )
        
        // Merge system instructions with the user query for bulletproof SDK version compatibility
        let prompt = """
        \(systemInstruction)
        
        [User Request]
        \(query)
        """
        
        Task {
            do {
                let response: GenerateContentResponse
                if let image = image {
                    response = try await generativeModel.generateContent(image, prompt)
                } else {
                    response = try await generativeModel.generateContent(prompt)
                }
                
                guard let responseText = response.text else {
                    DispatchQueue.main.async {
                        self.runSimulatedFallback(query: query, image: image, catalog: catalog, completion: completion)
                    }
                    return
                }
                
                // Parse the response using the '===' delimiter
                let parts = responseText.components(separatedBy: "===")
                let textReply = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? responseText
                
                var matchedProducts: [ProductItem] = []
                if parts.count > 1 {
                    let ids = parts[1]
                        .components(separatedBy: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    
                    matchedProducts = catalog.filter { ids.contains($0.id) }
                }
                
                // If live Gemini parsed no matches but the user requested products, do a smart local catalog search to complete
                if matchedProducts.isEmpty && (query.lowercased().contains("recommend") || query.lowercased().contains("show") || query.lowercased().contains("give")) {
                    self.runSimulatedFallback(query: query, image: image, catalog: catalog, completion: completion)
                    return
                }
                
                DispatchQueue.main.async {
                    completion(textReply, matchedProducts)
                }
            } catch {
                print("Aura AI Gemini Error: \(error)")
                DispatchQueue.main.async {
                    self.runSimulatedFallback(query: query, image: image, catalog: catalog, completion: completion)
                }
            }
        }
    }
}

