#import "@preview/cetz:0.5.2"
// =============================================================================
//  Corne (42-key split) keymap reference
//  Mirrors ../rmk/keyboard.toml — keep the two in sync.
//
//  Badge numbers are page ordinals, counting 1..10 down the sheet. They are
//  NOT the firmware's layer indices, which run 0..9 in a different order —
//  the crystal names are the identifier that matches across both files.
// =============================================================================

#set page(paper: "a4", margin: 0.4cm)
#set text(
  font: ("IBM Plex Sans", "Noto Sans", "Noto Sans Symbols 2", "Segoe UI Symbol"),
  fallback: true,
)
// Key legends are literal characters, never typography.
#set smartquote(enabled: false)
// Only the explicit #v() calls below should put space between the layers.
#set block(spacing: 0pt)

// ---------- Palette: one crystal per layer, named so the numbering can move --
#let c-jade = rgb("#2f7d5b") // green
#let c-topaz = rgb("#3a6ea5") // blue
#let c-opal = rgb("#7c3f8c") // purple
#let c-ruby = rgb("#a02c2c") // red
#let c-beryl = rgb("#0d7d84") // teal
#let c-amber = rgb("#b5591b") // orange
#let c-balas = rgb("#ad3572") // pink
#let c-lapis = rgb("#4a52a8") // indigo
#let c-onyx = rgb("#5a6b7a") // slate
#let c-prase = rgb("#6f8f12") // lime

#let ru-color = rgb("#1a5fb4") // secondary legend: Russian layout
#let us-color = rgb("#ad1a7a") // fourth legend: US, shown only where it differs
// magenta rather than green: green sits 64° from the Russian blue and the two
// were hard to tell apart at legend size; magenta is 108° clear of it.
#let ink = rgb("#1f2328")
#let label-ink = rgb("#464c56") // the word under a key symbol

// ---------- Geometry ----------
#let CONTENT-W = 20.2cm // A4 portrait less the margins
#let CONTENT-H = 28.9cm

#let GAP = 0.11cm // gap between keys
#let HAND-GAP = 0.4cm // gap between the two halves of a split layer
#let Lj = 0.84cm // jade carries six legends per letter, so it gets its own size
#let L = 0.63cm // the other split layers — two side by side, plus a side lane
#let Ls = 0.89cm // key size, one-handed layers — set by three fitting side by side

#let TITLE-H = 0.42cm // fixed, so every block height is known in advance
#let TITLE-GAP = 0.1cm
#let TIER-GAP = 0.85cm // between tiers; wide enough to run arrows through
#let JADE-GAP = 1.15cm // jade gets extra clearance below it
#let SECTION-GAP = 1cm
#let SOLO-GAP = 0.5cm // between one-handed layers on the middle tier

// =============================================================================
//  Text that always fits its keycap
// =============================================================================
#let fit(body, w, h, size) = context {
  let m = measure(text(size: size, body))
  let fw = if m.width > 0pt { w / m.width } else { 1.0 }
  let fh = if m.height > 0pt { h / m.height } else { 1.0 }
  text(size: size * calc.min(1.0, fw, fh), body)
}

// =============================================================================
//  What every keycode types under the OS layouts the board is used with.
//  Key = the UK legend, value = the Russian legend. Anything missing types the
//  same on both. US differences are handled separately, in `us-alt`/`us-bare`.
// =============================================================================
#let alt-legends = (
  // letters — the Russian ЙЦУКЕН position of the same keycode
  "q": "й",
  "w": "ц",
  "f": "а",
  "p": "з",
  "b": "и",
  "a": "ф",
  "r": "к",
  "s": "ы",
  "t": "е",
  "g": "п",
  "z": "я",
  "x": "ч",
  "c": "с",
  "d": "в",
  "v": "м",
  "j": "о",
  "l": "д",
  "u": "г",
  "y": "н",
  "m": "ь",
  "n": "т",
  "e": "у",
  "i": "ш",
  "o": "щ",
  "k": "л",
  "h": "р",

  // brackets and punctuation
  "[": "х",
  "]": "ъ",
  "{": "Х",
  "}": "Ъ",
  ",": "б",
  ".": "ю",
  ";": "ж",
  ":": "Ж",
  "<": "Б",
  ">": "Ю",
  "/": ".",
  "?": ",",
  "'": "э",
  "`": "ё",
  "$": ";",
  "^": ":",
  "&": "?",

  // symbols that sit elsewhere on the Russian layout
  "£": "№",
  "#": "\\",
  "¬": "Ё",
  "~": "/",
  "|": "/",
  "@": "Э",
)

// =============================================================================
//  What Shift turns each of those keycodes into. The one-handed layers carry
//  the bare keys and borrow Shift from the mouse, so the chart has to show both
//  halves — and for ten of these twelve the shifted character is itself
//  layout-dependent, so each half needs all three languages.
// =============================================================================
#let shift-legends = (
  "1": ("!", "!"),
  "2": ("\"", "\""),
  "3": ("£", "№"),
  "4": ("$", ";"),
  "5": ("%", "%"),
  "6": ("^", ":"),
  "7": ("&", "?"),
  "8": ("*", "*"),
  "9": ("(", "("),
  "0": (")", ")"),
  "`": ("¬", "Ё"),
  "-": ("_", "_"),
  "=": ("+", "+"),
  "[": ("{", "Х"),
  "]": ("}", "Ъ"),
  ";": (":", "Ж"),
  "'": ("@", "Э"),
  ",": ("<", "Б"),
  ".": (">", "Ю"),
  "/": ("?", ","),
  "#": ("~", "/"),
  "\\": ("|", "/"),
)

