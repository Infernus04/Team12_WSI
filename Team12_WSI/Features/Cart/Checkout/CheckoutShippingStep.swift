import SwiftUI

struct CheckoutShippingStep: View {
    @Binding var address: CheckoutShippingAddress
    
    var body: some View {
        CheckoutSectionCard(title: "Delivery Details") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    checkoutField("First Name", text: $address.firstName)
                    checkoutField("Last Name", text: $address.lastName)
                }
                
                checkoutField("Address Line 1", text: $address.address1)
                checkoutField("Address Line 2", text: $address.address2)
                
                HStack(spacing: 12) {
                    checkoutField("City", text: $address.city)
                    checkoutField("State", text: $address.state)
                }
                
                HStack(spacing: 12) {
                    checkoutField("Postal Code", text: $address.postalCode)
                    checkoutField("Country", text: $address.country)
                }
            }
        }
    }
    
    private func checkoutField(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AuraDesign.Fonts.sansSerif(size: 12, weight: .semibold))
                .foregroundColor(AuraDesign.Colors.charcoal.opacity(0.7))
            
            TextField(title, text: text)
                .padding(.horizontal, 12)
                .padding(.vertical, 13)
                .background(AuraDesign.Colors.ivory)
                .cornerRadius(10)
        }
    }
}
