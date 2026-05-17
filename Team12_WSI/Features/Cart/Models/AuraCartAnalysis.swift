import Foundation

struct AuraCartAnalysis {
    let confidenceScore: Double
    let overallAesthetic: String
    let completenessStatus: CompletenessStatus
    var relationships: [CartItemRelationship]
    var pairings: [CuratedPairing]
    
    enum CompletenessStatus: String {
        case incomplete
        case building
        case complete
        case clashing
        
        var title: String {
            switch self {
            case .incomplete:
                return "Incomplete Set"
            case .building:
                return "Building Harmony"
            case .complete:
                return "Complete Room"
            case .clashing:
                return "Aesthetic Clash Detected"
            }
        }
    }
}