// =============================================================================
//  The five keycodes that type something different under English (US) than
//  under English (UK). Everything else on the board is identical between them,
//  so the US legend only appears on these — as a bare key in `us-bare`, and as
//  the character a pre-shifted keycode produces in `us-alt`.
// =============================================================================
#let us-bare = (
  // keycode -> (unshifted on US, shifted on US)
  "`": ("`", "~"), // UK gives ¬ shifted
  "2": ("2", "@"), // UK gives "
  "3": ("3", "#"), // UK gives £
  "'": ("'", "\""), // UK gives @
  "#": ("\\", "|"), // the UK # key is backslash on US
)
#let us-alt = (
  // UK legend of a pre-shifted key -> what it gives on US
  "£": "#",
  "\"": "@",
  "@": "\"",
  "¬": "~",
  "~": "|",
  "#": "\\",
)

// =============================================================================
//  Key specifications
//    ch   a character key: all three legends, looked up above
//    sk   ditto, plus what Shift gives — six legends, all the same size
//    gk   a legend with no layout variants (arrows)
//    fnk  an F-key, set smaller than a one-character legend
//    wk   worded key (HOME, ESC, ...)
//    fk   text symbol above a word
//    ik   SVG icon above a word (see icons/README.md)
//    ig   SVG icon on its own, for keys that need no caption
//    mo   momentary layer switch, tinted with the target layer's colour
//    to   permanent layer switch
//    xx   transparent: this layer does not touch the key
//    held transparent, and the key you are holding to be on this layer
// =============================================================================
#let ch(legend) = {
  let alt = alt-legends.at(legend, default: none)
  let ru = if alt == none { legend } else { alt }
  (t: "ch", uk: legend, ru: ru, us: us-alt.at(legend, default: none))
}
// a bare key whose shifted form matters: both halves, in every layout
#let sk(legend) = {
  let b = ch(legend)
  let base = (b.uk, b.ru)
  let shift = shift-legends.at(legend, default: base.map(upper))
  let us = us-bare.at(legend, default: none)
  // when US differs at all, it joins both rows so the columns stay in line
  if us != none {
    base = (base.at(0), us.at(0), base.at(1))
    shift = (shift.at(0), us.at(1), shift.at(1))
  }
  (t: "sh", base: base, shift: shift)
}
#let gk(legend, size: 0.54) = (t: "g", a: legend, size: size)
#let fnk(n) = gk([F#n], size: 0.38)
#let ik(name, word, sub: none) = (t: "i", n: name, a: word, sub: sub)
#let ig(name) = (t: "ig", n: name)
#let wk(word) = (t: "w", a: word)
#let fk(symbol, word) = (t: "f", i: symbol, a: word)
#let mo(name, color) = (t: "s", m: "MO", a: name, c: color)
#let to(name, color) = (t: "s", m: "TO", a: name, c: color)
#let xx = (t: "x")
#let held(name, color) = (t: "h", a: name, c: color) // transparent, but held to be here

// ---------- Shorthands for the keys that repeat across layers ----------
#let k-sup = ik("super", "super")
#let k-shift = ik("arrow-big-up", "shift")
#let k-ctrl = wk("ctrl")
#let k-alt = wk("alt")
#let k-ralt = wk("altgr")
#let k-bksp = ik("arrow-big-left", "bksp")
#let k-space = ik("space", "space")
#let k-tab = ik("arrow-right-to-line", "tab")
#let k-enter = ik("corner-down-left", "enter")
#let k-esc = wk("esc")
#let k-caps = ik("arrow-big-up-dash", "caps")
#let k-pgup = ik("chevrons-up", "page", sub: "up")
#let k-pgdn = ik("chevrons-down", "page", sub: "down")
#let k-home = wk("home")
#let k-end = wk("end")
#let k-del = ik("delete-forward", "del")
#let k-ins = wk("ins")
#let k-lang = ik("languages", "lang")

#let ar-l = ig("arrow-left")
#let ar-r = ig("arrow-right")
#let ar-u = ig("arrow-up")
#let ar-d = ig("arrow-down")

// =============================================================================
//  Keycap rendering
//
//  A cap is a skirt (the whole square) with a lighter face sitting on it. The
//  face is inset just enough to leave a thin lip along the bottom — a deeper
//  one reads as a drop shadow and swallows the legend. Content is centred on
//  the FACE, not on the square, so nothing ever sits over the lip.
// =============================================================================
#let FACE-X = 0.07 // face inset from the left and right
#let FACE-Y = 0.055 // face inset from the top
#let FACE-W = 0.86
#let FACE-H = 0.855 // leaves a 0.09 lip along the bottom
#let PAD = 0.03 // padding inside the face
#let INNER = FACE-W - 2 * PAD // the area a legend gets: 0.80

#let cap(s, face, skirt, edge, body, dashed: false) = box(width: s, height: s, {
  place(
    top + left,
    rect(
      width: s,
      height: s,
      radius: s * 0.15,
      fill: skirt,
      stroke: (
        paint: edge,
        thickness: if dashed { 0.45pt } else { 0.5pt },
        dash: if dashed { "densely-dotted" } else { "solid" },
      ),
    ),
  )
  if face != none {
    place(
      top + left,
      dx: s * FACE-X,
      dy: s * FACE-Y,
      rect(
        width: s * FACE-W,
        height: s * FACE-H,
        radius: s * 0.1,
        fill: gradient.linear(face.lighten(55%), face, angle: 90deg),
        stroke: none,
      ),
    )
  }
  place(
    top + left,
    dx: s * FACE-X,
    dy: s * FACE-Y,
    box(
      width: s * FACE-W,
      height: s * FACE-H,
      inset: s * PAD,
      align(center + horizon, body),
    ),
  )
})

