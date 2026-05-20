/**
 * fix_image_mapping.cjs
 * 
 * Correctly maps product images based on product name, brand, and type.
 * The available images in /images/ are:
 *
 * NAMED IMAGES (we know what they show):
 *   allclad_stockpot.jpg         — All-Clad stock pot
 *   boos_board.jpg               — Boos cutting board (wooden)
 *   boska_fondue.jpg             — Boska fondue set
 *   lc_braiser_flame.jpg         — Le Creuset braiser, flame/orange
 *   lc_demi_semisalt.jpg         — Le Creuset demi tea kettle, sea salt color
 *   lc_dutch45_caribbean.jpg     — Le Creuset dutch oven 4.5qt, caribbean blue
 *   lc_dutch_flame.jpg           — Le Creuset dutch oven, flame/orange
 *   lc_fish_baker_seasalt.jpg    — Le Creuset fish baker, sea salt
 *   lc_fondue_cerise.jpg         — Le Creuset fondue pot, cerise/red
 *   lc_heritage_rect_cerise.jpg  — Le Creuset heritage rectangular dish, cerise
 *   lc_rect_white.jpg            — Le Creuset rectangular dish, white
 *   lc_stockpot_cerise.jpg       — Le Creuset stock pot, cerise
 *   lc_whistling_flame.jpg       — Le Creuset whistling tea kettle, flame
 *   mauviel_crepe_brass.jpg      — Mauviel copper crêpe pan with brass handle
 *   mc_mocha_kettle.jpg          — MacKenzie-Childs mocha check tea kettle
 *   pillivuyt_cup.jpg            — Pillivuyt porcelain cup
 *   ruffoni_historia_pineapple_55.jpg — Ruffoni Historia copper stock pot
 *   staub_deep_oven_3qt_cherry.jpg    — Staub deep oven 3qt, cherry red
 *   staub_dutch_black.jpg        — Staub dutch oven, black
 *   swissmar_fondue.jpg          — Swissmar fondue set
 *   technivorm_coffee.jpg        — Technivorm coffee maker
 *   ws_walnut_board.jpg          — Williams Sonoma walnut cutting board
 *
 * GENERIC IMAGES (from WS website, numbered):
 *   img4m.jpg, img5m.jpg, img10s.jpg, img12c.jpg, img17m.jpg, img23m.jpg,
 *   img27m.jpg, img42m.jpg, img57z.jpg, img64m.jpg, img83m.jpg, img95m.jpg,
 *   img122m.jpg, img153m.jpg, img236m.jpg
 *   moccamaster-by-technivorm-kbgv-select-coffee-maker-10-cup-z.jpg
 */

const fs = require('fs');

const dataFile = 'responses/skus.json';
let data = JSON.parse(fs.readFileSync(dataFile, 'utf8'));

/**
 * Match a product to its best image based on name, brand, productType, and other hints.
 */
