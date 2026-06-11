---
name: seo-audit
description: "SEO technical audit via browser: meta tags, structured data, headings, links, performance. Use when asked to analyze a site's SEO or check SEO health."
version: 1.0.0
author: Ulak Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [seo, audit, browser, analytics]
---

# SEO Technical Audit (Browser-Based)

When asked to analyze a site's SEO without Semrush/GSC access, use the browser to extract structured data via JavaScript evaluation.

## Quick Extract Script

Run via `browser_console(expression=...)`:

```javascript
(() => ({
  title: document.title,
  metaDescription: document.querySelector('meta[name="description"]')?.content || 'YOK',
  keywords: document.querySelector('meta[name="keywords"]')?.content || 'YOK',
  canonical: document.querySelector('link[rel="canonical"]')?.href || 'YOK',
  robots: document.querySelector('meta[name="robots"]')?.content || 'YOK',
  viewport: document.querySelector('meta[name="viewport"]')?.content || 'YOK',
  lang: document.documentElement.lang,
  charset: document.characterSet,
  generator: document.querySelector('meta[name="generator"]')?.content || 'YOK',
  h1: Array.from(document.querySelectorAll('h1')).map(h => h.textContent?.trim()),
  h2: Array.from(document.querySelectorAll('h2')).map(h => h.textContent?.trim()),
  h3count: document.querySelectorAll('h3').length,
  links: document.querySelectorAll('a[href]').length,
  internalLinks: Array.from(document.querySelectorAll('a[href]')).filter(a => a.href.includes(location.hostname)).length,
  externalLinks: Array.from(document.querySelectorAll('a[href]')).filter(a => !a.href.includes(location.hostname) && a.href.startsWith('http')).length,
  images: document.querySelectorAll('img').length,
  imagesWithoutAlt: Array.from(document.querySelectorAll('img')).filter(img => !img.alt || img.alt === '').length,
  structuredData: document.querySelectorAll('script[type="application/ld+json"]').length,
  favicon: !!document.querySelector('link[rel="icon"]') || !!document.querySelector('link[rel="shortcut icon"]'),
  ogTitle: document.querySelector('meta[property="og:title"]')?.content,
  ogDesc: document.querySelector('meta[property="og:description"]')?.content,
  ogImage: document.querySelector[meta[property="og:image"]')?.content,
  twitterCard: document.querySelector('meta[name="twitter:card"]')?.content,
  wordCount: document.body?.innerText?.trim().split(/\\s+/).length,
  hasGA: document.body?.innerHTML?.includes('google-analytics') || document.body?.innerHTML?.includes('gtag'),
  hasGTM: document.body?.innerHTML?.includes('googletagmanager'),
  hasPixel: document.body?.innerHTML?.includes('fbq'),
}))()
```

## Performance Extract

```javascript
(() => ({
  totalResources: performance.getEntriesByType('resource').length,
  domContentLoaded: Math.round(performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart),
  loadComplete: Math.round(performance.timing.loadEventEnd - performance.timing.navigationStart),
  fetchRequests: performance.getEntriesByType('resource').filter(r => r.initiatorType === 'fetch' || r.initiatorType === 'xmlhttprequest').map(r => r.name),
}))()
```

## CMS Detection

For SPA sites where meta tags don't reveal the CMS, check:
1. `__NEXT_DATA__` div → Next.js
2. `__NUXT__` → Nuxt
3. `___gatsby` → Gatsby
4. Network requests for `/api/`, `/graphql`, `/wp-json/`
5. If all fail, ask the user — don't guess.

## Common Pitfalls

**robots meta: noai / noimageai** — These tags BLOCK AI engines from training on your content. This is INTENTIONAL. Do NOT flag it as an error unless the site explicitly sells AI visibility services while also blocking AI (contradiction then warrants a flag).

**SPA word count** — SPAs may report low word counts if evaluated before full render. If count seems wrong visually, re-evaluate after a pause.

**H1 concatenation** — SPAs may render H1 text concatenated via CSS spacing. Not an SEO issue if it looks correct visually.

## Image Optimization

Large, unoptimized images are a common cause of poor LCP and increased page weight. Use the browser to identify oversized images, then compress them with `cwebp` (WebP) or consider AVIF for modern browsers.

**Detection**  
- Run the performance extract (see above) to list images and their dimensions if available, or inspect via DevTools → Network → Img.  
- Look for images with file size > 100 KB or dimensions significantly larger than displayed size.