// ---------- Inner layouts ----------
// `bounds` metrics measure the glyph's own bounding box rather than the font's
// line box, so a comma and an asterisk both end up centred in their band
// instead of sitting low and high respectively.
#let legend-text(body, ..args) = text(
  top-edge: "bounds",
  bottom-edge: "bounds",
  ..args,
  body,
)

#let body-glyph(s, legend, size: 0.54) = fit(
  legend-text([#legend], weight: 600, fill: ink),
  s * INNER * 0.95,
  s * 0.62,
  s * size,
)

// A key that types something different depending on the OS layout shows each
// version at one size, evenly spaced around the centre of the cap: UK and
// Russian side by side, or — where the US layout differs too — UK on top with
// the other two below. The size is solved for the widest so they always match
// and always stay inside the cap.
// A key that types the same everywhere — digits, most punctuation — just gets
// the one legend, as large as it will go.
#let TRI-SIZE = 0.40 // legend size, as a fraction of the key
#let TRI-ROOM = 0.36 // widest a single legend may get, ditto
#let TRI-UP = 0.195 // top legend, above the centre
#let TRI-DOWN = 0.185 // bottom legends, below the centre
#let TRI-SIDE = 0.20 // bottom legends, either side of the centre
// two legends share one row, so they have the headroom to run larger
#let PAIR-SIZE = 0.46 // legend size, as a fraction of the key
#let PAIR-ROOM = 0.38 // widest a single legend may get, ditto
#let PAIR-SIDE = 0.205 // either side of the centre

#let body-legends(s, uk, ru, us) = context {
  let ru = if ru == none { uk } else { ru }

  // only the layouts that actually say something different earn a legend: a
  // key where Russian agrees with UK but US does not gets the pair, not a
  // triangle with the same glyph printed twice
  let parts = ((uk, ink),)
  if us != none { parts.push((us, us-color)) }
  if ru != uk { parts.push((ru, ru-color)) }
  if parts.len() == 1 { return body-glyph(s, uk) }

  let pair = parts.len() == 2
  let base = s * (if pair { PAIR-SIZE } else { TRI-SIZE })
  let widest = calc.max(..parts.map(part => {
    measure(
      legend-text([#part.at(0)], size: base, weight: 700),
    ).width
  }))
  let room = s * (if pair { PAIR-ROOM } else { TRI-ROOM })
  let size = if widest > 0pt { base * calc.min(1.0, room / widest) } else { base }
  let legend(i) = legend-text(
    [#parts.at(i).at(0)],
    size: size,
    weight: 700,
    fill: parts.at(i).at(1),
  )

  box(width: s * INNER, height: s * INNER, if pair {
    place(center + horizon, dx: -s * PAIR-SIDE, legend(0))
    place(center + horizon, dx: s * PAIR-SIDE, legend(1))
  } else {
    place(center + horizon, dy: -s * TRI-UP, legend(0))
    place(center + horizon, dx: -s * TRI-SIDE, dy: s * TRI-DOWN, legend(1))
    place(center + horizon, dx: s * TRI-SIDE, dy: s * TRI-DOWN, legend(2))
  })
}

// A bare key plus its shifted form. Two rows, every glyph the same size:
// shifted on top on a tinted band, unshifted below — the way the characters sit
// on a real keycap. A row collapses to one glyph when all three layouts agree,
// which lets `-`/`_` and `=`/`+` stay large.
#let SHIFT-SIZE = 0.3 // starting legend size, as a fraction of the key

#let body-shift(s, base, shift, accent) = context {
  let spread(row) = {
    let tint = if row.len() == 3 {
      (ink, us-color, ru-color)
    } else { (ink, ru-color) }
    if row.all(g => g == row.at(0)) {
      ((row.at(0), ink),)
    } else {
      row.enumerate().map(pair => (pair.at(1), tint.at(pair.at(0))))
    }
  }
  let unshifted = spread(base)
  let shifted = spread(shift)

  let start = s * SHIFT-SIZE
  let gut = s * 0.07
  let glyph(part, size) = legend-text([#part.at(0)], size: size, weight: 700, fill: part.at(1))
  let w(part) = measure(glyph(part, start)).width

  // Columns are sized to the glyphs that actually land in them, not to the
  // widest glyph on the key. Three equal cells made a key carrying Ш or Ц
  // shrink its whole legend while a key of I and J kept full size, so the
  // letters came out different sizes from key to key.
  let n = calc.max(unshifted.len(), shifted.len())
  let wide = if unshifted.len() == n { unshifted } else { shifted }
  let thin = if unshifted.len() == n { shifted } else { unshifted }
  let cols = if thin.len() == n {
    range(n).map(i => calc.max(w(wide.at(i)), w(thin.at(i))))
  } else { wide.map(w) }

  let room = s * INNER - gut * (n - 1)
  let span = cols.sum()
  let f = if span > 0pt { calc.min(1.0, room / span) } else { 1.0 }
  let size = start * f
  let widths = cols.map(c => c * f)
  let band = s * INNER * 0.47

  // both rows share one set of column widths, so the three layouts stay in
  // line between the shifted row and the one below it
  let row(parts) = if parts.len() == n {
    stack(
      dir: ltr,
      spacing: gut,
      ..parts
        .enumerate()
        .map(pair => box(
          width: widths.at(pair.at(0)),
          height: band,
          align(center + horizon, glyph(pair.at(1), size)),
        )),
    )
  } else {
    box(width: s * INNER, height: band, align(center + horizon, glyph(parts.at(0), size)))
  }

  box(width: s * INNER, height: s * INNER, {
    place(
      top + left,
      dx: -s * PAD,
      dy: -s * PAD,
      rect(
        width: s * FACE-W,
        height: band + s * PAD,
        radius: (top: s * 0.1, bottom: 0pt),
        fill: accent.lighten(76%),
        stroke: none,
      ),
    )
    place(top + center, row(shifted))
    place(bottom + center, row(unshifted))
  })
}

#let body-word(s, word) = fit(
  legend-text([#upper(word)], weight: 700, fill: ink, tracking: 0.02em),
  s * INNER * 0.97,
  s * 0.44,
  s * 0.38,
)

#let icon(name, size) = image("icons/" + name + ".svg", height: size)

#let body-caption(s, word, h: 0.22) = box(width: s * INNER, height: s * h, align(
  center + horizon,
  fit(
    legend-text([#upper(word)], weight: 600, fill: label-ink, tracking: 0.03em),
    s * INNER,
    s * h,
    s * h,
  ),
))

// `sub` puts a second caption line under the first, for labels like PAGE / UP;
// the icon gives up a little height to pay for it
#let body-ik(s, name, word, sub) = if sub == none {
  stack(
    dir: ttb,
    spacing: s * 0.05,
    box(width: s * INNER, height: s * 0.44, align(center + horizon, icon(name, s * 0.44))),
    body-caption(s, word),
  )
} else {
  stack(
    dir: ttb,
    spacing: s * 0.025,
    box(width: s * INNER, height: s * 0.38, align(center + horizon, icon(name, s * 0.38))),
    body-caption(s, word, h: 0.19),
    body-caption(s, sub, h: 0.19),
  )
}

#let body-ig(s, name) = box(
  width: s * INNER,
  height: s * INNER,
  align(center + horizon, icon(name, s * 0.52)),
)

#let body-fk(s, symbol, word) = stack(
  dir: ttb,
  spacing: s * 0.045,
  box(width: s * INNER, height: s * 0.44, align(
    center + horizon,
    fit(legend-text([#symbol], weight: 500, fill: ink), s * 0.6, s * 0.44, s * 0.42),
  )),
  body-caption(s, word),
)

#let body-switch(s, mode, name, color) = stack(
  dir: ttb,
  spacing: s * 0.035,
  box(width: s * INNER, height: s * 0.18, align(
    center + horizon,
    fit(
      legend-text([#mode], weight: 700, fill: color.lighten(12%), tracking: 0.14em),
      s * 0.5,
      s * 0.18,
      s * 0.18,
    ),
  )),
  box(width: s * INNER, height: s * 0.34, align(
    center + horizon,
    fit(
      legend-text([#upper(name)], weight: 700, fill: color.darken(28%), tracking: 0.02em),
      s * INNER,
      s * 0.34,
      s * 0.34,
    ),
  )),
)

// ---------- Dispatch ----------
#let key(spec, s, accent) = {
  let t = spec.t

  if t == "x" {
    return cap(s, none, accent.lighten(96%), accent.lighten(72%), none, dashed: true)
  }

  if t == "h" {
    let c = spec.c
    return cap(
      s,
      none,
      c.lighten(93%),
      c.lighten(45%),
      body-switch(s, "HOLD", spec.a, c.lighten(25%)),
      dashed: true,
    )
  }

  if t == "s" {
    let c = spec.c
    return cap(
      s,
      c.lighten(84%),
      c.lighten(68%),
      c.lighten(15%),
      body-switch(s, spec.m, spec.a, c),
    )
  }

  // Modifier-ish keys sit on a slightly deeper cap than the legends.
  let deep = t == "w" or t == "f" or t == "i"
  let face = accent.lighten(if deep { 85% } else { 94% })
  let skirt = accent.lighten(if deep { 70% } else { 82% })
  let edge = accent.lighten(if deep { 30% } else { 40% })

  let body = if t == "g" { body-glyph(s, spec.a, size: spec.size) } else if t == "ch" {
    body-legends(s, spec.uk, spec.ru, spec.us)
  } else if t == "sh" { body-shift(s, spec.base, spec.shift, accent) } else if t == "w" {
    body-word(s, spec.a)
  } else if t == "i" {
    body-ik(s, spec.n, spec.a, spec.sub)
  } else if t == "ig" { body-ig(s, spec.n) } else { body-fk(s, spec.i, spec.a) }

  cap(s, face, skirt, edge, body)
}

// =============================================================================
//  Halves, layers and titles
// =============================================================================
#let half-width(s) = 6 * s + 5 * GAP

#let half(side, s, rows, thumb, accent) = {
  let row-of(cells) = grid(
    columns: (s,) * cells.len(),
    column-gutter: GAP,
    ..cells.map(c => key(c, s, accent)),
  )
  stack(
    dir: ttb,
    spacing: GAP,
    ..rows.map(row-of),
    box(width: half-width(s), align(
      if side == "left" { right } else { left },
      row-of(thumb),
    )),
  )
}

// The title strip sits exactly at the block's top-left corner, so anchoring it
// here gives the arrow pass a *measured* origin for the whole layer. The label
// is the crystal name, already unique across the ten layers.
#let layer-title(index, name, color, width) = box(width: width, height: TITLE-H, {
  place(top + left, [#metadata(name)#label(name)])
  align(left + horizon, grid(
    columns: (auto, auto),
    column-gutter: 0.16cm,
    align: horizon,
    box(
      fill: color,
      radius: 0.07cm,
      inset: (x: 0.11cm, y: 0.05cm),
      text(size: 6pt, weight: 700, fill: white, tracking: 0.04em)[#index],
    ),
    text(size: 7.5pt, weight: 700, fill: color.darken(12%), tracking: 0.12em)[#upper(name)],
  ))
})

#let pair-width = 2 * half-width(L) + HAND-GAP
#let pair-width-j = 2 * half-width(Lj) + HAND-GAP

// A full split layer: title above the two halves.
#let split-layer(index, name, accent, left-rows, left-thumb, right-rows, right-thumb, size: L) = stack(
  dir: ttb,
  spacing: TITLE-GAP,
  layer-title(index, name, accent, 2 * half-width(size) + HAND-GAP),
  stack(
    dir: ltr,
    spacing: HAND-GAP,
    half("left", size, left-rows, left-thumb, accent),
    half("right", size, right-rows, right-thumb, accent),
  ),
)

// A one-handed layer: always the left half only.
#let solo-layer(index, name, accent, rows, thumb) = stack(
  dir: ttb,
  spacing: TITLE-GAP,
  layer-title(index, name, accent, half-width(Ls)),
  half("left", Ls, rows, thumb, accent),
)

// =============================================================================
//  Page layout
//
//  Two shapes down a portrait page, each showing how its layers are reached:
//
//        0                    4
//      1   2               7  5  6
//        3                    8
//
//  Every block is a known height, so the arrows further down can be aimed by
//  arithmetic. The tier gaps are deliberately wide: that is where arrows run.
// =============================================================================
#let block-h(s) = TITLE-H + TITLE-GAP + 4 * s + 3 * GAP
#let solo-w = half-width(Ls)

// The one figure here that is a layout *input* rather than a prediction: the
// width left over beside the two middle layers, split into a lane, the gutter
// and a lane. The document body opens those lanes with `#pad(x: SIDE, ...)`.
// Every other block coordinate is measured after layout — see the arrow pass.
#let SIDE = (CONTENT-W - 2 * pair-width) / 3

#let top-centre(bx) = bx + solo-w / 2

// centre of a key, in content coordinates
#let key-at(bx, by, s, side, row, col) = (
  bx + (if side == "right" { half-width(s) + HAND-GAP } else { 0cm }) + col * (s + GAP) + s / 2,
  by + TITLE-H + TITLE-GAP + row * (s + GAP) + s / 2,
)

// =============================================================================
//  Flow arrows
//
//  Each key that changes layer gets an arrow to the layer it reaches. Routes
//  are orthogonal and run only through space that is guaranteed empty: the
//  column gap between two keys, the corridor between the two halves of a split
//  layer, and the gaps between tiers. Nothing passes under a keycap.
// =============================================================================
#let ARROW-R = 0.2 // corner radius, in cm
#let TIP-GAP = 0.16cm // stop this far above the target block
#let ARROW-W = 1.5pt
#let RUN-UP = 0.62cm // straight run before a tip, so the head is never cramped
#let DOT-R = 0.085 // the blob marking where an arrow leaves its key, in cm

// an arrow leaves from the middle of one of the key's four edges, never from
// the middle of the cap, so you can see which way it sets off
#let key-edge(bx, by, s, side, row, col, dir) = {
  let c = key-at(bx, by, s, side, row, col)
  if dir == "right" { (c.at(0) + s / 2, c.at(1)) } else if dir == "left" {
    (c.at(0) - s / 2, c.at(1))
  } else if dir == "top" { (c.at(0), c.at(1) - s / 2) } else {
    (c.at(0), c.at(1) + s / 2)
  }
}

// the vertical lane between column `col` and the next one
#let col-gap(bx, s, side, col) = (
  bx + (if side == "right" { half-width(s) + HAND-GAP } else { 0cm }) + (col + 1) * (s + GAP) - GAP / 2
)
#let badge-x(bx) = bx + 0.24cm

// key -> out through a column gap -> along a tier gap -> down onto the badge
#let route-top(src, gx, lane, tx, by) = (
  src,
  (gx, src.at(1)),
  (gx, lane),
  (tx, lane),
  (tx, by - TIP-GAP),
)
#let route(src, gx, lane, bx, by) = route-top(src, gx, lane, badge-x(bx), by)

// right edge of a block, at the vertical middle of its keys
#let right-entry(bx, w) = bx + w + TIP-GAP
#let left-entry(bx) = bx - TIP-GAP
#let block-bottom(by, s) = by + block-h(s)
#let keys-top(by) = by + TITLE-H + TITLE-GAP // below the title strip

// in along a tier gap, then down beside the block and into its left edge
#let route-side(src, gx, lane, turn, ty, bx) = (
  src,
  (gx, src.at(1)),
  (gx, lane),
  (turn, lane),
  (turn, ty),
  (bx - TIP-GAP, ty),
)

// vertical middle of a block's keys, for a side entry
#let side-entry(by, s) = by + TITLE-H + TITLE-GAP + (4 * s + 3 * GAP) / 2

// ---------- rounded orthogonal polylines ----------
#let vsub(a, b) = (a.at(0) - b.at(0), a.at(1) - b.at(1))
#let vlen(v) = calc.sqrt(v.at(0) * v.at(0) + v.at(1) * v.at(1))
#let vstep(from, to, d) = {
  let v = vsub(to, from)
  let l = vlen(v)
  if l == 0 { from } else { (from.at(0) + v.at(0) / l * d, from.at(1) + v.at(1) / l * d) }
}



