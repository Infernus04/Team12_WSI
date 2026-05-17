import Foundation
import SwiftUI

// MARK: - Registry Activity Tracking

enum RegistryActivityType: String, Codable, CaseIterable, Hashable {
    case added
    case removed
    case purchased
    case bundleAdded
    case quantityChanged
    case movedCollection

    var displayLabel: String {
        switch self {
        case .added: return "Added"
        case .removed: return "Removed"
        case .purchased: return "Purchased"
        case .bundleAdded: return "Bundle Added"
        case .quantityChanged: return "Updated"
        case .movedCollection: return "Moved"
        }
    }

    var systemImage: String {
        switch self {
        case .added: return "plus.circle.fill"
        case .removed: return "minus.circle.fill"
        case .purchased: return "bag.fill"
        case .bundleAdded: return "square.grid.2x2.fill"
        case .quantityChanged: return "arrow.up.arrow.down.circle.fill"
        case .movedCollection: return "folder.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .added: return WSRegistryPalette.sage
        case .removed: return Color(hex: "#C8102E")
        case .purchased: return WSRegistryPalette.gold
        case .bundleAdded: return Color(hex: "#6A5ACD")
        case .quantityChanged: return WSRegistryPalette.cocoa
        case .movedCollection: return Color(hex: "#4A90D9")
        }
    }

    /// Filter-friendly category label.
    var filterCategory: String {
        switch self {
        case .added, .bundleAdded: return "Added"
        case .removed: return "Removed"
        case .purchased: return "Purchased"
        case .quantityChanged, .movedCollection: return "Updated"
        }
    }
}

struct RegistryActivity: Identifiable, Codable, Hashable {
    let id: UUID
    let type: RegistryActivityType
    let productName: String
    let collectionName: String?
    let detail: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        type: RegistryActivityType,
        productName: String,
        collectionName: String? = nil,
        detail: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.productName = productName
        self.collectionName = collectionName
        self.detail = detail
        self.timestamp = timestamp
    }

    var relativeTimeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

    var dateGroupKey: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(timestamp) { return "Today" }
        if calendar.isDateInYesterday(timestamp) { return "Yesterday" }
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        if timestamp > weekAgo { return "This Week" }
        return "Earlier"
    }
}

// MARK: - Mock Activity Data

enum MockRegistryActivities {
    static func generate() -> [RegistryActivity] {
        let now = Date()
        let calendar = Calendar.current

        return [
            RegistryActivity(
                type: .added,
                productName: "Le Creuset Signature Dutch Oven",
                collectionName: "Daily Cooking",
                detail: "Added to Daily Cooking collection",
                timestamp: calendar.date(byAdding: .minute, value: -12, to: now) ?? now
            ),
            RegistryActivity(
                type: .bundleAdded,
                productName: "Modern Autumn Hosting",
                collectionName: "Hosting",
                detail: "4 items added from AI bundle",
                timestamp: calendar.date(byAdding: .hour, value: -2, to: now) ?? now
            ),
            RegistryActivity(
                type: .purchased,
                productName: "Wusthof Classic 8-Piece Knife Set",
                collectionName: "Daily Cooking",
                detail: "Purchased by Emma Williams",
                timestamp: calendar.date(byAdding: .hour, value: -5, to: now) ?? now
            ),
            RegistryActivity(
                type: .added,
                productName: "Vitamix A3500 Ascent Blender",
                collectionName: "Daily Cooking",
                detail: "Added from AI recommendations",
                timestamp: calendar.date(byAdding: .day, value: -1, to: now) ?? now
            ),
            RegistryActivity(
                type: .removed,
                productName: "Basic Mixing Bowl Set",
                detail: "Removed from registry",
                timestamp: calendar.date(byAdding: .day, value: -1, to: now) ?? now
            ),
            RegistryActivity(
                type: .quantityChanged,
                productName: "Staub Serving Bowl Set",
                collectionName: "Hosting",
                detail: "Quantity updated to 2",
                timestamp: calendar.date(byAdding: .day, value: -2, to: now) ?? now
            ),
            RegistryActivity(
                type: .purchased,
                productName: "LSA International Wine Carafe",
                collectionName: "Hosting",
                detail: "Purchased by Olivia Johnson",
                timestamp: calendar.date(byAdding: .day, value: -3, to: now) ?? now
            ),
            RegistryActivity(
                type: .movedCollection,
                productName: "Crate & Barrel Marin Dinner Plate",
                collectionName: "Shared Dining",
                detail: "Moved to Shared Dining collection",
                timestamp: calendar.date(byAdding: .day, value: -4, to: now) ?? now
            ),
            RegistryActivity(
                type: .added,
                productName: "Zwiesel Glas All Purpose Glass",
                collectionName: "Shared Dining",
                detail: "Added to Shared Dining collection",
                timestamp: calendar.date(byAdding: .day, value: -5, to: now) ?? now
            ),
            RegistryActivity(
                type: .bundleAdded,
                productName: "Organic Minimalist Morning",
                collectionName: "Morning Rituals",
                detail: "4 items added from AI bundle",
                timestamp: calendar.date(byAdding: .day, value: -8, to: now) ?? now
            ),
            RegistryActivity(
                type: .purchased,
                productName: "Le Creuset Signature Dutch Oven",
                collectionName: "Daily Cooking",
                detail: "Purchased by William Anderson",
                timestamp: calendar.date(byAdding: .day, value: -10, to: now) ?? now
            ),
            RegistryActivity(
                type: .added,
                productName: "Marimekko Oiva Serving Platter",
                collectionName: "Hosting",
                detail: "Added from browse",
                timestamp: calendar.date(byAdding: .day, value: -12, to: now) ?? now
            )
        ]
    }
}
