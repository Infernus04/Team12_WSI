const fs = require('fs');

const dataFile = 'responses/skus.json';
let data = JSON.parse(fs.readFileSync(dataFile, 'utf8'));

const imageMapping = {
  '/lc_whistling_flame.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Le+Creuset+Kettle',
  '/lc_rect_white.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Baking+Dish',
  '/lc_braiser_flame.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Braiser',
  '/lc_dutch_flame.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Le+Creuset+Dutch+Oven',
  '/staub_dutch_black.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Staub+Dutch+Oven',
  '/breville_coffee.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Breville+Coffee+Maker',
  '/technivorm_coffee.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Technivorm+Coffee',
  '/allclad_stockpot.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=All-Clad+Stock+Pot',
  '/lc_stockpot_cerise.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Le+Creuset+Stock+Pot',
  '/boos_board.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Boos+Cutting+Board',
  '/ws_walnut_board.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Walnut+Cutting+Board',
  '/pillivuyt_cup.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Pillivuyt+Cup',
  '/lc_cup.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Le+Creuset+Cup',
  '/swissmar_fondue.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Swissmar+Fondue',
  '/boska_fondue.jpg': 'https://placehold.co/400x400/EAEAEA/333333.png?text=Boska+Fondue'
};

data.forEach(item => {
  if (item.media && item.media.images && item.media.images[0]) {
    const p = item.media.images[0].path;
    if (imageMapping[p]) {
      item.media.images[0].path = imageMapping[p];
    }
  }
});

fs.writeFileSync(dataFile, JSON.stringify(data, null, 2));
console.log('Successfully updated URLs in skus.json');
