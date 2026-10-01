import { test, expect } from '@playwright/test';

test.describe('Offline Bundling & Zero External Asset Leakage', () => {
  test('Page executes with strictly ZERO network requests to external typography CDNs', async ({ page }) => {
    const externalRequests: string[] = [];

    page.on('request', request => {
      const url = request.url();
      if (
        url.includes('fonts.googleapis.com') ||
        url.includes('fonts.gstatic.com') ||
        url.includes('cdn.') ||
        url.includes('cdnjs.') ||
        url.includes('unpkg.com')
      ) {
        externalRequests.push(url);
      }
    });

    await page.goto('./');
    await page.waitForLoadState('networkidle');

    // Assert zero external font or script dependencies requested
    expect(externalRequests).toEqual([]);
  });

  test('Local assets and service workers load with HTTP 200/304', async ({ page }) => {
    const failedUrls: { url: string; status: number }[] = [];

    page.on('response', response => {
      if (response.status() >= 400) {
        failedUrls.push({ url: response.url(), status: response.status() });
      }
    });

    await page.goto('./');
    await page.waitForLoadState('networkidle');

    expect(failedUrls).toEqual([]);
  });
});
