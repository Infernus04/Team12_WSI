import { analyzeCart } from './src/lib/cartRecommender.js'
const items = [{ productId: "2453926", quantity: 1 }, { productId: "5483103364487949759", quantity: 1 }];
const res = await analyzeCart(items, 'auto', 0);
console.log(JSON.stringify(res.recommendations, null, 2));