// A zero-size mark at the content origin. Every queried position is taken
// relative to this, so the page margin never enters the arrow maths.
#place(top + left, [#metadata("origin")#label("origin")])

// ---- how to read a key, in the dead space left of the top layer ------------
#let swatch(body) = box(width: 0.42cm, height: 0.26cm, baseline: 0.07cm, body)

// Legend - explains how to read keys
#place(top + left, dx: 0.5cm, dy: 0.38cm, block(width: 4.4cm, grid(
  columns: (auto, auto),
  column-gutter: 0.24cm,
  row-gutter: 0.12cm,
  align: horizon,

  legend-text(size: 7pt, weight: 700)[#text(fill: ink)[q]#h(0.1cm)#text(fill: ru-color)[й]],
  text(size: 5.8pt, fill: label-ink)[#text(fill: ink, weight: 700)[UK] · #text(fill: ru-color, weight: 700)[Russian]],

  legend-text(size: 7pt, weight: 700)[#text(fill: ink)[£]#h(0.1cm)#text(fill: us-color)[\#]],
  text(size: 5.8pt, fill: label-ink)[#text(fill: us-color, weight: 700)[US], on the 11 keys it differs],

  swatch(rect(width: 100%, height: 100%, radius: (top: 0.05cm, bottom: 0pt), fill: rgb("#d8dade"), stroke: none)),
  text(size: 5.8pt, fill: label-ink)[tinted row: what #text(fill: ink, weight: 700)[Shift] gives],

  swatch(rect(width: 100%, height: 100%, radius: 0.05cm, fill: none, stroke: (
    paint: rgb("#b9bdc4"),
    thickness: 0.45pt,
    dash: "densely-dotted",
  ))),
  text(size: 5.8pt, fill: label-ink)[dotted: unchanged from below],
)))

// ---- the diamond -----------------------------------------------------------
#align(center, split-layer(
  size: Lj,
  1,
  "jade",
  c-jade,
  (
    (k-ralt, sk("q"), sk("w"), sk("f"), sk("p"), sk("b")),
    (sk("a"), mo("topaz", c-topaz), sk("r"), sk("s"), sk("t"), sk("g")),
    (sk("z"), k-esc, sk("x"), sk("c"), sk("d"), sk("v")),
  ),
  (k-sup, k-shift, k-bksp),
  (
    (sk("j"), sk("l"), sk("u"), sk("y"), ar-d, k-ralt),
    (sk("m"), sk("n"), sk("e"), sk("i"), mo("opal", c-opal), sk("o")),
    (sk("k"), sk("h"), ar-l, ar-r, k-enter, ar-u),
  ),
  (k-space, k-ctrl, k-alt),
))

