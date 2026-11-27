---
name: business-cards
description: Design, edit, and order printed business cards with Kleido. Use when the user wants business cards made or reprinted, wants to change a card they already have on Kleido, pastes a kleidoprint.com/c/ link, or asks about a Kleido print order.
---

# Kleido business cards

The Kleido connector gives you these tools: `get_print_specs`, `design_card_with_kleido`, `get_kleido_design`, `list_cards`, `get_card_for_editing`, `edit_card`, `revert_card`, `create_print_order`, `list_orders`, and `get_order`.

If the tools aren't available, the user hasn't connected their Kleido account yet. Tell them to connect Kleido in this app's connector or MCP settings and sign in with their Kleido account. In Claude Code that's `/mcp`, then `plugin:kleido-print:kleido`; in Cursor it's the `plugin-kleido-print-kleido` server under MCP settings; on claude.ai, in Cowork, and in ChatGPT it's the Kleido connector in the plugin's settings. Setup help for every app is at https://www.kleidoprint.com/agents.

## Pick the job

- **New cards**: follow [Design a new card](#design-a-new-card), then [Order prints](#order-prints).
- **Changes to a card they have** (a kleidoprint.com/c/ link, or "my card"): follow [Edit a saved card](#edit-a-saved-card).
- **Order status**: call `list_orders` or `get_order` and answer only what they asked. These are read-only. If the user lost the payment link for an unpaid order, `get_order` returns it as `checkoutUrl` while the checkout is still open.

## Design a new card

1. Collect what goes on the card: the business website, then the person's name, title, email, phone, website, and location, plus an optional QR code link and any style direction. Print only what the user gave you. Never invent contact details.
2. Call `get_print_specs`. It returns the artwork format, finishes, prices, and the user's Kleido designer credits.
3. Unless the user already chose, offer the two routes in one short message:
   - **Kleido's designer**: reads the logo, colors, and style from their website. Costs 1 credit per design. Say how many credits they have.
   - **You design it**: free. You write the card as HTML.

   With no credits left, recommend designing it yourself. Credits aren't sold through AI assistants, so don't offer to buy them or link to a purchase.

4. Then follow the route they picked:
   - **Kleido's designer**: call `design_card_with_kleido` with `website_url` and whatever details, `qr_url`, and `style_notes` they gave. Ask for one design (`designs: 1`) unless they want more, because each costs a credit. Share `watchUrl`, then call `get_kleido_design` about every 20 seconds until the status is `succeeded` or `failed`. Show each `previewUrl` with its letter (A to D) and ask which to print. They can fix text on the card page before ordering. A failed design is refunded; offer to retry or to design it yourself.
   - **You design it**: read [references/html-artwork.md](references/html-artwork.md) and the `artworkSpec` from `get_print_specs`. Where they differ, the spec wins. Show the user a proof of both faces before you order (see the reference for how) and revise until they approve it.

## Edit a saved card

1. Get the card link from the user, or find it with `list_cards`.
2. Call `get_card_for_editing` and share `previewUrl`. The page updates live as you save.
3. Call `edit_card` with the latest `revision`. Prefer small find-and-replace `edits` on the HTML you read. Change printed text with `field_values` and the QR link with `qr_url`. Send a whole `front_html` or `back_html` only for a redesign. Follow the `rules` that `get_card_for_editing` returns.
4. Look at the two images `edit_card` returns. Fix text that overflows, weak contrast, and anything within 18 px of an edge before you tell the user it's done.
5. If `edit_card` says the card changed since you read it, call `get_card_for_editing` again and reapply the change.
6. `revert_card` undoes every design change (HTML edits) and restores the original design. Ask the user before calling it. It doesn't undo `field_values` or `qr_url`: to undo those, call `edit_card` with the earlier values, so note them before you change them.

Editing is free. The user orders prints of a saved card from its card page.

## Order prints

1. Confirm everything in one message and wait for a clear yes:
   - the design (the Kleido design and letter, or your HTML proof)
   - size and orientation
   - finish: matte or gloss
   - corners: squared or rounded
   - quantity: 100, 250, or 500, with the price from `get_print_specs`
   - the shipping address
2. Call `create_print_order`, with `design_id` and `variant` for a Kleido design or `front_html` and `back_html` for yours. Don't call it before the user confirms.
3. Give the user `checkoutUrl`. They pay on Stripe, the link expires in 24 hours, and printing starts after payment. You can't pay for them, and nothing is charged until they do.
4. If the result says the order was already placed, tell them and use `get_order` for its status.

Addresses take a two-letter country code. US addresses need a two-letter state code and a ZIP code. US shipping is free; international shipping is quoted at checkout.

## Errors

Kleido's error messages are written for the user, so relay them as they are. If a tool says Kleido had a problem on its side, don't retry right away; tell the user to try again in a few minutes or to email hello@kleidoprint.com.
