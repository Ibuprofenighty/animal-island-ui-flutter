import { test, expect } from '@playwright/test';

test.describe('Gallery Navigation, Story Rendering & Console Purity', () => {
  test('Gallery runs cleanly without uncaught JavaScript exceptions or console errors', async ({ page }) => {
    const consoleErrors: string[] = [];
    page.on('console', msg => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
      }
    });

    page.on('pageerror', error => {
      consoleErrors.push(error.message);
    });

    await page.goto('./');
    await page.waitForLoadState('networkidle');

    // Filter out benign browser warnings if any, assert 0 unhandled fatal errors
    const fatalErrors = consoleErrors.filter(err => !err.includes('favicon.ico') && !err.includes('WebGL'));
    expect(fatalErrors).toEqual([]);
  });

  test('Hash routes for components and provenance are navigable', async ({ page }) => {
    await page.goto('./#/provenance');
    await page.waitForLoadState('networkidle');

    const canvas = page.locator('canvas').first();
    await expect(canvas).toBeVisible();

    const box = await canvas.boundingBox();
    expect(box).not.toBeNull();
    expect(box!.width).toBeGreaterThan(0);
    expect(box!.height).toBeGreaterThan(0);
  });
});
