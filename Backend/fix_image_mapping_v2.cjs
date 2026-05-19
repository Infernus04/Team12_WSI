/**
 * fix_image_mapping_v2.cjs
 * 
 * CORRECTED after visually inspecting every single image file.
 * 
 * === TRUE IDENTITY OF EVERY IMAGE ===
 * 
 * allclad_stockpot.jpg       = All-Clad stainless steel stockpot ✅
 * boos_board.jpg             = John Boos maple cutting board ✅
 * boska_fondue.jpg           = Boska white ceramic fondue set with wood base ✅
 * lc_braiser_flame.jpg       = Le Creuset braiser, flame/orange ✅
 * lc_demi_semisalt.jpg       = Le Creuset demi kettle, cream/sea salt ✅
 * lc_dutch45_caribbean.jpg   = ⚠️ ACTUALLY a RED Le Creuset dutch oven (cerise, NOT caribbean)
 * lc_dutch_flame.jpg         = Le Creuset dutch oven, flame/orange ✅
 * lc_fish_baker_seasalt.jpg  = ⚠️ ACTUALLY a RED/cerise Le Creuset fish baker (NOT sea salt)
 * lc_fondue_cerise.jpg       = ⚠️ ACTUALLY a WHITE Le Creuset fondue pot (NOT cerise)
 * lc_heritage_rect_cerise.jpg= Le Creuset heritage rectangular dish, cerise/red ✅
 * lc_rect_white.jpg          = Le Creuset square baking dish, white/cream ✅ 
 * lc_stockpot_cerise.jpg     = Le Creuset enameled stockpot, cerise/red ✅
 * lc_whistling_flame.jpg     = Le Creuset whistling kettle, flame/orange ✅
 * mauviel_crepe_brass.jpg    = Mauviel copper crêpe pan with brass handle ✅
 * mc_mocha_kettle.jpg        = MacKenzie-Childs mocha check tea kettle ✅
 * pillivuyt_cup.jpg          = White cup & saucer with blue rim (Apilco Tradition style) ✅
 * ruffoni_historia_pineapple_55.jpg = Ruffoni hammered copper pot with pineapple knob ✅
 * staub_deep_oven_3qt_cherry.jpg = ⚠️ ACTUALLY a WHITE/cream Staub tall cocotte (NOT cherry)
 * staub_dutch_black.jpg      = Staub round dutch oven, black/graphite ✅
 * swissmar_fondue.jpg        = Swissmar dark green fondue set ✅
 * technivorm_coffee.jpg      = ⚠️ ACTUALLY a Breville Precision Brewer coffee maker
 * ws_walnut_board.jpg        = Williams Sonoma dark walnut cutting board ✅
 * 
 * img4m.jpg   = Williams Sonoma Organic Extra-Virgin Olive Oil bottle
 * img5m.jpg   = Staub fry pan, CITRON/yellow 
 * img10s.jpg  = Staub fry pan, CREAM/white
 * img12c.jpg  = Staub fry pan, CHERRY/red
 * img17m.jpg  = Williams Sonoma End-Grain Cutting Board, Acacia (mosaic pattern)
 * img23m.jpg  = Ornate Chinese Rose Medallion decorative plate
 * img27m.jpg  = Williams Sonoma Board Oil bottle
 * img42m.jpg  = Dark navy blue ceramic ruffled pie dish
 * img57z.jpg  = Le Creuset cream & sugar set, ARTICHAUT/green
 * img64m.jpg  = White ceramic lidded bowl (Hold Everything Ashwood style)
 * img83m.jpg  = Staub round dutch oven, BASIL/green
 * img95m.jpg  = Plain white porcelain cup & saucer (Open Kitchen style)
 * img122m.jpg = Cuisinart PerfecTemp 14-cup coffee maker ✅
 * img153m.jpg = Walnut lazy susan/tray with olive oil, vinegar, herbs
 * img236m.jpg = Crystal/clear glass martini glass (Dorset style)
 * moccamaster-by-technivorm-kbgv-select-coffee-maker-10-cup-z.jpg = (Moccamaster - not used)
 */

const fs = require('fs');

const dataFile = 'responses/skus.json';
let data = JSON.parse(fs.readFileSync(dataFile, 'utf8'));

/**
 * Corrected mapping based on actual visual inspection of every image.
 */
