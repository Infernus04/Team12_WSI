//
//  EmptyCartView.swift
//  WSHackathonApp
//
//  Created by Nilesh Mahajan on 05/04/26.
//
import SwiftUI
struct EmptyCartView: View {
    
    var onContinueShopping: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bag")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.wsCharcoal.opacity(0.6))
            
            Text(AppStrings.Cart.emptyMessage)
                .font(.wsDisplay(size: 24))
                .foregroundColor(.wsCharcoal)
                .multilineTextAlignment(.center)
            
            Text("Discover beautiful pieces to complete your space.")
                .font(.wsBody(size: 16))
                .foregroundColor(.wsCharcoal.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                onContinueShopping?()
            }) {
                Text(AppStrings.Cart.emptyButton)
            }
            .buttonStyle(WSPrimaryButtonStyle())
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
