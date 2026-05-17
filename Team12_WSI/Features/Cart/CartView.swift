import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var registryRepository: RegistryRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.wsWarmIvory
                    .ignoresSafeArea()
                
                if viewModel.isEmptyCart {
                    EmptyCartView {
                        tabBarVM.selectTab(.home)
                    }
                } else {
                    VStack(spacing: 0) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 20) {
                                freeShippingProgressView
                                
                                if let analysis = viewModel.cartAnalysis {
                                    AestheticConfidenceMeter(analysis: analysis)
                                } else if viewModel.isAnalyzing {
                                    progressCard
                                }
                                
                                if let analysisErrorMessage = viewModel.analysisErrorMessage {
                                    errorCard(message: analysisErrorMessage)
                                }
                                
                                VStack(spacing: 1) {
                                    ForEach(viewModel.items) { item in
                                        CartItemRow(
                                            item: item,
                                            onAdd: { viewModel.add(item) },
                                            onRemove: { viewModel.removeItem(item) },
                                            onRemoveAll: { viewModel.removeAll(of: item) },
                                            onToggleGiftWrap: { viewModel.toggleGiftWrap(for: item) },
                                            onMoveToRegistry: { viewModel.moveToRegistry(item: item) }
                                        )
                                    }
                                }
                                .background(Color.wsSurface)
                                .cornerRadius(2)
                                .wsLuxuryShadow()
                                
                                if let analysis = viewModel.cartAnalysis, !analysis.pairings.isEmpty {
                                    CuratedPairingsCard(
                                        pairings: analysis.pairings,
                                        onAdd: { product in
                                            withAnimation(.easeInOut(duration: 0.25)) {
                                                viewModel.addPairingToCart(product: product)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 18)
                            .padding(.bottom, 24)
                        }
                        
                        CartCheckoutBar(
                            totalText: viewModel.totalPriceText,
                            itemCountText: viewModel.totalItemsText,
                            onCheckout: viewModel.beginCheckout
                        )
                    }
                }
            }
            .navigationTitle(AppStrings.Cart.title)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.isCheckoutPresented) {
                CheckoutFlowView(
                    cartItems: viewModel.items,
                    onClose: viewModel.dismissCheckout,
                    onOrderPlaced: viewModel.completeCheckout
                )
            }
        }
        .onAppear {
            viewModel.bind(cartRepository: cartRepository, registryRepository: registryRepository)
        }
    }
    
    private var progressCard: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(Color.wsMutedBrass)
            Text("Aura is studying how your pieces work together.")
                .font(.wsBody(size: 13))
                .foregroundColor(.wsCharcoal)
            Spacer()
        }
        .padding(18)
        .background(Color.wsSurface)
        .cornerRadius(2)
        .wsLuxuryShadow()
    }
    
    private func errorCard(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .foregroundColor(.wsCrimson)
            Text(message)
                .font(.wsBody(size: 13))
                .foregroundColor(.wsSecondary)
            Spacer()
        }
        .padding(18)
        .background(Color.wsSurface)
        .cornerRadius(2)
        .wsLuxuryShadow()
    }
    
    private var freeShippingProgressView: some View {
        let threshold = 150.0
        let current = viewModel.totalPrice
        let remainder = max(0, threshold - current)
        let percentage = min(1.0, current / threshold)
        
        return VStack(spacing: 8) {
            HStack {
                Text(remainder > 0 ? "You're \(remainder.currencyText) away from Free Shipping!" : "You've unlocked Free Shipping!")
                    .font(.wsBody(size: 13, weight: .semibold))
                    .foregroundColor(remainder > 0 ? .wsCharcoal : .green)
                Spacer()
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.wsDivider)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(remainder > 0 ? Color.wsCharcoal : Color.green)
                        .frame(width: geo.size.width * CGFloat(percentage), height: 4)
                        .cornerRadius(2)
                        .animation(.spring(), value: percentage)
                }
            }
            .frame(height: 4)
        }
        .padding(16)
        .background(Color.wsSurface)
        .cornerRadius(2)
        .wsLuxuryShadow()
    }
}
