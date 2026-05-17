const fs = require('fs');

const dataFile = 'responses/skus.json';
let data = JSON.parse(fs.readFileSync(dataFile, 'utf8'));

const toRemoveTypes = [
  'cutting-board-oil',
  'tabletop-serveware-bowl',
  'lazy-susan',
  'oil',
  'bar-glasses-martini'
];

data = data.filter(item => !toRemoveTypes.includes(item.properties.productType));

function createProduct(baseItem, id, name, price, brand, color, imgPath) {
  const p = JSON.parse(JSON.stringify(baseItem));
  p.id = id;
  p.name = name;
  p.shortName = name;
  p.price.regularPrice = price;
  p.price.sellingPrice = price;
  p.price.retailPrice = price;
  if (p.properties) {
    p.properties.name = name;
    p.properties.shortName = name;
    if (brand) p.properties.brand = brand;
    if (color) p.properties.color = color;
  }
  if (p.media && p.media.images && p.media.images[0]) {
    p.media.images[0].path = imgPath || p.media.images[0].path;
  }
  return p;
}

const additions = [];

// 1. tea-kettles (need 1 more)
const baseTeaKettle = data.find(i => i.properties.productType === 'tea-kettles');
additions.push(createProduct(baseTeaKettle, '8000001', 'Le Creuset Classic Whistling Tea Kettle, 1.7-Qt., Flame', 115.0, 'le-creuset-parent/le-creuset', 'orange-parent/flame', '/lc_whistling_flame.jpg'));

// 2. bakeware-dishes (need 1 more)
const baseBakeware = data.find(i => i.properties.productType === 'bakeware-dishes');
additions.push(createProduct(baseBakeware, '8000002', 'Le Creuset Stoneware Rectangular Dish, 10.5", White', 55.0, 'le-creuset-parent/le-creuset', 'white-parent/white', '/lc_rect_white.jpg'));

// 3. dutch-ovens-braisers (need 1 more)
const baseBraiser = data.find(i => i.properties.productType === 'dutch-ovens-braisers');
additions.push(createProduct(baseBraiser, '8000003', 'Le Creuset Enameled Cast Iron Braiser, 3.5-Qt., Flame', 310.0, 'le-creuset-parent/le-creuset', 'orange-parent/flame', '/lc_braiser_flame.jpg'));

// 4. dutch-ovens (need 2 more)
const baseDutch = data.find(i => i.properties.productType === 'dutch-ovens');
additions.push(createProduct(baseDutch, '8000004', 'Le Creuset Enameled Cast Iron Signature Round Dutch Oven, 5.5-Qt., Flame', 420.0, 'le-creuset-parent/le-creuset', 'orange-parent/flame', '/lc_dutch_flame.jpg'));
additions.push(createProduct(baseDutch, '8000005', 'Staub Enameled Cast Iron Round Dutch Oven, 5.5-Qt., Matte Black', 340.0, 'staub-parent/staub', 'black-parent/matte-black', '/staub_dutch_black.jpg'));

// 5. coffee-maker (need 2 more)
const baseCoffee = data.find(i => i.properties.productType === 'coffee-maker');
additions.push(createProduct(baseCoffee, '8000006', 'Breville Precision Brewer Glass Coffee Maker', 299.95, 'breville', 'silver', '/breville_coffee.jpg'));
additions.push(createProduct(baseCoffee, '8000007', 'Technivorm Moccamaster KBGV Select Coffee Maker', 359.0, 'technivorm', 'silver', '/technivorm_coffee.jpg'));

// 6. stock-pots (need 2 more)
const baseStock = data.find(i => i.properties.productType === 'stock-pots');
additions.push(createProduct(baseStock, '8000008', 'All-Clad D3 Stainless Steel Stock Pot, 8-Qt.', 399.95, 'all-clad', 'silver', '/allclad_stockpot.jpg'));
additions.push(createProduct(baseStock, '8000009', 'Le Creuset Enamel On Steel Stock Pot, 8-Qt., Cerise', 115.0, 'le-creuset-parent/le-creuset', 'red-parent/cerise', '/lc_stockpot_cerise.jpg'));

// 7. cutting-boards-storage (need 2 more)
const baseBoard = data.find(i => i.properties.productType === 'cutting-boards-storage');
additions.push(createProduct(baseBoard, '8000010', 'Boos Edge-Grain Rectangular Cutting Board, Maple', 149.95, 'boos', 'brown', '/boos_board.jpg'));
additions.push(createProduct(baseBoard, '8000011', 'Williams Sonoma Walnut Edge-Grain Cutting Board', 129.95, 'williams-sonoma', 'brown', '/ws_walnut_board.jpg'));

// 8. cups-and-saucers (need 2 more)
const baseCup = data.find(i => i.properties.productType === 'cups-and-saucers');
additions.push(createProduct(baseCup, '8000012', 'Pillivuyt Brasserie Cup & Saucer', 29.95, 'pillivuyt', 'white', '/pillivuyt_cup.jpg'));
additions.push(createProduct(baseCup, '8000013', 'Le Creuset Stoneware Cappuccino Cup & Saucer', 22.0, 'le-creuset-parent/le-creuset', 'red-parent/cerise', '/lc_cup.jpg'));

// 9. fondue-sets (need 2 more)
const baseFondue = data.find(i => i.properties.productType === 'fondue-sets');
additions.push(createProduct(baseFondue, '8000014', 'Swissmar Lugano Cast Iron Fondue Set', 129.95, 'swissmar', 'black', '/swissmar_fondue.jpg'));
additions.push(createProduct(baseFondue, '8000015', 'Boska Bianco Tapas Fondue', 45.0, 'boska', 'white', '/boska_fondue.jpg'));

data = data.concat(additions);

fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
console.log('Successfully augmented data. Removed single items and added missing variants.');
