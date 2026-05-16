import { Hono } from 'hono'
import { promises as fs } from 'fs'
import path from 'path'

const app = new Hono()

app.get('/', (c) => {
  return c.text('Hello Hono!')
})

// Wedding Registry Recommendation Engine - Initial Filtering
app.get('/products/wedding', async (c) => {
  try {
    const filePath = path.join(process.cwd(), 'responses', 'skus.json')
    const data = await fs.readFile(filePath, 'utf8')
    const products = JSON.parse(data)

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
    
    const filePath = path.join(process.cwd(), 'responses', 'skus.json')
    const data = await fs.readFile(filePath, 'utf8')
    const allProducts = JSON.parse(data)

    // Identify categories already in registry
    const registeredCategories = new Set()
    allProducts.forEach(p => {
      if (currentItems.includes(p.id)) {
        const patterns = Array.isArray(p.properties.pattern) ? p.properties.pattern : [p.properties.pattern]
        patterns.forEach(cat => registeredCategories.add(cat))
      }
    })

    // Suggest items from missing core categories
    const coreCategories = ['cookware', 'tabletop', 'glassware', 'electrics', 'homekeeping']
    const missingCategories = coreCategories.filter(cat => !registeredCategories.has(cat))

    const suggestions = allProducts.filter(p => {
      // Don't suggest items already in registry
      if (currentItems.includes(p.id)) return false
      
      const patterns = Array.isArray(p.properties.pattern) ? p.properties.pattern : [p.properties.pattern]
      return patterns.some(cat => missingCategories.includes(cat))
    })

    return c.json({
      missingCategories,
      recommendations: suggestions.slice(0, 10) // Return top 10 suggestions
    })
  } catch (error) {
    return c.json({ error: 'Failed to generate recommendations' }, 500)
  }
})

export default app



