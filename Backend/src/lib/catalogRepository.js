import { promises as fs } from 'fs'
import path from 'path'

import { deriveProductFamily, humanizeToken, normalizeSlug } from './cartTaxonomy.js'

const CATALOG_PATH = path.join(process.cwd(), 'responses', 'skus.json')
const IMAGE_ALIASES = new Map([
  ['/lc_demi_seasalt.jpg', '/lc_demi_semisalt.jpg'],
])

let rawCatalogPromise
let normalizedCatalogPromise

function parseArrayLikeString(value) {
  if (Array.isArray(value)) {
    return value.flatMap((entry) => parseArrayLikeString(entry))
  }

  if (typeof value !== 'string') {
    return value == null ? [] : [String(value)]
  }

  const trimmed = value.trim()

  if (!trimmed.startsWith('[') || !trimmed.endsWith(']')) {
    return trimmed ? [trimmed] : []
  }

  if (trimmed.includes('{')) {
    try {
      const parsed = JSON.parse(trimmed)
      return Array.isArray(parsed) ? parsed : []
    } catch {
      return []
    }
  }

  const inner = trimmed.slice(1, -1).trim()
  if (!inner) return []

  return inner
    .split(',')
    .map((entry) => entry.trim())
    .filter(Boolean)
}

function cloneProduct(rawProduct) {
  const copy = JSON.parse(JSON.stringify(rawProduct))
  const image = copy.media?.images?.[0]
  if (image?.path) {
    image.path = fixImagePath(image.path)
  }
  return copy
}

function fixImagePath(pathValue) {
  return IMAGE_ALIASES.get(pathValue) ?? pathValue
}

function normalizeSegmentToken(rawValue) {
  const normalized = normalizeSlug(rawValue)
  if (!normalized) {
    return { family: '', value: '', label: '' }
  }

  const parts = normalized.split('/').filter(Boolean)
  const family = parts[0]?.replace(/-parent$/, '') ?? normalized
  const value = parts.at(-1) ?? normalized

  return {
    family,
    value,
    label: humanizeToken(value),
  }
}

function normalizeTextList(rawValue) {
  return parseArrayLikeString(rawValue)
    .map((entry) => {
      if (typeof entry !== 'string') return ''
      const token = normalizeSegmentToken(entry)
      return token.value || normalizeSlug(entry)
    })
    .filter(Boolean)
}

function normalizeProduct(rawProduct) {
  const raw = cloneProduct(rawProduct)
  const properties = raw.properties ?? {}
  const brandToken = normalizeSegmentToken(properties.brand)
  const colorToken = normalizeSegmentToken(properties.color)
  const patterns = normalizeTextList(properties.pattern)
  const collections = normalizeTextList(properties.collection)
  const materials = normalizeTextList(properties.material)
  const imagePath = raw.media?.images?.[0]?.path ?? ''

  return {
    id: raw.id,
    name: raw.name,
    shortName: raw.shortName ?? raw.name,
    price: raw.price?.sellingPrice ?? raw.price?.regularPrice ?? 0,
    imagePath,
    productType: normalizeSlug(properties.productType),
    family: deriveProductFamily(properties.productType, patterns),
    brandRaw: properties.brand ?? '',
    brandFamily: brandToken.family || brandToken.value,
    brandLabel: brandToken.label,
    colorRaw: properties.color ?? '',
    colorFamily: colorToken.family || colorToken.value,
    colorLabel: colorToken.label,
    patterns,
    primaryPattern: patterns[0] ?? '',
    collections,
    primaryCollection: collections[0] ?? '',
    materials,
    primaryMaterial: materials[0] ?? '',
    canGiftWrap: properties.canGiftWrap === 'true',
    isFood: properties.isFood === 'true',
    isShoppable: properties.isShoppable !== 'false',
    availability: raw.availability ?? 'UNKNOWN',
    deliveryEstimate: raw.deliveryEstimate ?? 'UNKNOWN',
    raw,
  }
}

async function loadRawCatalog() {
  const fileContents = await fs.readFile(CATALOG_PATH, 'utf8')
  const parsed = JSON.parse(fileContents)
  return parsed.map(cloneProduct)
}

export async function getRawCatalog() {
  rawCatalogPromise ??= loadRawCatalog()
  return rawCatalogPromise
}

export async function getCatalog() {
  normalizedCatalogPromise ??= getRawCatalog().then((catalog) => catalog.map(normalizeProduct))
  return normalizedCatalogPromise
}

export async function getCatalogMap() {
  const catalog = await getCatalog()
  return new Map(catalog.map((product) => [product.id, product]))
}

export { fixImagePath, normalizeProduct, parseArrayLikeString }
