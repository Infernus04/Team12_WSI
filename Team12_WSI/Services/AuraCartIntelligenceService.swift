import Foundation

final class AuraCartIntelligenceService {
    func analyzeCart(cartItems: [CartItem]) async throws -> AuraCartAnalysis {
        let requestBody = CartAnalysisRequest(
            items: cartItems.map { CartLineItemRequest(productId: $0.id, quantity: $0.quantity) }
        )
        
        let response: AuraCartAnalysisDTO = try await APIClient.shared.request(.cartAnalyze(), body: requestBody)
        return response.toDomain()
    }
}

private struct CartAnalysisRequest: Codable {
    let items: [CartLineItemRequest]
}

private struct AuraCartAnalysisDTO: Decodable {
    let confidenceScore: Double
    let overallAesthetic: String
    let completenessStatus: String
    let relationships: [CartItemRelationshipDTO]
    let pairings: [CuratedPairingDTO]
    
    func toDomain() -> AuraCartAnalysis {
        AuraCartAnalysis(
            confidenceScore: confidenceScore,
            overallAesthetic: overallAesthetic,
            completenessStatus: AuraCartAnalysis.CompletenessStatus(rawValue: completenessStatus) ?? .building,
            relationships: relationships.map { $0.toDomain() },
            pairings: pairings.map { $0.toDomain() }
        )
    }
}

private struct CartItemRelationshipDTO: Decodable {
    let id: String
    let item1Id: String
    let item2Id: String
    let type: String
    let score: Int
    let reasoningText: String
    
    func toDomain() -> CartItemRelationship {
        CartItemRelationship(
            id: id,
            item1Id: item1Id,
            item2Id: item2Id,
            type: CartItemRelationship.RelationshipType(rawValue: type) ?? .neutral,
            score: score,
            reasoningText: reasoningText
        )
    }
}

private struct CuratedPairingDTO: Decodable {
    let id: String
    let sourceItemName: String
    let recommendedItems: [ProductItemDTO]
    
    func toDomain() -> CuratedPairing {
        CuratedPairing(
            id: id,
            sourceItemName: sourceItemName,
            recommendedItems: recommendedItems.map { ProductItem(from: $0) }
        )
    }
}
