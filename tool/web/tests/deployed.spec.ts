import { test, expect } from '@playwright/test';
import * as fs from 'node:fs';
import * as path from 'node:path';

// Expected identity comes from the single sources: catalog/sdk.lock.json for the
// toolchain and pubspec.yaml for the package.
const repoRoot = path.resolve(__dirname, '..', '..', '..');
const sdkLock = JSON.parse(fs.readFileSync(path.join(repoRoot, 'catalog', 'sdk.lock.json'), 'utf8'));
const pubspec = fs.readFileSync(path.join(repoRoot, 'pubspec.yaml'), 'utf8');
const pubspecField = (key: string) => pubspec.match(new RegExp(`^${key}:\\s*(\\S+)`, 'm'))?.[1];

test.describe('Deployed Production Gallery E2E Verification (Stage S16)', () => {
  test('T16.03.1: Build-info metadata endpoint returns valid immutable build identity', async ({ page, baseURL }) => {
    const response = await page.request.get('./build-info.json');
    expect(response.status()).toBe(200);

    const data = await response.json();
    expect(data.package).toBe(pubspecField('name'));
    expect(data.version).toBe(pubspecField('version'));
    expect(data.flutter_version).toBe(sdkLock.flutter.frameworkVersion);
    expect(data.dart_version).toBe(sdkLock.flutter.dartSdkVersion);
    expect(data.commit).toMatch(/^[0-9a-f]{40}$/);
    if (process.env.GITHUB_SHA) expect(data.commit).toBe(process.env.GITHUB_SHA);
    expect(data.license).toBe('CC BY-NC 4.0');
  });

  test('T16.03.2: Initial load mounts CanvasKit and renders without console errors or CDN leaks', async ({ page }) => {
    const externalRequests: string[] = [];
    const consoleErrors: string[] = [];

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

    await expect(page).toHaveTitle(/Animal Island UI Gallery/i);

    const canvas = page.locator('canvas').first();
    await expect(canvas).toBeVisible();

    const box = await canvas.boundingBox();
    expect(box).not.toBeNull();
    expect(box!.width).toBeGreaterThan(0);
    expect(box!.height).toBeGreaterThan(0);

    // Assert strictly zero external font or script dependencies requested
    expect(externalRequests).toEqual([]);

    // Assert 0 fatal unhandled console errors
    const fatalErrors = consoleErrors.filter(err => !err.includes('favicon.ico') && !err.includes('WebGL'));
    expect(fatalErrors).toEqual([]);

    // Capture a screenshot into the Playwright test output
    const homeScreenshot = test.info().outputPath('gallery-home.png');
    await page.screenshot({ path: homeScreenshot, fullPage: false });
    expect(fs.existsSync(homeScreenshot)).toBe(true);
    expect(fs.statSync(homeScreenshot).size).toBeGreaterThan(1000);
  });

  test('T16.03.3: Hash deep linking, page reload, and history traversal recover cleanly', async ({ page }) => {
    // 1. Initial direct load on hash route
    await page.goto('./#/provenance');
    await page.waitForLoadState('networkidle');

    const canvas = page.locator('canvas').first();
    await expect(canvas).toBeVisible();

    // 2. Reload page on hash route (validates server fallback and Flutter bootstrapping on deep links)
    await page.reload();
    await page.waitForLoadState('networkidle');
    await expect(canvas).toBeVisible();

    // 3. SPA hash navigation within application
    await page.evaluate(() => {
      window.location.hash = '#/';
    });
    await page.waitForLoadState('networkidle');
    await expect(canvas).toBeVisible();

    // 4. Browser history back traversal
    await page.evaluate(() => {
      window.history.back();
    });
    await page.waitForLoadState('networkidle');
    await expect(canvas).toBeVisible();

    // 5. Browser history forward traversal
    await page.evaluate(() => {
      window.history.forward();
    });
    await page.waitForLoadState('networkidle');
    await expect(canvas).toBeVisible();

    // Capture a screenshot into the Playwright test output
    const provenanceScreenshot = test.info().outputPath('gallery-provenance.png');
    await page.screenshot({ path: provenanceScreenshot, fullPage: false });
    expect(fs.existsSync(provenanceScreenshot)).toBe(true);
    expect(fs.statSync(provenanceScreenshot).size).toBeGreaterThan(1000);
  });
});