function getBestImage(product) {
  const name = (product.name || '').toLowerCase();
  const brand = (product.properties?.brand || '').toLowerCase();
  const productType = (product.properties?.productType || '').toLowerCase();
  const collection = (product.properties?.collection || '').toLowerCase();
  const color = (product.properties?.color || '').toLowerCase();
  const material = (product.properties?.material || '').toLowerCase();

  // === EXACT PRODUCT MATCHES ===

  // MacKenzie-Childs Mocha Check Whistling Tea Kettle
  if (name.includes('mackenzie') && name.includes('kettle'))
    return '/mc_mocha_kettle.jpg';

  // Le Creuset Demi Tea Kettle, Sea Salt
  if (name.includes('le creuset') && name.includes('demi') && name.includes('kettle'))
    return '/lc_demi_semisalt.jpg';

  // Le Creuset Whistling Tea Kettle (flame)
  if (name.includes('le creuset') && name.includes('whistling'))
    return '/lc_whistling_flame.jpg';

  // Le Creuset Fondue Pot
  if (name.includes('le creuset') && name.includes('fondue'))
    return '/lc_fondue_cerise.jpg';

  // Boska fondue
  if (name.includes('boska') && name.includes('fondue'))
    return '/boska_fondue.jpg';

  // Swissmar fondue
  if (name.includes('swissmar') && name.includes('fondue'))
    return '/swissmar_fondue.jpg';

  // Le Creuset Heritage Rectangular Dish, Cerise
  if (name.includes('le creuset') && name.includes('heritage') && name.includes('rectangular'))
    return '/lc_heritage_rect_cerise.jpg';

  // Le Creuset Fish Baker
  if (name.includes('le creuset') && name.includes('fish baker'))
    return '/lc_fish_baker_seasalt.jpg';

  // Le Creuset Braiser
  if (name.includes('le creuset') && name.includes('braiser'))
    return '/lc_braiser_flame.jpg';

  // Le Creuset Dutch Oven — Caribbean
  if (name.includes('le creuset') && name.includes('dutch oven') && color.includes('caribbean'))
    return '/lc_dutch45_caribbean.jpg';

  // Le Creuset Dutch Oven — general / flame
  if (name.includes('le creuset') && name.includes('dutch oven'))
    return '/lc_dutch_flame.jpg';

  // Le Creuset Stock Pot
  if (name.includes('le creuset') && (name.includes('stock pot') || name.includes('stockpot')))
    return '/lc_stockpot_cerise.jpg';

  // Le Creuset Rectangular Dish (white or general)
  if (name.includes('le creuset') && (name.includes('rectangular') || name.includes('rect')))
    return '/lc_rect_white.jpg';

  // Staub Deep Oven, Cherry
  if (name.includes('staub') && name.includes('deep oven'))
    return '/staub_deep_oven_3qt_cherry.jpg';

  // Staub Dutch Oven
  if (name.includes('staub') && name.includes('dutch oven'))
    return '/staub_dutch_black.jpg';

  // Staub Fry Pan / Skillet (use staub deep oven as closest match)
  if (name.includes('staub') && (name.includes('fry pan') || name.includes('skillet')))
    return '/staub_deep_oven_3qt_cherry.jpg';

  // Ruffoni Historia Stock Pot
  if (name.includes('ruffoni'))
    return '/ruffoni_historia_pineapple_55.jpg';

  // Mauviel Crêpe Pan
  if (name.includes('mauviel'))
    return '/mauviel_crepe_brass.jpg';

  // All-Clad Stock Pot
  if (name.includes('all-clad') && (name.includes('stock pot') || name.includes('stockpot')))
    return '/allclad_stockpot.jpg';

  // Boos Cutting Board
  if (name.includes('boos') && name.includes('board'))
    return '/boos_board.jpg';

  // Williams Sonoma End-Grain Cutting Board / Board Oil / Walnut Board
  if (name.includes('cutting board') && name.includes('acacia'))
    return '/ws_walnut_board.jpg';
  if (name.includes('board oil'))
    return '/ws_walnut_board.jpg';
  if (name.includes('walnut') && name.includes('board'))
    return '/ws_walnut_board.jpg';

  // Technivorm / Moccamaster coffee maker
  if (name.includes('technivorm') || name.includes('moccamaster'))
    return '/technivorm_coffee.jpg';

  // Cuisinart coffee maker
  if (name.includes('cuisinart') && name.includes('coffee'))
    return '/img122m.jpg';

  // Breville coffee maker
  if (name.includes('breville') && name.includes('coffee'))
    return '/technivorm_coffee.jpg';

  // Apilco / Pillivuyt cups and saucers
  if (name.includes('apilco') && (name.includes('cup') || name.includes('saucer')))
    return '/pillivuyt_cup.jpg';
  if (name.includes('pillivuyt') && (name.includes('cup') || name.includes('saucer')))
    return '/pillivuyt_cup.jpg';

  // === BRAND + TYPE FALLBACKS ===

  // Le Creuset general cookware
  if (brand.includes('le-creuset') || brand.includes('le creuset')) {
    if (productType.includes('tea-kettle')) return '/lc_whistling_flame.jpg';
    if (productType.includes('dutch-oven') || productType.includes('braiser')) return '/lc_dutch_flame.jpg';
    if (productType.includes('fondue')) return '/lc_fondue_cerise.jpg';
    if (productType.includes('bakeware') || productType.includes('dish')) return '/lc_heritage_rect_cerise.jpg';
    if (productType.includes('stock')) return '/lc_stockpot_cerise.jpg';
    if (productType.includes('cookware-set')) return '/lc_dutch_flame.jpg';
    if (productType.includes('dinnerware')) return '/lc_heritage_rect_cerise.jpg';
    if (productType.includes('measuring')) return '/lc_demi_semisalt.jpg';
    // General Le Creuset fallback
    return '/lc_dutch_flame.jpg';
  }

  // Staub general
  if (brand.includes('staub')) {
    if (productType.includes('dutch') || productType.includes('braiser')) return '/staub_dutch_black.jpg';
    if (productType.includes('fry') || productType.includes('skillet')) return '/staub_deep_oven_3qt_cherry.jpg';
    return '/staub_dutch_black.jpg';
  }

  // Williams Sonoma brand items
  if (brand.includes('williams-sonoma') || brand.includes('williams sonoma')) {
    if (productType.includes('cutting-board') || productType.includes('board')) return '/ws_walnut_board.jpg';
    if (productType.includes('oil')) return '/ws_walnut_board.jpg';
    if (productType.includes('bar-glass') || productType.includes('martini')) return '/img57z.jpg';
    if (productType.includes('dinnerware')) return '/pillivuyt_cup.jpg';
    if (productType.includes('cookware-set')) return '/allclad_stockpot.jpg';
    if (productType.includes('olive') || name.includes('olive oil')) return '/img17m.jpg';
    return '/ws_walnut_board.jpg';
  }

  // Hold Everything brand
  if (brand.includes('hold-everything')) {
    if (productType.includes('lazy-susan')) return '/ws_walnut_board.jpg';
    if (productType.includes('bowl')) return '/img153m.jpg';
    return '/img236m.jpg';
  }

  // Pillivuyt
  if (brand.includes('pillivuyt')) {
    if (productType.includes('dinnerware')) return '/pillivuyt_cup.jpg';
    return '/pillivuyt_cup.jpg';
  }

  // Fortessa
  if (brand.includes('fortessa')) {
    return '/pillivuyt_cup.jpg';
  }

  // Apilco
  if (brand.includes('apilco')) {
    return '/pillivuyt_cup.jpg';
  }

  // === PRODUCT TYPE FALLBACKS ===

  if (productType.includes('tea-kettle') || productType.includes('kettle'))
    return '/mc_mocha_kettle.jpg';
  if (productType.includes('coffee'))
    return '/technivorm_coffee.jpg';
  if (productType.includes('fondue'))
    return '/swissmar_fondue.jpg';
  if (productType.includes('dutch') || productType.includes('braiser'))
    return '/staub_dutch_black.jpg';
  if (productType.includes('fry') || productType.includes('skillet'))
    return '/mauviel_crepe_brass.jpg';
  if (productType.includes('stock'))
    return '/allclad_stockpot.jpg';
  if (productType.includes('cutting-board') || productType.includes('board'))
    return '/ws_walnut_board.jpg';
  if (productType.includes('cup') || productType.includes('saucer') || productType.includes('mug'))
    return '/pillivuyt_cup.jpg';
  if (productType.includes('bakeware') || productType.includes('dish'))
    return '/lc_heritage_rect_cerise.jpg';
  if (productType.includes('dinnerware'))
    return '/pillivuyt_cup.jpg';
  if (productType.includes('cookware-set'))
    return '/allclad_stockpot.jpg';
  if (productType.includes('bar-glass') || productType.includes('martini') || productType.includes('wine'))
    return '/img57z.jpg';
  if (productType.includes('strainer') || productType.includes('colander'))
    return '/allclad_stockpot.jpg';
  if (productType.includes('measuring'))
    return '/img95m.jpg';
  if (productType.includes('lazy-susan'))
    return '/ws_walnut_board.jpg';
  if (productType.includes('oil'))
    return '/img17m.jpg';

  // === ULTIMATE FALLBACK ===
  // Use a generic but nice product image
  return '/img42m.jpg';
}

// Apply corrections
let changedCount = 0;
data.forEach((item, index) => {
  if (item.media && item.media.images && item.media.images[0]) {
    const oldPath = item.media.images[0].path;
    const newPath = getBestImage(item);
    if (oldPath !== newPath) {
      item.media.images[0].path = newPath;
      changedCount++;
      console.log(`[${index}] ${item.name}`);
      console.log(`   OLD: ${oldPath}`);
      console.log(`   NEW: ${newPath}`);
      console.log('');
    }
  }
});

fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
console.log(`\n✅ Fixed ${changedCount} image mappings out of ${data.length} products.`);
