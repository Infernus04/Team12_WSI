import SwiftUI

struct CuratedPairingsCard: View {
    let pairings: [CuratedPairing]
    let onAdd: (ProductItem) -> Void
    
    @State private var currentPage = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Curated Pairings")
                        .font(.wsSerif(size: 18, weight: .bold))
                        .foregroundColor(.wsCharcoal)
                    Text("Based on shopper habits & aesthetic logic")
                        .font(.wsBody(size: 11))
                        .foregroundColor(.wsSecondary)
                }
                
                Spacer()
                
                // Instagram-like page indicator dots
                if pairings.count > 1 {
                    HStack(spacing: 5) {
                        ForEach(0..<pairings.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.wsCharcoal : Color.wsCharcoal.opacity(0.2))
                                .frame(width: 6, height: 6)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Swipeable Pages
            TabView(selection: $currentPage) {
                ForEach(Array(pairings.enumerated()), id: \.element.id) { index, pairing in
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Perfect companions for your \(pairing.sourceItemName)")
                            .font(.wsBody(size: 12, weight: .medium))
                            .foregroundColor(.wsCharcoal.opacity(0.6))
                            .padding(.horizontal, 16)
                        
                        // Recommendations list for this specific cart item
                        HStack(spacing: 12) {
                            ForEach(pairing.recommendedItems) { product in
                                recommendedProductItem(product)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 200)
        }
        .background(Color.wsSurface)
        .cornerRadius(2)
        .wsLuxuryShadow()
    }
    
    @ViewBuilder
    private func recommendedProductItem(_ product: ProductItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Product Image Container
            ZStack(alignment: .topTrailing) {
                if let url = product.imageURL {
                    CustomAsyncImage(url: url)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 90)
                        .clipped()
                        .cornerRadius(2)
                        .background(Color.wsWarmIvory)
                } else {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.wsWarmIvory)
                        .frame(width: 90, height: 90)
                }
            }
            
            // Product Short Name
            Text(product.shortName ?? product.name)
                .font(.wsBody(size: 11, weight: .semibold))
                .foregroundColor(.wsCharcoal)
                .lineLimit(1)
            
            // Price & Add Button
            HStack {
                Text((product.price ?? 0.0).currencyText)
                    .font(.wsBody(size: 11))
                    .foregroundColor(.wsCharcoal.opacity(0.7))
                
                Spacer()
                
                Button(action: {
                    onAdd(product)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.wsCharcoal)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
