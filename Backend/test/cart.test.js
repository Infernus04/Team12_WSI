import { describe, expect, test } from 'bun:test'

import { getCatalog, getRawCatalog } from '../src/lib/catalogRepository.js'
import { analyzeCart } from '../src/lib/cartRecommender.js'
import { scorePair } from '../src/lib/cartScorer.js'
import { quoteCheckout, submitCheckout } from '../src/lib/mockCheckout.js'

describe('catalog normalization', () => {
  test('normalizes stringified array metadata', async () => {
    const catalog = await getCatalog()
    const apilcoCup = catalog.find((product) => product.id === '1341411')

    expect(apilcoCup.patterns).toEqual(['tabletop', 'glassware'])
  })

  test('repairs the demi kettle image alias', async () => {
    const products = await getRawCatalog()
    const kettle = products.find((product) => product.id === '13344382564729065351')

    expect(kettle.media.images[0].path).toBe('/lc_demi_semisalt.jpg')
  })
})

describe('cart scoring', () => {
  test('scores same-collection cookware as a match', async () => {
    const catalog = await getCatalog()
    const dutchOven = catalog.find((product) => product.id === '2453926')
    const skillet = catalog.find((product) => product.id === '181543')

    const relationship = scorePair(dutchOven, skillet)

    expect(relationship.type).toBe('match')
    expect(relationship.score).toBeGreaterThanOrEqual(70)
  })

  test('suggests curated pairings for items in the cart', async () => {
    const body = await analyzeCart([
      { productId: '2453926', quantity: 1 }
    ])
    
    expect(body.pairings).toBeTruthy()
    expect(body.pairings.length).toBeGreaterThan(0)
    expect(body.pairings[0].recommendedItems.length).toBeGreaterThan(0)
  })
})

describe('mock checkout', () => {
  test('quotes subtotal, tax, and shipping', async () => {
    const quote = await quoteCheckout([
      { productId: '2453926', quantity: 1 },
      { productId: '181543', quantity: 2 },
    ])

    expect(quote.subtotal).toBeGreaterThan(0)
    expect(quote.shippingOptions.length).toBeGreaterThan(0)
    expect(quote.total).toBeGreaterThan(quote.subtotal)
  })

  test('returns a mock confirmation payload', async () => {
    const confirmation = await submitCheckout({
      items: [{ productId: '2453926', quantity: 1 }],
      shippingAddress: {
        firstName: 'Aura',
        lastName: 'Shopper',
        address1: '1 Market St',
        city: 'San Francisco',
        state: 'CA',
        postalCode: '94105',
        country: 'US',
      },
      deliveryOptionId: 'standard',
      paymentSummary: {
        cardholderName: 'Aura Shopper',
        cardBrand: 'Visa',
        maskedNumber: '•••• 4242',
      }
    })

    expect(confirmation.orderId).toContain('AURA-')
    expect(confirmation.confirmationMessage).toContain('Aura Shopper')
    expect(confirmation.estimatedDelivery).toBeTruthy()
  })
})