**Compression workflow** (example for WebP):  
1. Fetch the original image (if you have server access):  
   ```bash
   curl -sL <image-url> -o original.webp
   ```  
2. Re‑encode with a quality setting that balances size and fidelity:  
   ```bash
   cwebp -q 75 original.webp -o optimized.webp   # try q 70‑85
   ```  
3. Compare file sizes:  
   ```bash
   ls -lh original.webp optimized.webp
   ```  
4. Replace the original on the server (or update the build step) and clear CDN/cache.  
5. Re‑run Lighthouse to verify LCP improvement.

**Pitfalls**  
- Do not push quality below ~60 for photographic images; noticeable artifacts may hurt user experience.  
- Always keep the original aspect ratio; avoid upscaling small images.  
- If the site uses `<picture>` or `srcset`, update all variants.  
- For audiences with older browsers, retain a JPEG/WebP fallback via `<picture>`.

**Automation tip**  
Add a script to your build pipeline (e.g., in `package.json`) that runs `cwebp` on all assets in `src/assets/` and outputs to `dist/assets/` with a quality of 75.

## Semrush MCP

## Semrush MCP

NPM: `semrush-mcp` v0.1.5 (thomaswawra, Apr 2026). Config under `mcp_servers.semrush` with `SEMRUSH_API_KEY` env var. See native-mcp skill for full MCP config schema.

## Report Format

Structure findings as: Iyi Olanlar → Sorunku Olanlar → Acil Yapilar (max 5 priority items). Keep actionable.


## Lighthouse Audit

When a deeper performance, accessibility, best practices, and SEO audit is needed, use the open‑source Lighthouse tool (https://github.com/GoogleChrome/lighthouse). It can be run headlessly via Node.js.

### Setup
1. Clone the Lighthouse repo:
   ```bash
   git clone https://github.com/GoogleChrome/lighthouse.git
   cd lighthouse
   ```
2. Install dependencies (use `--force` or `--legacy-peer-deps` if npm conflicts arise):
   ```bash
   npm install --force
   ```
3. Ensure a recent Chromium/Chrome is available and set the `CHROME_PATH` environment variable:
   ```bash
   export CHROME_PATH=/usr/bin/chromium-browser   # adjust path if needed
   ```
4. Optionally install Chromium via package manager if missing:
   ```bash
   apt-get update && apt-get install -y chromium-browser
   ```

### Running an Audit
Run Lighthouse against a target URL, outputting JSON for further processing:
```bash
npx lighthouse https://example.com \
  --output=json \
  --output-path=./report.json \
  --quiet \
  --chrome-flags="--headless --no-sandbox"
```

### Interpreting Results
The generated `report.json` contains categories scores (0‑1) under `categories`. Example extraction via Node:
```javascript
const report = require('./report.json');
console.log('Performance:', report.categories.performance.score*100||'N/A');
console.log('Accessibility:', report.categories.accessibility.score*100||'N/A');
console.log('Best Practices:', report.categories['best-practices'].score*100||'N/A');
console.log('SEO:', report.categories.seo.score*100||'N/A');
```

### Pitfalls
- **Missing Chrome**: Lighthouse will error `The CHROME_PATH environment variable must be set to a Chrome/Chromium executable`. Install Chromium and export `CHROME_PATH`.
- **Headless flags**: Some sites require `--no-sandbox` in container environments; add via `--chrome-flags`.
- **npm peer conflicts**: Use `--force` or `--legacy-peer-deps` when installing dependencies.
- **Large report**: The JSON can be huge; consider using `--preset=desktop` or `--preset=mobile` to limit categories.

### Automation Tip
Add a script to your CI pipeline that runs Lighthouse and fails if any category score falls below a threshold (e.g., performance < 90).

## Client-Side Rendered Content Pitfall

Some websites (especially SPAs) render meta tags and content via JavaScript after the initial HTML load. The browser snapshot may show an empty `<head>` and `<body>` immediately after navigation, leading to missing meta tags.

**Fallback**: If `browser_console` returns empty or missing meta tags, fetch the raw HTML via terminal:

```bash
curl -s <URL> | grep -o '<meta name="[^"]*" content="[^"]*"'
```

Then extract values with `sed` or similar. Alternatively, wait for network idle by using `browser_snapshot` after a short delay or using `browser_console` with a `setTimeout` retry.

**Example** (from session): The page `https://tepeseo.com/ajans?...` initially returned empty head/body; using `curl` revealed the meta tags in the raw HTML.
