const FAMILY_BY_PRODUCT_TYPE = new Map([
  ['dutch-ovens', 'cookware'],
  ['dutch-ovens-braisers', 'cookware'],
  ['fry-pans-skillets', 'cookware'],
  ['stock-pots', 'cookware'],
  ['fondue-sets', 'cookware'],
  ['bakeware-dishes', 'bakeware'],
  ['tea-kettles', 'tea'],
  ['coffee-maker', 'electrics'],
  ['bar-glasses-martini', 'tabletop'],
  ['cups-and-saucers', 'tabletop'],
  ['tabletop-serveware-bowl', 'serveware'],
  ['lazy-susan', 'serveware'],
  ['cutting-boards-storage', 'prep'],
  ['cutting-board-oil', 'prep'],
  ['oil', 'pantry'],
])

const COMPLEMENTS = {
  cookware: new Set(['cookware', 'bakeware', 'tea', 'tabletop', 'serveware']),
  bakeware: new Set(['cookware', 'tabletop', 'serveware']),
  tea: new Set(['cookware', 'tabletop', 'serveware', 'electrics']),
  electrics: new Set(['tabletop', 'serveware', 'prep']),
  tabletop: new Set(['serveware', 'tea', 'electrics', 'bakeware']),
  serveware: new Set(['tabletop', 'tea', 'prep']),
  prep: new Set(['cookware', 'serveware', 'pantry']),
  pantry: new Set(['prep', 'tabletop']),
}

const HERO_PRODUCT_TYPES = new Set([
  'dutch-ovens',
  'dutch-ovens-braisers',
  'stock-pots',
  'coffee-maker',
  'fondue-sets',
])

const STRONG_COLOR_FAMILIES = new Set(['red', 'blue', 'yellow', 'green', 'copper'])
const QUIET_COLOR_FAMILIES = new Set(['brown', 'white', 'clear', 'silver'])

export const OCCASION_MODES = ['auto', 'everyday', 'hosting', 'gifting']

export function normalizeSlug(value) {
  return String(value ?? '')
    .trim()
    .toLowerCase()
    .replace(/["']/g, '')
}

export function humanizeToken(value) {
  return String(value ?? '')
    .replace(/[-_/]+/g, ' ')
    .replace(/\b\w/g, (char) => char.toUpperCase())
    .trim()
}

export function deriveProductFamily(productType = '', patterns = []) {
  const normalizedType = normalizeSlug(productType)

  if (FAMILY_BY_PRODUCT_TYPE.has(normalizedType)) {
    return FAMILY_BY_PRODUCT_TYPE.get(normalizedType)
  }

  const normalizedPatterns = patterns.map(normalizeSlug)

  if (normalizedPatterns.includes('cookware')) return 'cookware'
  if (normalizedPatterns.includes('tabletop') || normalizedPatterns.includes('glassware')) return 'tabletop'
  if (normalizedPatterns.includes('homekeeping')) return 'serveware'
  if (normalizedPatterns.includes('electrics')) return 'electrics'
  if (normalizedPatterns.includes('food')) return 'pantry'

  return 'lifestyle'
}

export function areComplementaryFamilies(leftFamily, rightFamily) {
  if (!leftFamily || !rightFamily) return false
  if (leftFamily === rightFamily) {
    return ['cookware', 'tabletop', 'serveware', 'prep'].includes(leftFamily)
  }

  return COMPLEMENTS[leftFamily]?.has(rightFamily) ?? false
}

export function isHeroPiece(product) {
  return HERO_PRODUCT_TYPES.has(product.productType) || (product.family === 'cookware' && product.price >= 180)
}

export function colorConflictPenalty(leftColor, rightColor) {
  if (!leftColor || !rightColor || leftColor === rightColor) return 0
  if (QUIET_COLOR_FAMILIES.has(leftColor) || QUIET_COLOR_FAMILIES.has(rightColor)) return 0

  return STRONG_COLOR_FAMILIES.has(leftColor) && STRONG_COLOR_FAMILIES.has(rightColor) ? 15 : 0
}

export function patternConflictPenalty(leftPatterns, rightPatterns) {
  const left = new Set(leftPatterns.map(normalizeSlug))
  const right = new Set(rightPatterns.map(normalizeSlug))

  if (left.has('check') && !right.has('check') && right.size > 0) return 12
  if (right.has('check') && !left.has('check') && left.size > 0) return 12
  if (left.has('hammered') && right.has('solid')) return 8
  if (right.has('hammered') && left.has('solid')) return 8

  return 0
}

export function heroConflictPenalty(leftProduct, rightProduct) {
  if (!isHeroPiece(leftProduct) || !isHeroPiece(rightProduct)) return 0
  if (leftProduct.primaryCollection && leftProduct.primaryCollection === rightProduct.primaryCollection) return 0
  if (leftProduct.brandFamily === rightProduct.brandFamily && leftProduct.colorFamily === rightProduct.colorFamily) return 0

  return 18
}

export function deriveAestheticLabel(items) {
  if (items.length === 0) return 'Curated Selection';

  const materials = new Set(items.flatMap(i => i.materials));
  const brands = new Set(items.map(i => i.brandLabel));
  const collections = new Set(items.map(i => i.primaryCollection).filter(Boolean));

  if (collections.size === 1) {
    const colName = [...collections][0].replace(/-/g, ' ');
    return `${colName.charAt(0).toUpperCase() + colName.slice(1)} Collection`;
  }
  
  if (brands.size === 1) {
    return `${[...brands][0]} Assortment`;
  }

  if (materials.has('enameled-cast-iron')) {
    return 'Enameled Cast Iron Selection';
  }

  if (materials.has('porcelain') || materials.has('lead-free-crystal')) {
    return 'Classic Tabletop Selection';
  }

  if (materials.has('wood') || materials.has('acacia')) {
    return 'Natural Wood Collection';
  }

  return 'Curated Kitchen Selection';
}
