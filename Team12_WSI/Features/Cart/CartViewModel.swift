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
    private var registryRepository: RegistryRepository?
    private var lastCartSignature: String = ""
    
    func bind(cartRepository: CartRepository, registryRepository: RegistryRepository) {
        self.repository = cartRepository
        self.registryRepository = registryRepository
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
    
    func moveToRegistry(item: CartItem) {
        guard let registryRepo = registryRepository else { return }
        
        // If there's no active registry, we could either prompt to create one or silently fail.
        // For hackathon purposes, assuming we have one or create a default one if needed.
        if !registryRepo.isActiveRegistry {
            registryRepo.createRegistry(firstName: "Guest", lastName: "User", event: .wedding, date: Date())
        }
        
        let product = ProductItem(
            id: item.id,
            name: item.name,
            shortName: nil,
            price: item.price,
            path: item.path,
            productType: item.productType,
            brand: item.brand,
            canGiftWrap: item.canGiftWrap,
            availability: item.availability,
            deliveryEstimate: item.deliveryEstimate
        )
        registryRepo.addProduct(product)
        repository?.removeOne(productId: item.id)
    }
    
    func beginCheckout() {
        guard !items.isEmpty else { return }
        isCheckoutPresented = true
    }
    
    func dismissCheckout() {
        isCheckoutPresented = false
    }
    
    func completeCheckout(_ confirmation: CheckoutConfirmation) {
        repository?.clear()
        cartAnalysis = nil
        analysisErrorMessage = nil
        isCheckoutPresented = false
        print("Checkout completed: \(confirmation.orderId)")
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
