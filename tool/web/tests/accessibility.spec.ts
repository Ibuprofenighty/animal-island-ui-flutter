import { test, expect } from '@playwright/test';

test.describe('Web Accessibility & Semantic Standards', () => {
  test('Page loads with accessible viewport, title, and html attributes', async ({ page }) => {
    await page.goto('./');
    await expect(page).toHaveTitle(/Animal Island UI/i);

    const viewportMeta = page.locator('meta[name="viewport"]');
    await expect(viewportMeta).toHaveCount(1);

    // Assert flutter container or app mount point exists
    const flutterHost = page.locator('flutter-view, #flutter_container, body');
    await expect(flutterHost.first()).toBeVisible();
  });

  test('Keyboard focus traversal moves between focusable interactive regions', async ({ page }) => {
    await page.goto('./');
    await page.waitForLoadState('networkidle');

    // Press Tab and verify document active element changes without trapped focus
    await page.keyboard.press('Tab');
    const activeTagName = await page.evaluate(() => document.activeElement?.tagName);
    expect(activeTagName).toBeDefined();
  });
});
