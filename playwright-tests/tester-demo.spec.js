const { test, expect } = require('@playwright/test');
const path = require('path');
const fs = require('fs').promises;

test.describe('Tester Demo Page Visual Testing', () => {
  test('should capture full page screenshot of SaaS dashboard', async ({ page }) => {
    await page.goto('/tester-demo');
    
    await page.waitForLoadState('networkidle');
    
    await page.waitForTimeout(2000);
    
    const screenshotDir = path.join(__dirname, '..', 'screenshots');
    await fs.mkdir(screenshotDir, { recursive: true });
    
    const screenshotPath = path.join(screenshotDir, 'tester-demo-dashboard.png');
    await page.screenshot({ 
      path: screenshotPath,
      fullPage: true 
    });
    
    console.log(`Screenshot saved to: ${screenshotPath}`);
    
    await expect(page.locator('h1')).toContainText('Dashboard Overview');
    await expect(page.locator('text=SaaSy Dashboard')).toBeVisible();
    
    const cardElements = await page.locator('[class*="span-"]').all();
    expect(cardElements.length).toBeGreaterThan(5);
    
    await expect(page.locator('text=Total Revenue')).toBeVisible();
    await expect(page.locator('text=Active Users')).toBeVisible();
    await expect(page.locator('text=New Signups')).toBeVisible();
    await expect(page.locator('text=Churn Rate')).toBeVisible();
    
    await expect(page.locator('#activity-table')).toBeVisible();
    
    const viewportScreenshotPath = path.join(screenshotDir, 'tester-demo-viewport.png');
    await page.screenshot({ 
      path: viewportScreenshotPath,
      fullPage: false 
    });
    
    console.log(`Viewport screenshot saved to: ${viewportScreenshotPath}`);
  });
  
  test('should capture mobile view of dashboard', async ({ browser }) => {
    const context = await browser.newContext({
      viewport: { width: 375, height: 812 },
      userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
    });
    
    const page = await context.newPage();
    await page.goto('/tester-demo');
    
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);
    
    const screenshotDir = path.join(__dirname, '..', 'screenshots');
    const screenshotPath = path.join(screenshotDir, 'tester-demo-mobile.png');
    
    await page.screenshot({ 
      path: screenshotPath,
      fullPage: true 
    });
    
    console.log(`Mobile screenshot saved to: ${screenshotPath}`);
    
    await context.close();
  });
  
  test('should capture tablet view of dashboard', async ({ browser }) => {
    const context = await browser.newContext({
      viewport: { width: 768, height: 1024 },
      userAgent: 'Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1'
    });
    
    const page = await context.newPage();
    await page.goto('/tester-demo');
    
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);
    
    const screenshotDir = path.join(__dirname, '..', 'screenshots');
    const screenshotPath = path.join(screenshotDir, 'tester-demo-tablet.png');
    
    await page.screenshot({ 
      path: screenshotPath,
      fullPage: true 
    });
    
    console.log(`Tablet screenshot saved to: ${screenshotPath}`);
    
    await context.close();
  });
});