#v(JADE-GAP)

// pad(x: SIDE) is what actually opens the lanes the x-topaz / x-opal maths assumes
#pad(x: SIDE, grid(
  columns: (auto, 1fr, auto),
  split-layer(
    2,
    "topaz",
    c-topaz,
    (
      (xx, ch("¬"), mo("ruby", c-ruby), ch("`"), ch("!"), ch("~")),
      (
        xx,
        held("topaz", c-topaz),
        ik("wheel-down", "wheel", sub: "down"),
        ik("wheel-up", "wheel", sub: "up"),
        ik("mouse-left", "click", sub: "left"),
        ik("mouse-middle", "click", sub: "middle"),
      ),
      (xx, xx, ch("<"), ch("$"), ch("/"), ch("^")),
    ),
    (ch("\\"), k-shift, ik("wheel-left", "wheel", sub: "left")),
    (
      (ch("_"), ch("?"), ch("'"), ch("|"), ik("play", "play"), ik("skip-back", "prev")),
      (
        k-tab,
        ik("move-left", "mouse", sub: "left"),
        ik("move-up", "mouse", sub: "up"),
        ik("move-down", "mouse", sub: "down"),
        ik("move-right", "mouse", sub: "right"),
        ch("*"),
      ),
      (ik("mouse-right", "click", sub: "right"), ch("\""), k-home, k-end, ch("@"), ik("skip-forward", "next")),
    ),
    (ik("wheel-right", "wheel", sub: "right"), k-ctrl, k-alt),
  ),
  [],
  split-layer(
    3,
    "opal",
    c-opal,
    (
      (to("beryl", c-beryl), ch("£"), ch("9"), ch("5"), ch("0"), ch("3")),
      (ch("&"), ch("["), ch("("), ch("{"), ch(":"), ch("7")),
      (k-lang, ch("]"), ch("+"), ch("-"), ch("#"), ch("}")),
    ),
    (k-caps, k-shift, k-pgdn),
    (
      (ch("2"), ch("1"), ch("4"), ch("8"), xx, xx),
      (ch("6"), ch("="), ch(","), ch("."), held("opal", c-opal), xx),
      (ch(")"), ch("%"), ch(";"), ch(">"), xx, xx),
    ),
    (k-pgup, k-ctrl, k-alt),
  ),
))

