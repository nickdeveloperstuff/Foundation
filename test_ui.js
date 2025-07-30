const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });
  
  await page.goto('http://localhost:4000/tester-demo');
  await page.waitForTimeout(2000); // Wait for page to fully render
  
  await page.screenshot({ path: 'screenshots/tester-demo-fixed.png' });
  
  console.log('Screenshot saved to screenshots/tester-demo-fixed.png');
  
  await browser.close();
})();