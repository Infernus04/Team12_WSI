import SwiftUI

struct CheckoutPaymentStep: View {
    @Binding var paymentSummary: PaymentSummary
    
    private let supportedBrands = ["Visa", "Mastercard", "AmEx"]
    
    var body: some View {
        CheckoutSectionCard(title: "Payment Summary") {
            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cardholder")
                        .font(AuraDesign.Fonts.sansSerif(size: 12, weight: .semibold))
                        .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.7))
                    
                    TextField("Cardholder Name", text: $paymentSummary.cardholderName)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 13)
                        .background(AuraDesign.Colors.ivory)
                        .cornerRadius(10)
                }
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Brand")
                            .font(AuraDesign.Fonts.sansSerif(size: 12, weight: .semibold))
                            .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.7))
                        
                        Picker("Brand", selection: $paymentSummary.cardBrand) {
                            ForEach(supportedBrands, id: \.self) { brand in
                                Text(brand).tag(brand)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 13)
                        .background(AuraDesign.Colors.ivory)
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Last 4 Digits")
                            .font(AuraDesign.Fonts.sansSerif(size: 12, weight: .semibold))
                            .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.7))
                        
                        TextField("4242", text: $paymentSummary.lastFourDigits)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 13)
                            .background(AuraDesign.Colors.ivory)
                            .cornerRadius(10)
                            .onChange(of: paymentSummary.lastFourDigits) { _, newValue in
                                paymentSummary.lastFourDigits = String(newValue.filter(\.isNumber).prefix(4))
                            }
                    }
                }
                
                HStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .foregroundColor(AuraDesign.Colors.mutedGold)
                    Text("Only a masked payment summary is captured for this mock checkout.")
                        .font(AuraDesign.Fonts.sansSerif(size: 12))
                        .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.7))
                    Spacer()
                }
            }
        }
    }
}