#v(TIER-GAP)

#align(center, split-layer(
  4,
  "ruby",
  c-ruby,
  (
    (xx, xx, held("ruby", c-ruby), ik("bluetooth-off", "bt clr"), fk([1], "bt"), fk([2], "bt")),
    (xx, held("topaz", c-topaz), xx, ik("arrow-right", "bt next"), ik("usb", "bt usb"), fk([3], "bt")),
    (xx, xx, xx, ik("arrow-left", "bt prev"), fk([5], "bt"), fk([4], "bt")),
  ),
  (k-sup, k-shift, k-ctrl),
  (
    (fnk(1), fnk(2), fnk(3), fnk(4), fnk(5), fnk(6)),
    (fnk(7), fnk(8), fnk(9), fnk(10), fnk(11), fnk(12)),
    (
      ik("volume-x", "mute"),
      ik("volume-1", "vol −"),
      ik("volume-2", "vol +"),
      ik("sun", "bright +"),
      ik("sun-dim", "bright −"),
      ik("camera", "prt sc"),
    ),
  ),
  (k-sup, k-ctrl, k-alt),
))

// Everything below the bar is the left half of the board on its own.
#let DIVIDER-H = 0.32cm
#let hairline = line(length: 100%, stroke: 0.6pt + rgb("#c9ccd2"))

