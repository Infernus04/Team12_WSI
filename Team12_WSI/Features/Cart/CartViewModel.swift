import Foundation
import Combine

@MainActor
final class CartViewModel: ObservableObject {
    @Published private(set) var items: [CartItem] = []
    @Published private(set) var cartAnalysis: AuraCartAnalysis?
    @Published private(set) var isAnalyzing: Bool = false
    @Published private(set) var analysisErrorMessage: String?
    @Published var isCheckoutPresented: Bool = false
    
    private let intelligenceService = AuraCartIntelligenceService()
    private var cancellables = Set<AnyCancellable>()
    private var analysisTask: Task<Void, Never>?
    private var repository: CartRepository?
    private var saveForLaterRepository: SaveForLaterRepository?
    private var lastCartSignature: String = ""
    
    func bind(cartRepository: CartRepository, saveForLaterRepository: SaveForLaterRepository) {
        self.repository = cartRepository
        self.saveForLaterRepository = saveForLaterRepository
        cancellables.removeAll()
        
        cartRepository.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedItems in
                self?.handleRepositoryUpdate(updatedItems)
            }
            .store(in: &cancellables)
    }
    
    var isEmptyCart: Bool {
        items.isEmpty
    }
    
    var totalPrice: Double {
        repository?.totalPrice ?? 0
    }
    
    var totalPriceText: String {
        totalPrice.currencyText
    }
    
    var totalItemsText: String {
        let count = repository?.totalItems ?? 0
        return count == 1 ? "1 curated piece" : "\(count) curated pieces"
    }
    
    func removeItem(_ item: CartItem) {
        repository?.removeOne(productId: item.id)
    }
    
    func removeAll(of item: CartItem) {
        repository?.removeAll(productId: item.id)
    }
    
    func add(_ item: CartItem) {
        repository?.increaseQuantity(productId: item.id)
    }
    
    func addPairingToCart(product: ProductItem) {
        repository?.add(product: product, quantityDelta: 1)
    }
    
    func toggleGiftWrap(for item: CartItem) {
        repository?.toggleGiftWrap(productId: item.id)
    }
    
    /// Move a cart item to the wishlist (Save for Later)
    func moveToWishlist(item: CartItem) {
        guard let saveRepo = saveForLaterRepository else { return }
        
        let product = ProductItem(
            id: item.id,
            name: item.name,
            price: item.price,
            path: item.path,
            productType: item.productType,
            brand: item.brand
        )
        saveRepo.add(product: product)
        repository?.removeAll(productId: item.id)
    }
    
    func beginCheckout() {
        guard !items.isEmpty else { return }
        isCheckoutPresented = true
    }
    
    func dismissCheckout() {
        isCheckoutPresented = false
    }
    
    /// Called when checkout completes — clears cart
    func completeCheckout() {
        repository?.clear()
        cartAnalysis = nil
        analysisErrorMessage = nil
        isCheckoutPresented = false
    }
    
    private func handleRepositoryUpdate(_ updatedItems: [CartItem]) {
        items = updatedItems
        
        let signature = Self.signature(for: updatedItems)
        if signature != lastCartSignature {
            lastCartSignature = signature
        }
        
        guard !updatedItems.isEmpty else {
            analysisTask?.cancel()
            cartAnalysis = nil
            analysisErrorMessage = nil
            isAnalyzing = false
            return
        }
        
        scheduleAnalysis()
    }
    
    private func scheduleAnalysis() {
        analysisTask?.cancel()
        
        guard !items.isEmpty else {
            cartAnalysis = nil
            analysisErrorMessage = nil
            isAnalyzing = false
            return
        }
        
        let currentItems = items
        isAnalyzing = true
        
        analysisTask = Task { [weak self] in
            guard let self else { return }
            
            do {
                try await Task.sleep(for: .milliseconds(250))
                let analysis = try await self.intelligenceService.analyzeCart(
                    cartItems: currentItems
                )
                guard !Task.isCancelled else { return }
                
                self.cartAnalysis = analysis
                self.analysisErrorMessage = nil
                self.isAnalyzing = false
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                self.cartAnalysis = nil
                self.analysisErrorMessage = "Aura insights are temporarily unavailable."
                self.isAnalyzing = false
            }
        }
    }
    
    private static func signature(for items: [CartItem]) -> String {
        items
            .sorted { $0.id < $1.id }
            .map { "\($0.id):\($0.quantity)" }
            .joined(separator: "|")
    }
}
