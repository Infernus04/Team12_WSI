import Foundation

struct CartItemRelationship: Identifiable {
    let id: String
    let item1Id: String
    let item2Id: String
    let type: RelationshipType
    let score: Int
    let reasoningText: String
    
    enum RelationshipType: String {
        case match
        case clash
        case neutral
    }
}
