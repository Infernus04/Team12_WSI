import { analyzeCart } from './src/lib/cartRecommender.js'
let items = [{ productId: "2453926", quantity: 1 }, { productId: "181543", quantity: 1 }];
let res = await analyzeCart(items, 'auto', 0);
let firstRec = res.recommendations[0];
console.log("First rec:", firstRec.type, firstRec.suggestedItem.id, firstRec.suggestedItem.name);

// Add it to cart
items.push({ productId: firstRec.suggestedItem.id, quantity: 1 });
let res2 = await analyzeCart(items, 'auto', 0);
console.log("Second rec:", res2.recommendations[0]?.type, res2.recommendations[0]?.suggestedItem?.id, res2.recommendations[0]?.suggestedItem?.name);
