/**
 * rename_images.cjs
 * 
 * Renames all misnamed and generic image files to accurate descriptive names,
 * then updates all references in skus.json.
 */

const fs = require('fs');
const path = require('path');

const imagesDir = 'images';
const dataFile = 'responses/skus.json';

// ============================================
// RENAME MAP: old filename → new filename
// ============================================
const renameMap = {
  // --- Misnamed files (filename doesn't match content) ---
  'lc_dutch45_caribbean.jpg':        'lc_dutch_cerise.jpg',           // Actually RED dutch oven, not Caribbean
  'lc_fish_baker_seasalt.jpg':       'lc_fish_baker_cerise.jpg',      // Actually RED fish baker, not sea salt
  'lc_fondue_cerise.jpg':            'lc_fondue_white.jpg',           // Actually WHITE fondue, not cerise
  'staub_deep_oven_3qt_cherry.jpg':  'staub_tall_cocotte_white.jpg',  // Actually WHITE/cream cocotte, not cherry
  'technivorm_coffee.jpg':           'breville_precision_brewer.jpg', // Actually Breville, not Technivorm

  // --- Generic numbered images → descriptive names ---
  'img4m.jpg':   'ws_olive_oil.jpg',               // WS Organic Extra-Virgin Olive Oil bottle
  'img5m.jpg':   'staub_frypan_citron.jpg',         // Staub fry pan, citron/yellow
  'img10s.jpg':  'staub_frypan_cream.jpg',          // Staub fry pan, cream/white
  'img12c.jpg':  'staub_frypan_cherry.jpg',         // Staub fry pan, cherry/red
  'img17m.jpg':  'ws_endgrain_board_acacia.jpg',    // WS End-Grain Cutting Board, Acacia
  'img23m.jpg':  'decorative_medallion_plate.jpg',  // Ornate Chinese rose medallion plate
  'img27m.jpg':  'ws_board_oil.jpg',                // Williams Sonoma Board Oil bottle
  'img42m.jpg':  'ceramic_pie_dish_navy.jpg',       // Dark navy ruffled ceramic pie dish
  'img57z.jpg':  'lc_cream_sugar_artichaut.jpg',    // Le Creuset cream & sugar set, green
  'img64m.jpg':  'ceramic_lidded_bowl_white.jpg',   // White ceramic bowl with wooden lid
  'img83m.jpg':  'staub_dutch_basil.jpg',           // Staub round dutch oven, basil/green
  'img95m.jpg':  'porcelain_cup_saucer_white.jpg',  // Plain white porcelain cup & saucer
  'img122m.jpg': 'cuisinart_coffee_maker.jpg',      // Cuisinart PerfecTemp 14-cup coffee maker
  'img153m.jpg': 'walnut_lazy_susan_tray.jpg',      // Walnut lazy susan with olive oil & herbs
  'img236m.jpg': 'crystal_martini_glass.jpg',       // Crystal/clear glass martini glass
};

// Step 1: Rename the actual image files
console.log('=== RENAMING IMAGE FILES ===\n');
let renamedCount = 0;

for (const [oldName, newName] of Object.entries(renameMap)) {
  const oldPath = path.join(imagesDir, oldName);
  const newPath = path.join(imagesDir, newName);
  
  if (fs.existsSync(oldPath)) {
    if (fs.existsSync(newPath)) {
      console.log(`⚠️  SKIP: ${newName} already exists, cannot rename ${oldName}`);
      continue;
    }
    fs.renameSync(oldPath, newPath);
    console.log(`✅ ${oldName}  →  ${newName}`);
    renamedCount++;
  } else {
    console.log(`❌ NOT FOUND: ${oldName}`);
  }
}

console.log(`\nRenamed ${renamedCount} files.\n`);

// Step 2: Update all paths in skus.json
console.log('=== UPDATING skus.json ===\n');
let data = JSON.parse(fs.readFileSync(dataFile, 'utf8'));
let updatedCount = 0;

data.forEach((item, index) => {
  if (item.media?.images?.[0]?.path) {
    const currentPath = item.media.images[0].path;
    // currentPath is like "/img42m.jpg" — extract the filename
    const filename = currentPath.replace(/^\//, '');
    
    if (renameMap[filename]) {
      const newPath = '/' + renameMap[filename];
      item.media.images[0].path = newPath;
      console.log(`[${index}] ${item.name}`);
      console.log(`   ${currentPath}  →  ${newPath}`);
      updatedCount++;
    }
  }
});

fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
console.log(`\n✅ Updated ${updatedCount} paths in skus.json.`);
console.log(`\nDone! Restart 'bun run dev' to apply changes.`);
