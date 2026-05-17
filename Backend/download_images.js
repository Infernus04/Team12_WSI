import fs from 'fs';
import https from 'https';
import path from 'path';

const imagesToFetch = [
  { file: 'lc_whistling_flame.jpg', keyword: 'kettle' },
  { file: 'lc_rect_white.jpg', keyword: 'baking,dish' },
  { file: 'lc_braiser_flame.jpg', keyword: 'pan' },
  { file: 'lc_dutch_flame.jpg', keyword: 'pot' },
  { file: 'staub_dutch_black.jpg', keyword: 'castiron' },
  { file: 'breville_coffee.jpg', keyword: 'coffeemaker' },
  { file: 'technivorm_coffee.jpg', keyword: 'coffeemachine' },
  { file: 'allclad_stockpot.jpg', keyword: 'pot,cooking' },
  { file: 'lc_stockpot_cerise.jpg', keyword: 'pot,red' },
  { file: 'boos_board.jpg', keyword: 'cuttingboard' },
  { file: 'ws_walnut_board.jpg', keyword: 'wood,board' },
  { file: 'pillivuyt_cup.jpg', keyword: 'teacup' },
  { file: 'lc_cup.jpg', keyword: 'cappuccinocup' },
  { file: 'swissmar_fondue.jpg', keyword: 'fondue' },
  { file: 'boska_fondue.jpg', keyword: 'cheese,fondue' }
];

const dir = path.join(process.cwd(), 'Images');

async function downloadImage(filename, keyword) {
  return new Promise((resolve, reject) => {
    const url = `https://loremflickr.com/400/400/${keyword}`;
    const dest = path.join(dir, filename);
    
    https.get(url, (res) => {
      if (res.statusCode === 301 || res.statusCode === 302) {
        https.get(res.headers.location, (redirectRes) => {
          const file = fs.createWriteStream(dest);
          redirectRes.pipe(file);
          file.on('finish', () => {
            file.close();
            console.log(`Downloaded ${filename} for ${keyword}`);
            resolve();
          });
        }).on('error', reject);
      } else {
        const file = fs.createWriteStream(dest);
        res.pipe(file);
        file.on('finish', () => {
          file.close();
          console.log(`Downloaded ${filename} for ${keyword}`);
          resolve();
        });
      }
    }).on('error', reject);
  });
}

async function run() {
  for (const img of imagesToFetch) {
    try {
      await downloadImage(img.file, img.keyword);
    } catch (e) {
      console.error(`Failed to download ${img.file}: ${e.message}`);
    }
  }
}

run();
