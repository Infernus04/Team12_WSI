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
                .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.6))
            
            Text(AppStrings.Cart.emptyMessage)
                .font(AuraDesign.Fonts.serif(size: 24, weight: .semibold))
                .foregroundColor(AuraDesign.Colors.charcoal)
                .multilineTextAlignment(.center)
            
            Text("Discover beautiful pieces to complete your space.")
                .font(AuraDesign.Fonts.sansSerif(size: 16, weight: .regular))
                .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                onContinueShopping?()
            }) {
                Text(AppStrings.Cart.emptyButton)
                    .font(AuraDesign.Fonts.sansSerif(size: 15, weight: .medium))
                    .foregroundColor(AuraDesign.Colors.ivory)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(AuraDesign.Colors.charcoal)
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}
