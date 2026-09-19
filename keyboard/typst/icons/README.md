# Icons

`keyboard.typ` draws these on the keycaps.

## Lucide

Most are [Lucide](https://lucide.dev) v1.47.0, ISC licensed, fetched with:

    curl -O https://cdn.jsdelivr.net/npm/lucide-static@1.47.0/icons/<name>.svg

`delete.svg` is not drawn on any key — it is kept because `delete-forward.svg`
is derived from it.

## Simple Icons

`super-tux.svg` is the Linux penguin from [Simple Icons](https://simpleicons.org)
v13 (CC0). The Super key sends `LGui`, and Tux says that faster than any
abstract glyph. Swap it for Lucide's `grid-2x2`, `diamond` or `command` if you
would rather have a stroke icon there.

## Hand-drawn

Lucide has no equivalent, so these are drawn in the same 24x24 / stroke-width 2
geometry:

- `mouse-left`, `mouse-middle`, `mouse-right` — a three-button mouse with the
  pressed button filled.
- `wheel-up`, `wheel-down`, `wheel-left`, `wheel-right` — the same mouse with a
  bold arrow across the body.
- `delete-forward` — Lucide's backspace glyph mirrored via
  `transform="translate(24,0) scale(-1,1)"`.

The mouse icons are two-tone on purpose: the body is drawn in `#8b939d` so it
recedes, and only the part that the key actually operates — a button, or the
scroll direction — is in the ink colour. Drawn in one tone the button fill reads
as a triangle and the clicks become hard to tell from the scrolls.

## Colour

`stroke="currentColor"` is rewritten to the ink colour `#1f2328` on every file:
Typst renders SVGs independently of the surrounding text colour, so it has to be
baked in. Re-apply after adding an icon:

    sed -i 's/currentColor/#1f2328/g' *.svg
