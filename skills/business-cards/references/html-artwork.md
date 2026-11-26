# Designing print-ready card HTML

Read this when you design the card yourself. The `artworkSpec` that `get_print_specs` returns is the source of truth; this file summarizes it and adds what makes a card look good in print.

## The format

- Send two HTML fragments, `front_html` and `back_html`. Each is one root element at exactly the card's pixel size, 160 px per inch:
  - 2x3.5 in (the default): 560x320 landscape, 320x560 portrait
  - 2.125x3.5 in: 560x340 landscape, 340x560 portrait
- Both faces use the same size and orientation.
- Put the background color on the root element. The printer extends it into a 1/16 in bleed.
- Keep text, logos, and QR codes at least 18 px from every edge. Backgrounds and large color panels can run to the edge; thin borders and rules near the edge can't, because trim shifts slightly. With rounded corners, keep the corners empty.
- Use inline styles or one `<style>` block. JavaScript is disabled, and the network is blocked: no `<script>`, `<link>`, `@import`, web fonts, or images from a URL. Use inline SVG, or `data:` URIs for small raster images.
- Installed fonts: Inter (also used for `system-ui` and `ui-sans-serif`), Gelasio (for Georgia and `ui-serif`), Liberation Sans (for Helvetica and Arial), and Liberation Serif (for `serif` and Times). Any other font falls back to one of these.
- Both faces together must be under 900 KB.

## Sizes that print well

At 160 px per inch, 1 pt is about 2.2 px. Text that looks fine on screen at 11 px prints at 5 pt, which is too small to read.

- Name: 24 to 34 px
- Title and company: 15 to 18 px
- Contact lines: at least 15 px (about 7 pt)
- QR code: at least 112 px (0.7 in) square, dark on light, with a light margin around it

Use dark text on a light background or the reverse. Mid-gray text on white, or white on a pale brand color, fades in print.

## Getting the brand right

- If the user has a website, read the business name, logo, and main colors from it. Use the real logo as inline SVG or a small `data:` image. Don't redraw a logo by hand; if you can't get it, set the business name in type and tell the user.
- Use one or two brand colors plus a neutral. Pick the font closest to the site's from the four installed ones.
- A common layout puts the brand on the front (logo, business name, maybe a short tagline) and the person on the back (name, title, contact lines, QR code). Ask the user if they'd like something else.

## QR codes

Never draw a QR code by hand or approximate one: it won't scan. In an environment where you can run code, generate it as SVG with a QR library and inline the result. Otherwise leave the QR code off, or use Kleido's designer with `qr_url`, which adds a working one.

## Skeleton

```html
<div
  style="width:560px;height:320px;box-sizing:border-box;position:relative;overflow:hidden;
         background:#0f3d3e;color:#ffffff;font-family:Inter,sans-serif;padding:32px;"
>
  <!-- content stays inside the 32px padding, clear of the 18px safe margin -->
  <div style="font-size:30px;font-weight:600;">Ada Moreno</div>
  <div style="font-size:16px;margin-top:4px;opacity:0.85;">Head Baker, Rye &amp; Co.</div>
  <div style="position:absolute;left:32px;bottom:32px;font-size:15px;line-height:1.5;">
    ada@ryeandco.com<br />(415) 555-0142
  </div>
</div>
```

## Show a proof before ordering

Kleido has no preview for HTML you write, so show the user both faces at actual size before `create_print_order`:

- **If you can write files and run a browser** (coding agents such as Claude Code, Codex, or Cursor): write both faces side by side into a local HTML file, open it or take a screenshot, and check it yourself before showing the user.
- **If the app can display HTML** (an artifact, canvas, or preview pane): show both faces there.
- **Otherwise**: describe the layout and give the user the HTML to open themselves.

Before you ask for approval, check:

- Every root is exactly the card's pixel size, and nothing overflows it.
- Nothing is within 18 px of an edge.
- Text sizes and contrast meet the guidance above.
- The details match what the user gave, spelled exactly.
- No external URLs remain in `src`, `href`, or `url()`.