#v((SECTION-GAP - DIVIDER-H) / 2)

// the label sits out in the white margin on the left, indented just enough to
// clear the return arrow climbing the side lane
#box(width: 100%, height: DIVIDER-H, align(horizon, pad(left: 0.55cm, grid(
  columns: (auto, 1fr),
  column-gutter: 0.3cm,
  align: horizon,
  text(size: 6.8pt, weight: 700, fill: label-ink, tracking: 0.14em)[ONE-HANDED · LEFT HALF ONLY], hairline,
))))

#v((SECTION-GAP - DIVIDER-H) / 2)

// ---- the fountain ----------------------------------------------------------
#align(center, solo-layer(
  5,
  "beryl",
  c-beryl,
  (
    (to("jade", c-jade), sk("q"), sk("w"), sk("f"), sk("p"), sk("b")),
    (sk("a"), k-enter, sk("r"), sk("s"), sk("t"), sk("g")),
    (sk("z"), k-esc, sk("x"), sk("c"), sk("d"), sk("v")),
  ),
  (mo("amber", c-amber), mo("balas", c-balas), mo("lapis", c-lapis)),
))

#v(TIER-GAP)

#align(center, grid(
  columns: (auto, auto, auto),
  column-gutter: SOLO-GAP,
  solo-layer(
    6,
    "amber",
    c-amber,
    (
      (ik("play", "play"), sk("`"), sk("8"), sk("4"), sk("1"), sk("2")),
      (k-home, mo("onyx", c-onyx), sk("\\"), sk("["), sk("]"), sk("6")),
      (k-end, sk("#"), sk(","), sk("="), sk("."), k-lang),
    ),
    (held("amber", c-amber), xx, xx),
  ),
  solo-layer(
    7,
    "balas",
    c-balas,
    (
      (ik("volume-2", "vol +"), sk("/"), sk("9"), sk("5"), sk("0"), sk("3")),
      (ik("volume-1", "vol −"), mo("prase", c-prase), sk("-"), sk(";"), sk("'"), sk("7")),
      (ik("volume-x", "mute"), ar-l, ar-d, ar-u, ar-r, ik("camera", "prt sc")),
    ),
    (xx, held("balas", c-balas), xx),
  ),
  solo-layer(
    8,
    "lapis",
    c-lapis,
    (
      (k-del, k-ins, sk("y"), sk("u"), sk("l"), sk("j")),
      (sk("o"), k-bksp, sk("i"), sk("e"), sk("n"), sk("m")),
      (k-tab, k-space, k-pgdn, k-pgup, sk("k"), sk("h")),
    ),
    (xx, xx, held("lapis", c-lapis)),
  ),
))

#v(TIER-GAP)

#align(center, grid(
  columns: (auto, auto),
  column-gutter: SOLO-GAP,
  solo-layer(
    9,
    "onyx",
    c-onyx,
    (
      (xx, xx, fnk(7), fnk(8), fnk(9), xx),
      (xx, held("onyx", c-onyx), fnk(10), fnk(11), fnk(12), xx),
      (xx, xx, xx, ik("sun-dim", "bright −"), ik("sun", "bright +"), xx),
    ),
    (held("amber", c-amber), xx, xx),
  ),
  solo-layer(
    10,
    "prase",
    c-prase,
    (
      (xx, xx, fnk(1), fnk(2), fnk(3), xx),
      (xx, held("prase", c-prase), fnk(4), fnk(5), fnk(6), xx),
      (xx, xx, k-caps, ik("skip-back", "prev"), ik("skip-forward", "next"), xx),
    ),
    (xx, held("balas", c-balas), xx),
  ),
))