function getBestImage(product) {
  const name = (product.name || '').toLowerCase();
  const brand = (product.properties?.brand || '').toLowerCase();
  const productType = (product.properties?.productType || '').toLowerCase();
  const color = (product.properties?.color || '').toLowerCase();

  // =============================================
  // EXACT PRODUCT MATCHES (by product name)
  // =============================================

  // #1 & #75: WS End-Grain Cutting Board, Acacia
  if (name.includes('end-grain cutting board') || (name.includes('cutting board') && name.includes('acacia')))
    return '/img17m.jpg'; // The acacia end-grain board

  // #2 & #76: WS Board Oil  
  if (name.includes('board oil'))
    return '/img27m.jpg'; // The board oil bottle

  // #3: Hold Everything Lidded Ceramic Bowl, Ashwood
  if (name.includes('hold everything') && name.includes('ceramic bowl'))
    return '/img64m.jpg'; // White ceramic lidded bowl

  // #4 & #77: Apilco Tradition Porcelain Cup & Saucer
  if (name.includes('apilco') && (name.includes('cup') || name.includes('saucer')))
    return '/pillivuyt_cup.jpg'; // Blue-rimmed cup & saucer

  // #5: Staub Dutch Oven, 7-Qt., Basil
  if (name.includes('staub') && name.includes('dutch oven') && name.includes('basil'))
    return '/img83m.jpg'; // GREEN Staub dutch oven

  // #6: Cuisinart PerfecTemp Coffee Maker
  if (name.includes('cuisinart') && name.includes('coffee'))
    return '/img122m.jpg'; // Cuisinart coffee maker

  // #7: Hold Everything Lazy Susan, Walnut
  if (name.includes('lazy susan'))
    return '/img153m.jpg'; // Walnut tray/lazy susan

  // #8: WS Organic Olive Oil
  if (name.includes('olive oil'))
    return '/img4m.jpg'; // WS olive oil bottle

  // #9: Dorset Martini Glasses
  if (name.includes('dorset') && name.includes('martini'))
    return '/img236m.jpg'; // Crystal martini glass

  // #10: Staub Deep Skillet, 8½", Citron
  if (name.includes('staub') && name.includes('skillet') && name.includes('citron'))
    return '/img5m.jpg'; // Yellow/citron Staub fry pan

  if (name.includes('staub') && name.includes('deep skillet') && name.includes('citron'))
    return '/img5m.jpg';

  // #11: Staub Fry Pan, 10", Sapphire Blue
  if (name.includes('staub') && name.includes('fry pan') && name.includes('sapphire'))
    return '/img10s.jpg'; // Cream Staub fry pan (closest we have - no blue)

  // #12: Staub Fry Pan, 12", Cherry
  if (name.includes('staub') && name.includes('fry pan') && name.includes('cherry'))
    return '/img12c.jpg'; // Cherry/red Staub fry pan

  // #13: Le Creuset Demi Tea Kettle, Sea Salt
  if (name.includes('le creuset') && name.includes('demi') && name.includes('kettle'))
    return '/lc_demi_semisalt.jpg'; // Cream demi kettle ✅

  // #14: MacKenzie-Childs Mocha Check Whistling Tea Kettle
  if (name.includes('mackenzie') && name.includes('kettle'))
    return '/mc_mocha_kettle.jpg'; // Checkered kettle ✅

  // #15 & #57: Le Creuset Fondue Pot, Cerise
  if (name.includes('le creuset') && name.includes('fondue'))
    return '/lc_fondue_cerise.jpg'; // White fondue pot (filename says cerise but image is white)

  // #16 & #56: Le Creuset Heritage Rectangular Dish, Cerise
  if (name.includes('le creuset') && name.includes('heritage') && name.includes('rectangular'))
    return '/lc_heritage_rect_cerise.jpg'; // Red rectangular dish ✅

  if (name.includes('le creuset') && name.includes('rectangular baker'))
    return '/lc_heritage_rect_cerise.jpg';

  // #17 & #58: Le Creuset Fish Baker, Sea Salt
  if (name.includes('le creuset') && name.includes('fish baker'))
    return '/lc_fish_baker_seasalt.jpg'; // Red fish baker (filename says seasalt but image is red)

  // #18 & #53: Mauviel Crêpe Pan
  if (name.includes('mauviel') && name.includes('crêpe'))
    return '/mauviel_crepe_brass.jpg'; // Copper crêpe pan ✅
  if (name.includes('mauviel') && name.includes('crepe'))
    return '/mauviel_crepe_brass.jpg';

  // #19 & #55: Le Creuset Dutch Oven, 4.5 qt., Caribbean
  if (name.includes('le creuset') && name.includes('dutch oven') && name.includes('caribbean'))
    return '/lc_dutch45_caribbean.jpg'; // Red dutch oven (filename says caribbean but image is red)

  // Le Creuset Round Dutch Oven (general)
  if (name.includes('le creuset') && name.includes('round dutch oven'))
    return '/lc_dutch45_caribbean.jpg';

  // #20 & #52: Ruffoni Historia Stock Pot / Dutch Oven
  if (name.includes('ruffoni'))
    return '/ruffoni_historia_pineapple_55.jpg'; // Copper pot with pineapple knob ✅

  // #21 & #54: Staub Deep Oven, 3-Qt., Cherry
  if (name.includes('staub') && name.includes('deep oven'))
    return '/staub_deep_oven_3qt_cherry.jpg'; // White/cream Staub cocotte

  // #22: Open Kitchen 46-Piece Dinnerware Set
  if (name.includes('open kitchen') && name.includes('46-piece') && name.includes('dinnerware'))
    return '/img95m.jpg'; // Plain white cup & saucer (represents dinnerware)

  // #23: Open Kitchen Stainless-Steel 10-Piece Cookware Set
  if (name.includes('open kitchen') && name.includes('cookware'))
    return '/allclad_stockpot.jpg'; // Stainless steel pot

  // #24: Open Kitchen Cups & Saucers
  if (name.includes('open kitchen') && name.includes('cups') && name.includes('saucers'))
    return '/img95m.jpg'; // Plain white cup & saucer

  // #25: Open Kitchen Strainer Set
  if (name.includes('open kitchen') && name.includes('strainer'))
    return '/allclad_stockpot.jpg'; // Stainless steel (closest match)

  // #26-30: Le Creuset Cookware Sets
  if (name.includes('le creuset') && name.includes('stainless-steel') && name.includes('cookware'))
    return '/allclad_stockpot.jpg'; // Stainless sets
  if (name.includes('le creuset') && name.includes('enameled cast iron') && name.includes('cookware'))
    return '/lc_dutch_flame.jpg'; // Orange dutch oven represents the set
  if (name.includes('le creuset') && name.includes('ceramic nonstick') && name.includes('cookware'))
    return '/lc_braiser_flame.jpg'; // Orange braiser
  if (name.includes('le creuset') && name.includes('mixed material') && name.includes('cookware'))
    return '/allclad_stockpot.jpg';

  // #31: Le Creuset 14-Piece Measuring Set
  if (name.includes('le creuset') && name.includes('measuring'))
    return '/img57z.jpg'; // Green cream & sugar set (Le Creuset stoneware)

  // #32: Le Creuset Coupe Dinnerware Set
  if (name.includes('le creuset') && name.includes('dinnerware'))
    return '/lc_rect_white.jpg'; // White Le Creuset dish

  // #33: Pillivuyt Plisse Porcelain Dinnerware
  if (name.includes('pillivuyt'))
    return '/pillivuyt_cup.jpg'; // White cup with blue rim

  // #34: Fortessa Blyss Dinnerware
  if (name.includes('fortessa'))
    return '/img95m.jpg'; // Plain white cup

  // #35: Wedgwood Renaissance Gold
  if (name.includes('wedgwood') && name.includes('gold'))
    return '/img23m.jpg'; // Ornate decorative plate

  // #36: Wedgwood Renaissance Red
  if (name.includes('wedgwood') && name.includes('red'))
    return '/img23m.jpg'; // Ornate decorative plate

  // #37: Open Kitchen Red Wine Glasses
  if (name.includes('wine glass'))
    return '/img236m.jpg'; // Crystal glass

  // #38: Open Kitchen Tall Tumblers
  if (name.includes('tumbler'))
    return '/img236m.jpg'; // Crystal glass (closest)

  // #39-41: All-Clad Cookware Sets
  if (name.includes('all-clad'))
    return '/allclad_stockpot.jpg'; // Stainless pot ✅

  // #42: Breville Barista Express Espresso Machine
  if (name.includes('breville') && name.includes('barista'))
    return '/technivorm_coffee.jpg'; // This is actually a Breville machine!

  // #43: Breville Smart Oven Air Fryer
  if (name.includes('breville') && name.includes('smart oven'))
    return '/img42m.jpg'; // Blue pie dish (no oven image - needs replacement)

  // #44: Breville Smart Grinder Pro
  if (name.includes('breville') && name.includes('grinder'))
    return '/technivorm_coffee.jpg'; // Breville machine

  // #45: Vitamix A3500 Blender
  if (name.includes('vitamix') && name.includes('a3500'))
    return '/img42m.jpg'; // No blender image available

  // #46: KitchenAid Artisan Stand Mixer
  if (name.includes('kitchenaid'))
    return '/img42m.jpg'; // No mixer image available

  // #47: Smeg 2-Slice Toaster
  if (name.includes('smeg') && name.includes('toaster'))
    return '/img42m.jpg'; // No toaster image available

  // #48: Smeg Electric Kettle
  if (name.includes('smeg') && name.includes('kettle'))
    return '/lc_whistling_flame.jpg'; // Orange kettle (closest to Smeg style)

  // #49: Zwilling Pro Knife Block Set
  if (name.includes('zwilling'))
    return '/img42m.jpg'; // No knife image available

  // #50: Wusthof Classic Knife Set
  if (name.includes('wusthof'))
    return '/img42m.jpg'; // No knife image available

  // #51: Global Starter Knife Set
  if (name.includes('global') && name.includes('knife'))
    return '/img42m.jpg'; // No knife image available

  // #59: Martha Stewart x GreenPan Cookware Set
  if (name.includes('martha stewart') || name.includes('greenpan'))
    return '/allclad_stockpot.jpg'; // Stainless pot

  // #60: Open Kitchen Flatware
  if (name.includes('flatware'))
    return '/allclad_stockpot.jpg'; // Stainless (closest)

  // #61: Open Kitchen Dinner Plates
  if (name.includes('dinner plates'))
    return '/img95m.jpg'; // White porcelain

  // #62: Open Kitchen Cereal Bowls
  if (name.includes('cereal bowls'))
    return '/img95m.jpg'; // White porcelain

  // #63: Open Kitchen Mugs
  if (name.includes('open kitchen') && name.includes('mugs'))
    return '/img95m.jpg'; // White porcelain cup

  // #64: Open Kitchen 3-Piece Platter Set
  if (name.includes('platter'))
    return '/lc_rect_white.jpg'; // White serving dish

  // #65: WS Ultimate Hosting Starter Set
  if (name.includes('ultimate hosting'))
    return '/img153m.jpg'; // Tray with oils/herbs

  // #66: WS Daily Cooking Essentials Set
  if (name.includes('daily cooking'))
    return '/allclad_stockpot.jpg'; // Stainless pot

  // #67: WS Shared Dining Essentials Set
  if (name.includes('shared dining'))
    return '/img153m.jpg'; // Tray with dining items

  // #68: WS Morning Coffee Ritual Set
  if (name.includes('morning coffee'))
    return '/img122m.jpg'; // Coffee maker

  // #69: Robert Welch Kingham Flatware
  if (name.includes('robert welch'))
    return '/allclad_stockpot.jpg'; // Stainless (flatware)

  // #70: Schott Zwiesel Champagne Flutes
  if (name.includes('champagne'))
    return '/img236m.jpg'; // Crystal glass

  // #71: Schott Zwiesel Burgundy Glasses
  if (name.includes('burgundy'))
    return '/img236m.jpg'; // Crystal glass

  // #72: Nespresso VertuoPlus
  if (name.includes('nespresso'))
    return '/img122m.jpg'; // Coffee machine

  // #73: OXO POP Container Set
  if (name.includes('oxo') && name.includes('pop'))
    return '/img64m.jpg'; // White lidded bowl (closest to container)

  // #74: Hold Everything Pantry Canister Set
  if (name.includes('pantry canister'))
    return '/img64m.jpg'; // White lidded container

  // #78: Staub Ceramic Serving Bowl Set
  if (name.includes('staub') && name.includes('serving bowl'))
    return '/img83m.jpg'; // Green Staub (same brand, ceramic)

  // #79: Villeroy & Boch NewWave Dinnerware
  if (name.includes('villeroy'))
    return '/img95m.jpg'; // White porcelain

  // #80: Juliska Berry & Thread Place Setting
  if (name.includes('juliska'))
    return '/img23m.jpg'; // Ornate decorative plate

  // #81: Cuisinart Food Processor
  if (name.includes('cuisinart') && name.includes('food processor'))
    return '/img122m.jpg'; // Cuisinart appliance

  // #82: Vitamix Immersion Blender
  if (name.includes('vitamix') && name.includes('immersion'))
    return '/allclad_stockpot.jpg'; // Stainless (closest)

  // =============================================
  // BRAND FALLBACKS
  // =============================================
  if (brand.includes('le-creuset') || brand.includes('le creuset'))
    return '/lc_dutch_flame.jpg';
  if (brand.includes('staub'))
    return '/staub_dutch_black.jpg';
  if (brand.includes('williams-sonoma'))
    return '/ws_walnut_board.jpg';
  if (brand.includes('all-clad'))
    return '/allclad_stockpot.jpg';

  // ULTIMATE FALLBACK
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
    } else {
      console.log(`[${index}] ${item.name} → ✅ already correct (${oldPath})`);
    }
  }
});

fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
console.log(`\n✅ Fixed ${changedCount} image mappings out of ${data.length} products.`);
