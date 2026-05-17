import { Hono } from 'hono'
import { serveStatic } from '@hono/node-server/serve-static'

import { analyzeCart } from './lib/cartRecommender.js'
import { getCatalog, getRawCatalog } from './lib/catalogRepository.js'
import { quoteCheckout, submitCheckout } from './lib/mockCheckout.js'

const app = new Hono()

// Serve static images
app.use('/images/*', serveStatic({ root: './' }))


app.get('/', (c) => {
  return c.text('Hello Hono!')
})

// Wedding Registry Recommendation Engine - Initial Filtering
app.get('/products/wedding', async (c) => {
  try {
    const products = await getRawCatalog()

    // Filter for wedding-appropriate items
    // High-level filter: Must be gift-wrappable and belong to core registry categories
    const weddingProducts = products.filter(product => {
      const isGiftable = product.properties.canGiftWrap === 'true'
      const isFood = product.properties.isFood === 'true'
      
      // Traditional wedding registry categories
      const weddingPatterns = ['cookware', 'tabletop', 'glassware', 'electrics', 'homekeeping']
      const pattern = Array.isArray(product.properties.pattern) 
        ? product.properties.pattern 
        : [product.properties.pattern]
      
      const hasWeddingCategory = pattern.some(p => weddingPatterns.includes(p))

      return isGiftable && !isFood && hasWeddingCategory
    })

    return c.json({
      count: weddingProducts.length,
      products: weddingProducts
    })
  } catch (error) {
    console.error('Error fetching wedding products:', error)
    return c.json({ error: 'Failed to fetch products' }, 500)
  }
})

// Suggest recommendations based on current registry
app.post('/recommendations', async (c) => {
  try {
    const { currentItems = [] } = await c.req.json()
    const allProducts = await getCatalog()

    // Identify categories already in registry
    const registeredCategories = new Set()
    allProducts.forEach(p => {
      if (currentItems.includes(p.id)) {
        const patterns = p.patterns
        patterns.forEach(cat => registeredCategories.add(cat))
      }
    })

    // Suggest items from missing core categories
    const coreCategories = ['cookware', 'tabletop', 'glassware', 'electrics', 'homekeeping']
    const missingCategories = coreCategories.filter(cat => !registeredCategories.has(cat))

    const suggestions = allProducts.filter(p => {
      // Don't suggest items already in registry
      if (currentItems.includes(p.id)) return false

      return p.patterns.some(cat => missingCategories.includes(cat))
    })

    return c.json({
      missingCategories,
      recommendations: suggestions.slice(0, 10).map(product => product.raw) // Return top 10 suggestions
    })
  } catch (error) {
    return c.json({ error: 'Failed to generate recommendations' }, 500)
  }
})

app.post('/cart/analyze', async (c) => {
  try {
    const { items = [] } = await c.req.json()

    if (!Array.isArray(items)) {
      return c.json({ error: 'items must be an array' }, 400)
    }

    const analysis = await analyzeCart(items)
    return c.json(analysis)
  } catch (error) {
    console.error('Error analyzing cart:', error)
    return c.json({ error: 'Failed to analyze cart' }, 500)
  }
})

app.post('/checkout/quote', async (c) => {
  try {
    const { items = [] } = await c.req.json()

    if (!Array.isArray(items)) {
      return c.json({ error: 'items must be an array' }, 400)
    }

    return c.json(await quoteCheckout(items))
  } catch (error) {
    console.error('Error quoting checkout:', error)
    return c.json({ error: 'Failed to build checkout quote' }, 500)
  }
})

app.post('/checkout/submit', async (c) => {
  try {
    const payload = await c.req.json()
    return c.json(await submitCheckout(payload))
  } catch (error) {
    console.error('Error submitting checkout:', error)
    return c.json({ error: 'Failed to submit checkout' }, 500)
  }
})

// Unfiltered Product Catalogue
app.get('/skus', async (c) => {
  try {
    const products = await getRawCatalog()
    return c.json({
      count: products.length,
      products: products
    })
  } catch (error) {
    return c.json({ error: 'Failed to fetch skus' }, 500)
  }
})

export default app
export { app }



