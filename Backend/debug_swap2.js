import { scoreCart } from './src/lib/cartScorer.js';
import { getCatalogMap } from './src/lib/catalogRepository.js';

const cat = await getCatalogMap();
const item1 = cat.get('2453926');
const item2 = cat.get('5483103364487949759');
const item3 = cat.get('13344382564729065351');

const current = scoreCart([{...item1, quantity: 1}, {...item2, quantity: 1}], 'auto');
const projected = scoreCart([{...item1, quantity: 1}, {...item3, quantity: 1}], 'auto');

console.log("Current confidence:", current.confidenceScore);
console.log("Projected confidence:", projected.confidenceScore);
console.log("Improvement:", projected.confidenceScore - current.confidenceScore);
