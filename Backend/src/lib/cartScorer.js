import {
  areComplementaryFamilies,
  colorConflictPenalty,
  deriveAestheticLabel,
  heroConflictPenalty,
  patternConflictPenalty,
} from './cartTaxonomy.js'

const WEIGHTS = {
  collection: 30,
  material: 20,
  color: 15,
  pattern: 10,
  complement: 10,
  crossBrand: 5,
}

function clamp(value, minimum = 0, maximum = 100) {
  return Math.max(minimum, Math.min(maximum, value))
}

function intersect(left, right) {
  const rightSet = new Set(right)
  return left.filter((value) => rightSet.has(value))
}

function buildReasoningText(positiveSignals, negativeSignals) {
  return positiveSignals.length > 0 ? positiveSignals.join('. ') : 'A coordinated selection.'
}

export function scorePair(leftProduct, rightProduct) {
  let score = 35 // Boost baseline to ensure even stronger positive baseline
  const positiveSignals = []

  if (leftProduct.primaryCollection && leftProduct.primaryCollection === rightProduct.primaryCollection) {
    score += WEIGHTS.collection
    positiveSignals.push(`Shared ${leftProduct.brandLabel} collection creates continuity`)
  }

  const sharedMaterials = intersect(leftProduct.materials, rightProduct.materials)
  if (sharedMaterials.length > 0) {
    score += WEIGHTS.material
    positiveSignals.push(`Shared ${sharedMaterials[0].replace(/-/g, ' ')} material keeps the palette grounded`)
  }

  if (leftProduct.colorFamily && leftProduct.colorFamily === rightProduct.colorFamily) {
    score += WEIGHTS.color
    positiveSignals.push(`Matching ${leftProduct.colorLabel.toLowerCase()} tones feel cohesive`)
  }

  if (
    intersect(leftProduct.patterns, rightProduct.patterns).length > 0 ||
    leftProduct.family === rightProduct.family
  ) {
    score += WEIGHTS.pattern
    positiveSignals.push('They speak the same visual language')
  }

  if (areComplementaryFamilies(leftProduct.family, rightProduct.family)) {
    score += WEIGHTS.complement
    positiveSignals.push('Their functions naturally complete each other')
  }

  if (
    leftProduct.brandFamily !== rightProduct.brandFamily &&
    areComplementaryFamilies(leftProduct.family, rightProduct.family) &&
    (leftProduct.primaryMaterial === rightProduct.primaryMaterial ||
      leftProduct.colorFamily === rightProduct.colorFamily ||
      intersect(leftProduct.patterns, rightProduct.patterns).length > 0)
  ) {
    score += WEIGHTS.crossBrand
    positiveSignals.push('The cross-brand mix still feels intentionally curated')
  }

  const normalizedScore = clamp(Math.round(score))
  const type = normalizedScore >= 70 ? 'match' : 'neutral'

  return {
    id: `${leftProduct.id}:${rightProduct.id}`,
    item1Id: leftProduct.id,
    item2Id: rightProduct.id,
    type,
    score: normalizedScore,
    reasoningText: buildReasoningText(positiveSignals, []),
    positiveSignals,
    negativeSignals: [],
  }
}

function summarizeItemAverages(items, relationships) {
  const compatibility = new Map(items.map((item) => [item.id, { total: 0, count: 0 }]))

  for (const relationship of relationships) {
    compatibility.get(relationship.item1Id).total += relationship.score
    compatibility.get(relationship.item1Id).count += 1
    compatibility.get(relationship.item2Id).total += relationship.score
    compatibility.get(relationship.item2Id).count += 1
  }

  return new Map(
    [...compatibility.entries()].map(([id, summary]) => {
      const average = summary.count === 0 ? 60 : Math.round(summary.total / summary.count)
      return [id, average]
    }),
  )
}

function deriveCompletenessStatus(items, relationships, confidenceScore) {
  if (items.length <= 1) return 'incomplete'
  if (items.length >= 3 && confidenceScore >= 70) return 'complete'
  return 'building'
}

export function scoreCart(items) {
  const relationships = []

  for (let leftIndex = 0; leftIndex < items.length; leftIndex += 1) {
    for (let rightIndex = leftIndex + 1; rightIndex < items.length; rightIndex += 1) {
      relationships.push(scorePair(items[leftIndex], items[rightIndex]))
    }
  }

  const itemAverages = summarizeItemAverages(items, relationships)
  const averageRelationshipScore = relationships.length
    ? relationships.reduce((total, relationship) => total + relationship.score, 0) / relationships.length
    : items.length === 1
      ? 65
      : 0
    
  const rawConfidence = (averageRelationshipScore * 0.9) + 10
  // Boost the harmony score to hover around 70% to keep users in a neutral perspective
  const confidenceScore = clamp(Math.round(45 + (rawConfidence * 0.55)))
  const sortedAverages = [...itemAverages.entries()].sort((left, right) => right[1] - left[1])
  const anchorItemId = sortedAverages[0]?.[0] ?? items[0]?.id ?? null

  return {
    confidenceScore,
    overallAesthetic: deriveAestheticLabel(items),
    completenessStatus: deriveCompletenessStatus(items, relationships, confidenceScore),
    relationships,
    anchorItemId,
    itemAverageScores: itemAverages,
    averageRelationshipScore,
  }
}
