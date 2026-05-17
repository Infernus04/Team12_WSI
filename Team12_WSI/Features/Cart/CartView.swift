import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @EnvironmentObject var cartRepository: CartRepository
    @EnvironmentObject var tabBarVM: WSTabBarViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuraDesign.Colors.ivory
                    .ignoresSafeArea()
                
                if viewModel.isEmptyCart {
                    EmptyCartView {
                        tabBarVM.selectTab(.home)
                    }
                } else {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 20) {
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
                                            onRemoveAll: { viewModel.removeAll(of: item) }
                                        )
                                    }
                                }
                                .background(AuraDesign.Colors.cream)
                                .cornerRadius(12)
                                .clipped()
                                
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
                            .padding(.horizontal, 16)
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
            viewModel.bind(repository: cartRepository)
        }
    }
    
    private var progressCard: some View {
        HStack(spacing: 12) {
            ProgressView()
                .tint(AuraDesign.Colors.charcoal)
            Text("Aura is studying how your pieces work together.")
                .font(AuraDesign.Fonts.sansSerif(size: 13, weight: .medium))
                .foregroundColor(AuraDesign.Colors.charcoal)
            Spacer()
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func errorCard(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .foregroundColor(AuraDesign.Colors.errorRed)
            Text(message)
                .font(AuraDesign.Fonts.sansSerif(size: 13))
                .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.75))
            Spacer()
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(12)
    }
}
