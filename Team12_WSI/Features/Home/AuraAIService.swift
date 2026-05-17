import Foundation
import GoogleGenerativeAI

final class AuraAIService {
    static let shared = AuraAIService()
    
    private var isApiKeyConfigured: Bool {
        let key = AppConstants.API.geminiAPIKey
        return key != "AIzaSyDJlNTVaA2FyRUY8X2QDgdEuS5n8yoifxo" && !key.isEmpty
    }
    
    /// Queries the Gemini 1.5 Flash model with the user query and catalog list.
    func sendMessage(
        _ query: String,
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
                let lower = query.lowercased()
                if lower.contains("cookware") || lower.contains("pot") || lower.contains("pan") {
                    let matches = catalog.filter { ($0.productType ?? "").lowercased().contains("cookware") || $0.name.lowercased().contains("cookware") }
                    completion("I would love to guide you through our exquisite cookware selections. For an inspiring kitchen foundation, a high-performance Le Creuset or professional copper set makes a wonderful anchor for your registry list.", Array(matches.prefix(3)))
                } else if lower.contains("plate") || lower.contains("ceramic") || lower.contains("dining") || lower.contains("tabletop") {
                    let matches = catalog.filter { ($0.productType ?? "").lowercased().contains("cutting") || $0.name.lowercased().contains("board") || $0.name.lowercased().contains("bowl") }
                    completion("To set an inviting, social table for your guests, I highly recommend incorporating organic textures and multi-layer serving platters that elevate shared meals.", Array(matches.prefix(3)))
                } else if lower.contains("homekeeping") || lower.contains("cleaning") || lower.contains("oil") || lower.contains("soap") {
                    let matches = catalog.filter { ($0.pattern ?? "").lowercased().contains("homekeeping") || $0.name.lowercased().contains("oil") }
                    completion("To keep your registry highly functional and keep your gourmet cookware and boards in perfect shape, Williams-Sonoma premium homekeeping cleaners and board oils are essential additions.", Array(matches.prefix(3)))
                } else {
                    completion("That sounds like a beautiful addition to your home story. Let me know if you would like me to curate cookware foundations, luxury tabletop details, or daily entertaining essentials for your registry!", [])
                }
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
                let response = try await generativeModel.generateContent(prompt)
                guard let responseText = response.text else {
                    DispatchQueue.main.async {
                        completion("I apologize, but I couldn't formulate a response right now. Please try again.", [])
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
                
                DispatchQueue.main.async {
                    completion(textReply, matchedProducts)
                }
            } catch {
                print("Aura AI Gemini Error: \(error)")
                DispatchQueue.main.async {
                    completion("I encountered a connection issue with my neural server, but I am still available to guide you. Please let me know how I can assist with your home design selections!", [])
                }
            }
        }
    }
}

