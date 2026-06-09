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

## Semrush MCP

NPM: `semrush-mcp` v0.1.5 (thomaswawra, Apr 2026). Config under `mcp_servers.semrush` with `SEMRUSH_API_KEY` env var. See native-mcp skill for full MCP config schema.

## Report Format

Structure findings as: Iyi Olanlar → Sorunku Olanlar → Acil Yapilar (max 5 priority items). Keep actionable.

## Client-Side Rendered Content Pitfall

Some websites (especially SPAs) render meta tags and content via JavaScript after the initial HTML load. The browser snapshot may show an empty `<head>` and `<body>` immediately after navigation, leading to missing meta tags.

**Fallback**: If `browser_console` returns empty or missing meta tags, fetch the raw HTML via terminal:

```bash
curl -s <URL> | grep -o '<meta name="[^"]*" content="[^"]*"'
```

Then extract values with `sed` or similar. Alternatively, wait for network idle by using `browser_snapshot` after a short delay or using `browser_console` with a `setTimeout` retry.

**Example** (from session): The page `https://tepeseo.com/ajans?...` initially returned empty head/body; using `curl` revealed the meta tags in the raw HTML.