// =============================================================================
//  Arrow pass
//
//  Runs inside `context`, after layout, so every block coordinate below is
//  QUERIED rather than predicted. `layer-title` drops a labelled mark at each
//  block's top-left corner, and `origin` marks the content origin. Nothing
//  here can drift out of step with the `#v()` spacers in the body above.
//
//  Within a block, key positions are still arithmetic — but from the same
//  `s` / `GAP` / `TITLE-H` the grid itself uses, so they cannot disagree.
//
//  Drawn last so the arrows sit on top; their routes keep them off the keys.
// =============================================================================
#context {
  let pos(n) = query(label(n)).first().location().position()
  let o = pos("origin")
  let at(n) = { let q = pos(n); (q.x - o.x, q.y - o.y) }
  let bx(n) = at(n).at(0)
  let by(n) = at(n).at(1)

  // blocks sharing a tier share a y: the grid guarantees it, the assert says so
  assert(by("topaz") == by("opal"), message: "topaz/opal no longer share a tier")
  assert(by("amber") == by("balas") and by("amber") == by("lapis"), message: "fountain tier split")
  assert(by("onyx") == by("prase"), message: "bottom tier split")

  let tier-row1 = by("jade")
  let tier-row2 = by("topaz")
  let tier-row3 = by("ruby")
  let tier-row4 = by("beryl")
  let tier-row5 = by("amber")
  let tier-row6 = by("onyx")

  let x-jade = bx("jade")
  let x-topaz = bx("topaz")
  let x-opal = bx("opal")
  let x-ruby = bx("ruby")
  let x-beryl = bx("beryl")
  let x-amber = bx("amber")
  let x-balas = bx("balas")
  let x-lapis = bx("lapis")
  let x-onyx = bx("onyx")
  let x-prase = bx("prase")

  let arrows = (
    (
      // MO MOUSE is on the left hand, so the mouse layer sits on the left
      color: c-topaz,
      pts: route(
        key-edge(x-jade, tier-row1, Lj, "left", 1, 1, "left"),
        col-gap(x-jade, Lj, "left", 0),
        tier-row2 - 0.8cm,
        x-topaz,
        tier-row2,
      ),
    ),
    (
      // MO NUM is on the right hand, so the num layer sits on the right
      color: c-opal,
      pts: route-top(
        key-edge(x-jade, tier-row1, Lj, "right", 1, 4, "right"),
        col-gap(x-jade, Lj, "right", 4),
        tier-row2 - 0.8cm,
        x-opal + 0.75 * pair-width,
        keys-top(tier-row2),
      ),
    ),
    (
      // MO FN drops its own lane and comes in at the fn layer's left edge
      color: c-ruby,
      pts: {
        let src = key-edge(x-topaz, tier-row2, L, "left", 0, 2, "left")
        let gx = col-gap(x-topaz, L, "left", 1)
        let ty = side-entry(tier-row3, L)
        (src, (gx, src.at(1)), (gx, ty), (left-entry(x-ruby), ty))
      },
    ),
    (
      // TO(1H) lives on the num layer; it comes in at 1H base's right edge
      color: c-beryl,
      pts: {
        let src = key-edge(x-opal, tier-row2, L, "left", 0, 0, "right")
        let ty = side-entry(tier-row4, Ls)
        let down = x-ruby + pair-width + 0.55cm
        (
          src,
          (col-gap(x-opal, L, "left", 0), src.at(1)),
          (col-gap(x-opal, L, "left", 0), tier-row3 - 0.5cm),
          (down, tier-row3 - 0.5cm),
          (down, ty),
          (right-entry(x-beryl, solo-w), ty),
        )
      },
    ),
    (
      // The three thumbs drop most of the tier gap before turning, so the run
      // across sits just above the layer it points at, and each tip comes to
      // rest on the first row of keys rather than up on the title.
      color: c-amber,
      pts: {
        let src = key-edge(x-beryl, tier-row4, Ls, "left", 3, 3, "bottom")
        let tx = top-centre(x-amber)
        (src, (src.at(0), tier-row5 - 0.3cm), (tx, tier-row5 - 0.3cm), (tx, keys-top(tier-row5) - TIP-GAP))
      },
    ),
    (
      // beryl sits directly above balas, so this one is a straight drop
      color: c-balas,
      pts: {
        let src = key-edge(x-beryl, tier-row4, Ls, "left", 3, 4, "bottom")
        (src, (src.at(0), keys-top(tier-row5) - TIP-GAP))
      },
    ),
    (
      color: c-lapis,
      pts: {
        let src = key-edge(x-beryl, tier-row4, Ls, "left", 3, 5, "bottom")
        let tx = top-centre(x-lapis)
        (src, (src.at(0), tier-row5 - 0.3cm), (tx, tier-row5 - 0.3cm), (tx, keys-top(tier-row5) - TIP-GAP))
      },
    ),
    (
      // each half of the F-keys hangs off its own num layer; onyx is entered
      // from the side, since the lane down amber's edge arrives there anyway
      color: c-onyx,
      pts: {
        let src = key-edge(x-amber, tier-row5, Ls, "left", 1, 1, "right")
        let gx = col-gap(x-amber, Ls, "left", 1)
        let ty = side-entry(tier-row6, Ls)
        (src, (gx, src.at(1)), (gx, ty), (left-entry(x-onyx), ty))
      },
    ),
    (
      color: c-prase,
      pts: route-top(
        key-edge(x-balas, tier-row5, Ls, "left", 1, 1, "right"),
        col-gap(x-balas, Ls, "left", 1),
        tier-row6 - 0.42cm,
        top-centre(x-prase),
        keys-top(tier-row6),
      ),
    ),
    (
      // back to base: out to the left lane, up the outside, into layer 0
      color: c-jade,
      pts: {
        let src = key-edge(x-beryl, tier-row4, Ls, "left", 0, 0, "left")
        let lane = SIDE / 2
        let ty = side-entry(tier-row1, Lj)
        (src, (lane, src.at(1)), (lane, ty), (left-entry(x-jade), ty))
      },
    ),
  )

  place(top + left, cetz.canvas(length: 1cm, {
    import cetz.draw: *
    rect((0, 0), (CONTENT-W / 1cm, -CONTENT-H / 1cm), stroke: none)
    for a in arrows {
      let st = (paint: a.color, thickness: ARROW-W, cap: "round", join: "round")
      let raw = a.pts.map(q => (q.at(0) / 1cm, -q.at(1) / 1cm))
      // a route may fold back on itself when a key edge already sits in the lane
      let pts = raw.fold((), (acc, q) => {
        if acc.len() > 0 and vlen(vsub(q, acc.last())) < 0.004 { acc } else { acc + (q,) }
      })
      circle(pts.at(0), radius: DOT-R, fill: a.color, stroke: none)
      let n = pts.len()
      let cur = pts.at(0)
      for i in range(1, n - 1) {
        let q = pts.at(i)
        let rr = calc.min(
          ARROW-R,
          vlen(vsub(q, pts.at(i - 1))) / 2,
          vlen(vsub(pts.at(i + 1), q)) / 2,
        )
        let a1 = vstep(q, pts.at(i - 1), rr)
        let b1 = vstep(q, pts.at(i + 1), rr)
        if vlen(vsub(a1, cur)) > 0.005 { line(cur, a1, stroke: st) }
        bezier(a1, b1, q, stroke: st)
        cur = b1
      }
      line(
        cur,
        pts.at(n - 1),
        stroke: st,
        mark: (end: "stealth", fill: a.color, stroke: none, length: 0.26, width: 0.26, inset: 0.07),
      )
    }
  }))
}
