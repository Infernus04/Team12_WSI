import Foundation

struct CuratedPairing: Identifiable {
    let id: String // Cart item ID
    let sourceItemName: String
    let recommendedItems: [ProductItem]
}
