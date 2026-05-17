import { analyzeCart } from './src/lib/cartRecommender.js'
const items = [{ productId: "2453926", quantity: 1 }, { productId: "181543", quantity: 1 }];
const res = await analyzeCart(items, 'auto', 0);
console.log(JSON.stringify(res.recommendations.map(r => ({ type: r.type, id: r.suggestedItem.id, title: r.title })), null, 2));
