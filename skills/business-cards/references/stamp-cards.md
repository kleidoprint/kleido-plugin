# Designing a stamp card

Read this with [html-artwork.md](html-artwork.md) when you design a loyalty stamp card yourself. Everything there still applies: the canvas sizes, the 18 px safe margin, the installed fonts, no network, and the proof before ordering. This file adds the stamp card layout.

## What goes where

- **Front**: the logo, the reward as the headline, the stamp grid, and the earn rule ("1 stamp = 1 purchase"). Nothing else. The grid is the largest element.
- **Back**: a brand face with a way to come back: the website, address, or social handle, and a QR code if the user gave a link. Add one short line of terms only if the user asked for it.

Use the 2x3.5 in card (560x320 landscape or 320x560 portrait) unless the user asks for another size.

## The grid

Work the numbers out before you draw anything:

- `stamps` is how many stamps earn the reward, counting the free one.
- `head_start` is 0 to 3 extra spaces printed already stamped.
- Draw `stamps + head_start` spaces in one grid, read left to right, top to bottom:
  1. The head-start spaces come first: filled with a brand color, a check mark inside, no number.
  2. Then `stamps - 1` empty spaces numbered 1, 2, 3, and so on.
  3. The last space is the reward: label it FREE, no number, and make it the only space in the accent color.
- With a head start, add one short line beside the grid: "First stamp on us" or "First 2 stamps on us".
- Never print a count of stamps or visits that disagrees with the grid or the reward.

Worked example, 10 stamps with a head start of 2: 12 spaces. Spaces 1 and 2 are pre-stamped, spaces 3 to 11 are numbered 1 to 9, and space 12 says FREE. The reward reads "Buy 9 coffees, get the 10th free".

Rows that fit:

- Landscape (560x320): up to 7 spaces in one row, up to 14 in two rows, more in three rows.
- Portrait (320x560): 3 columns for up to 9 spaces, otherwise 4 columns.

## Spaces

- Make every space the same circle or rounded square, 44 to 64 px across, with a fixed `width` and `height` and `flex-shrink: 0` so it never stretches into an oval.
- Leave at least 8 px between spaces, and keep every space inside the safe margin.
- Keep the inside of the empty spaces light so a rubber stamp or pen mark shows. Use a 2 px outline in a brand color.
- Put each number centered inside its space in small, quiet type (11 to 13 px). Nothing may touch or cross an outline.
- Matte prints take stamp ink and pen better than gloss; suggest matte when the user orders.

## Keep it calm

One background color per face, at most one quiet brand motif, and generous space around the grid. No confetti, scattered decorative circles, or thin colored strips along an edge.

## Front skeleton

A 10-stamp card with a head start of 2, landscape 560x320:

```html
<div
  style="width:560px;height:320px;box-sizing:border-box;position:relative;overflow:hidden;
         background:#fbf7f0;color:#2b1d14;font-family:Inter,sans-serif;padding:28px 32px;"
>
  <style>
    .grid { display:grid; grid-template-columns:repeat(6, 52px); gap:12px; margin-top:18px; }
    .s { width:52px; height:52px; flex-shrink:0; box-sizing:border-box; border-radius:50%;
         border:2px solid #7a4b2a; display:flex; align-items:center; justify-content:center;
         font-size:12px; color:#7a4b2a; }
    .done { background:#7a4b2a; color:#fbf7f0; font-size:20px; }
    .free { background:#d9822b; border-color:#d9822b; color:#fff; font-weight:700; font-size:12px; }
  </style>
  <div style="font-size:22px;font-weight:700;">Buy 9 coffees, get the 10th free</div>
  <div class="grid">
    <div class="s done">&#10003;</div><div class="s done">&#10003;</div>
    <div class="s">1</div><div class="s">2</div><div class="s">3</div><div class="s">4</div>
    <div class="s">5</div><div class="s">6</div><div class="s">7</div><div class="s">8</div>
    <div class="s">9</div><div class="s free">FREE</div>
  </div>
  <div style="position:absolute;left:32px;bottom:24px;font-size:14px;">
    1 stamp = any coffee &middot; First 2 stamps on us
  </div>
</div>
```

Add the logo at the top, from the business's website as inline SVG or a small `data:` image, and adjust the colors to the brand.

## Check before the proof

- The number of spaces is `stamps + head_start`, the numbers run 1 to `stamps - 1`, and the last space says FREE.
- The reward, the earn rule, and the "first stamps on us" line agree with the grid.
- Every space is a true circle or square of the same size, inside the 18 px margin.
- The usual checks in [html-artwork.md](html-artwork.md) pass.
