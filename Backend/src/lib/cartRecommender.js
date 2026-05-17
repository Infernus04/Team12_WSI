import { getCatalogMap, getCatalog } from './catalogRepository.js'
import { areComplementaryFamilies } from './cartTaxonomy.js'

function buildCartItems(items, catalogMap) {
  return items
    .map(({ productId, quantity = 1 }) => {
      const product = catalogMap.get(productId)
      if (!product) return null
      return { ...product, quantity }
    })
    .filter(Boolean)
}

function buildCuratedPairings(cartItems, catalog) {
  const pairings = [];
  const cartIds = new Set(cartItems.map((item) => item.id));

  for (const item of cartItems) {
    const recommendedItems = [];

    for (const candidate of catalog) {
      if (cartIds.has(candidate.id) || candidate.isFood || !candidate.isShoppable) {
        continue;
      }

      let score = 0;

      // 1. Functional Complement
      if (areComplementaryFamilies(item.family, candidate.family)) {
        score += 2;
      }

      // 2. Exact Brand Family matching
      if (item.brandFamily === candidate.brandFamily) {
        score += 3;
      }

      // 3. Collection cohesion
      if (item.primaryCollection && item.primaryCollection === candidate.primaryCollection) {
        score += 4;
      }

      // 4. Material cohesion (e.g. wood with wood, porcelain with porcelain, cast iron with cast iron)
      const sharedMaterials = item.materials.filter(m => candidate.materials.includes(m));
      if (sharedMaterials.length > 0) {
        score += 3;
      }

      // 5. Color Cohesion
      if (item.colorFamily && item.colorFamily === candidate.colorFamily) {
        score += 2;
      }

      // 6. Direct category complements (highly legitimate pairings)
      // E.g. Cutting Board + cutting board oil
      if (item.productType === 'cutting-boards-storage' && candidate.productType === 'cutting-board-oil') {
        score += 10;
      }
      if (item.productType === 'cutting-board-oil' && candidate.productType === 'cutting-boards-storage') {
        score += 10;
      }
      
      // E.g. Coffee maker or Tea Kettle + Cups and saucers
      if ((item.productType === 'coffee-maker' || item.productType === 'tea-kettles') && candidate.productType === 'cups-and-saucers') {
        score += 10;
      }
      if (item.productType === 'cups-and-saucers' && (candidate.productType === 'coffee-maker' || candidate.productType === 'tea-kettles')) {
        score += 10;
      }

      // E.g. Stock pots or Dutch Ovens + Fry pans/Skillets (Cookware set completion)
      if ((item.productType === 'dutch-ovens' || item.productType === 'stock-pots') && candidate.productType === 'fry-pans-skillets') {
        score += 8;
      }
      if (item.productType === 'fry-pans-skillets' && (candidate.productType === 'dutch-ovens' || candidate.productType === 'stock-pots')) {
        score += 8;
      }

      // Avoid suggesting the same exact type of product (e.g., don't recommend a Dutch oven for a Dutch oven, unless there's nothing else)
      if (item.productType === candidate.productType) {
        score -= 5;
      }

      if (score > 0) {
        recommendedItems.push({
           candidate,
           score
        });
      }
    }

    // Sort by cohesion score and grab top 3
    recommendedItems.sort((a, b) => b.score - a.score);
    const topCandidates = recommendedItems.slice(0, 3).map(r => r.candidate.raw);

    if (topCandidates.length > 0) {
      pairings.push({
        id: item.id,
        sourceItemName: item.shortName,
        recommendedItems: topCandidates
      });
    }
  }

  return pairings;
}

export async function analyzeCart(cartLines) {
  const [catalog, catalogMap] = await Promise.all([getCatalog(), getCatalogMap()]);
  const cartItems = buildCartItems(cartLines, catalogMap);
  
  // Import dynamically to avoid circular dependency issues if any
  const { scoreCart } = await import('./cartScorer.js');
  const currentScore = scoreCart(cartItems);

  const curatedPairings = buildCuratedPairings(cartItems, catalog);

  return {
    confidenceScore: currentScore.confidenceScore,
    overallAesthetic: currentScore.overallAesthetic,
    completenessStatus: currentScore.completenessStatus,
    relationships: currentScore.relationships,
    pairings: curatedPairings,
  }
}
