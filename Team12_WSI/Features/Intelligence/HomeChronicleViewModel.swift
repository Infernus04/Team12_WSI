import Foundation
import SwiftUI
import Combine

// MARK: - Home Chronicle ViewModel

@MainActor
final class HomeChronicleViewModel: ObservableObject {

    // MARK: - Published State

    @Published var timelineResponse: ChronicleTimelineResponse?
    @Published var replacementAlerts: [ReplacementAlert] = []
    @Published var roomGaps: [RoomGapSignal] = []
    @Published var completeBundle: CompleteYourHomeBundle?
    @Published var isLoading = true

    private let intelligenceService = AURAIntelligenceService()
    private let purchases = MockChronicleData.samplePurchases
    private let policies = MockChronicleData.lifecyclePolicies

    // MARK: - Load All

    func loadChronicle() {
        isLoading = true

        // Timeline
        timelineResponse = intelligenceService.generateTimeline(purchases: purchases)

        // Replacement Alerts
        replacementAlerts = intelligenceService.generateReplacementAlerts(
            purchases: purchases,
            policies: policies
        )

        // Room Gaps
        let targetRooms: [AURARoomType] = [.kitchen, .dining, .living, .bedroom, .bathroom, .outdoor]
        roomGaps = intelligenceService.detectRoomGaps(
            purchases: purchases,
            targetRooms: targetRooms
        )

        // Complete Your Home Bundle (mock)
        completeBundle = CompleteYourHomeBundle(
            title: "Complete Your Kitchen & Living Space",
            itemIDs: ["mock-003", "mock-005", "mock-010"],
            estimatedTotal: 919.85,
            appliedStoreCredit: 75.00,
            finalPayable: 844.85,
            rationale: "Based on your purchase history, these pieces complete your kitchen essentials and add warmth to your living area."
        )

        isLoading = false
    }

    // MARK: - Computed

    var totalSpent: Double {
        purchases.reduce(0) { $0 + ($1.unitPrice * Double($1.quantity)) }
    }

    var brandBreakdown: [(brand: String, count: Int)] {
        let grouped = Dictionary(grouping: purchases) { $0.brand }
        return grouped.map { (brandDisplayName($0.key), $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    func brandDisplayName(_ brand: WSIBrand) -> String {
        switch brand {
        case .williamsSonoma: return "Williams Sonoma"
        case .potteryBarn: return "Pottery Barn"
        case .westElm: return "West Elm"
        case .rejuvenation: return "Rejuvenation"
        case .markAndGraham: return "Mark & Graham"
        case .greenRow: return "GreenRow"
        case .unknown: return "Other"
        }
    }

    func urgencyColor(_ label: String) -> Color {
        switch label {
        case "Ready to Replace": return Color.red.opacity(0.85)
        case "Watch": return WSRegistryPalette.gold
        default: return WSRegistryPalette.warmGray
        }
    }
}
