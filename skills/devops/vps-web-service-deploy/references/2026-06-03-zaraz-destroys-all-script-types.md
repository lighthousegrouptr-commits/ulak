# 2026-06-03: Zaraz Destroys ALL Script Types in Minimal HTML Workers

## Problem
Cloudflare Zaraz (Web Analytics) injects scripts into HTML pages that destroy ALL script content:
- **Inline `<script>` tags**: content blanked (textContent.length === 0)
- **External `<script src="...">` references**: script tag appears in DOM but content never loads
- **`eval(atob("..."))` workarounds**: inline script content destroyed before execution

## Evidence
From browser console on `agentic.lighthousegroup.net.tr` with minimal HTML worker:
```
document.querySelectorAll('script') =>
  0: {src: "/cdn-cgi/zaraz/s.js?z=...", contentLen: 0}     ← Zaraz injected
  1: {src: "(inline)", contentLen: 2043}                     ← Our inline script (blanked)
  2: {src: "https://agentic.lighthousegroup.net.tr/app.js", contentLen: 0}  ← External script BLANKED
  3: {src: "(inline)", contentLen: 34}                       ← Zaraz helper
  4: {src: "(inline)", contentLen: 73}                       ← Zaraz helper
  5: {src: "(inline)", contentLen: 34}                       ← Zaraz helper
```

Meanwhile, `curl https://agentic.lighthousegroup.net.tr/app.js` returned correct JS content (2713 bytes).
The JS was correct. The server was correct. Zaraz destroyed it at the DOM level.

## Failed Workarounds (DO NOT TRY)
1. **Base64 eval**: `eval(atob("..."))` — Zaraz blanks the inline script content
2. **External script src**: `<script src="/app.js">` — Zaraz prevents loading
3. **String concatenation**: `</scr"+"ipt>` — HTML parser still sees `</script>`
4. **Escape sequence**: `<\/script>` — HTML parser still sees `</script>`
5. **Variable injection**: `${_s}` where `_s = '</script>'` — still outputs literal `</script>`

## Why the TanStack SPA Works
Vite generates `<script src="/assets/index-HASH.js">` references that load bundled JS from the Worker's asset serving. These bundled references are NOT destroyed by Zaraz. The exact reason is unclear (possibly because they're loaded as separate requests rather than inline), but it consistently works.

## Correct Approach
**Always deploy the full TanStack SPA for any dashboard that needs to work under Cloudflare Zaraz.**

```bash
cd /opt/agentic-os
bun run aggregate          # refresh data
bun run build              # bundle SPA with Vite
rm -rf .wrangler           # clean stale deploy config
npx wrangler deploy        # deploy from project root
```

## Key Insight
Zaraz is a Cloudflare **zone-level** setting. It affects ALL pages served through Cloudflare for that domain. The only ways to avoid it:
1. Use the Vite-bundled SPA approach (works because of how Vite references scripts)
2. Exclude the subdomain in Cloudflare Dashboard → Zaraz → Exclude Pages
3. Disable Zaraz entirely (not recommended — affects analytics)

## User Feedback
User explicitly rejected the minimal HTML worker approach: "Çözüm zor" (the solution is hard/complex). User chose option 2: "restore the original TanStack SPA". User later confirmed: "Son yaptığımız şey bozdu" (the last thing we did broke it) — referring to the aggregate+rebuild cycle that should have been safe but broke due to `.wrangler` cache conflict.

## Lesson
When the user says "it was working before, now it's broken", the answer is NOT to try a new approach. The answer is to restore what was working, exactly as it was working.
