import { getCatalogMap } from './catalogRepository.js'

const SHIPPING_OPTIONS = [
  {
    id: 'standard',
    label: 'Standard Delivery',
    detail: 'Reliable doorstep delivery in 5-7 business days',
    amount: 12,
    estimatedDays: '5-7 business days',
  },
  {
    id: 'white-glove',
    label: 'White Glove Coordination',
    detail: 'Priority handling with elevated delivery timing',
    amount: 24,
    estimatedDays: '2-3 business days',
  },
]

function roundCurrency(value) {
  return Math.round(value * 100) / 100
}

export async function quoteCheckout(items) {
  const catalogMap = await getCatalogMap()
  const subtotal = roundCurrency(
    items.reduce((total, item) => {
      const product = catalogMap.get(item.productId)
      return total + ((product?.price ?? 0) * item.quantity)
    }, 0),
  )

  const shippingOptions = SHIPPING_OPTIONS.map((option) => ({
    ...option,
    amount: subtotal >= 500 && option.id === 'standard' ? 0 : option.amount,
  }))
  const tax = roundCurrency(subtotal * 0.0825)
  const selectedShippingAmount = shippingOptions[0]?.amount ?? 0
  const total = roundCurrency(subtotal + tax + selectedShippingAmount)

  return {
    subtotal,
    shippingOptions,
    tax,
    total,
  }
}

export async function submitCheckout({ items, shippingAddress, deliveryOptionId, paymentSummary }) {
  const quote = await quoteCheckout(items)
  const deliveryOption = quote.shippingOptions.find((option) => option.id === deliveryOptionId) ?? quote.shippingOptions[0]
  const finalTotal = roundCurrency(quote.subtotal + quote.tax + (deliveryOption?.amount ?? 0))
  const placedAt = new Date().toISOString()
  const estimatedDelivery = deliveryOption?.estimatedDays ?? '5-7 business days'

  return {
    orderId: `AURA-${Date.now().toString().slice(-8)}`,
    placedAt,
    estimatedDelivery,
    confirmationMessage: `Your Aura cart for ${shippingAddress.firstName} ${shippingAddress.lastName} is confirmed.`,
    total: finalTotal,
    deliveryOption,
    paymentSummary,
  }
}
