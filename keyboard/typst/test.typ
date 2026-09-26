#import "@preview/cetz:0.5.2"

#set page(paper: "a4", flipped: true, margin: 0.3cm)
#set text(size: 8pt)

// ---------- One unique color per layer — no reuse ----------
#let c0 = rgb("#2f7d5b") // Layer 0 — Base
#let c1 = rgb("#7c3f8c") // Layer 1 — Numbers / Symbols
#let c2 = rgb("#3a6ea5") // Layer 2 — Mouse / Media
#let c3 = rgb("#a02c2c") // Layer 3 — Function / Bluetooth
#let c4 = rgb("#1a8a8a") // 1H Base
#let c5 = rgb("#b8860b") // 1H Navigation / Symbols
#let c6 = rgb("#c2185b") // 1H Numbers
#let c7 = rgb("#8d6e42") // 1H Function
#let c8 = rgb("#5c6bc0") // 1H Editing / Brackets

#let ru-color = rgb("#1a5fb4")
#let ro-color = rgb("#c64600")

#let sw(label, color) = (is_switch: true, label: label, color: color)

#let k3(uk, ru, ro) = box(width: 0.88cm, height: 0.88cm)[
  #grid(
    rows: (1fr, 1fr),
    row-gutter: 0pt,
    align(center + horizon, text(size: 9.5pt, weight: "bold")[#uk]),
    grid(
      columns: (1fr, 1fr),
      align(center + horizon, text(size: 7.5pt, weight: "bold", fill: ru-color)[#ru]),
      align(center + horizon, text(size: 7.5pt, weight: "bold", fill: ro-color)[#ro]),
    ),
  )
]

#let U = 0.95 // cm per grid unit

#let diagram = {
  set text(size: 10pt)

  cetz.canvas(length: U * 1cm, {
    import cetz.draw: *

    let kb_side(ox, oy, side, rows, thumb, accent) = {
      let is_left_half = side == "left"
      let key_fill = accent.lighten(85%)
      let key_stroke = accent.lighten(35%)

      let draw_cell = (x0, y0, item) => {
        let fill = key_fill
        let stroke = key_stroke
        let disp = item
        if type(item) == dictionary and item.at("is_switch", default: false) {
          fill = item.color.lighten(85%)
          stroke = item.color.lighten(35%)
          disp = item.label
        }
        rect((ox + x0, oy + y0), (ox + x0 + 1, oy + y0 + 1), radius: 0.12, fill: fill, stroke: 0.55pt + stroke)
        content((ox + x0 + 0.5, oy + y0 + 0.5))[#disp]
      }

      for (row_index, row) in rows.enumerate() {
        let y0 = 3 - row_index
        for (column_index, item) in row.enumerate() {
          draw_cell(column_index, y0, item)
        }
      }

      let thumb_row_start = if is_left_half { 3 } else { 0 }
      for (i, item) in thumb.enumerate() {
        draw_cell(thumb_row_start + i, 0, item)
      }
    }

    let kb_pair(ox, oy, rows_l, thumb_l, rows_r, thumb_r, accent) = {
      kb_side(ox, oy, "left", rows_l, thumb_l, accent)
      kb_side(ox + 7, oy, "right", rows_r, thumb_r, accent)
    }

    // Multi-point routed arrow — travels only through corridor waypoints, never over key interiors.
    let route(pts, color) = {
      line(..pts, stroke: color + 1.1pt, mark: (end: ">", fill: color))
    }

    // ================= Layout origins (unit coordinates) — tightened gaps =================
    let ox_c1 = 0
    let ox_c2 = 15
    let oy_r1 = 9
    let oy_r2 = 4

    let ox_1h1 = 4
    let ox_1h2 = 11
    let ox_1h3 = 18
    let oy_1hA = -1

    let ox_1h4 = 7.5
    let ox_1h5 = 14.5
    let oy_1hB = -6

    // ================= Layer 0 — Base =================
    kb_pair(
      ox_c1,
      oy_r1,
      (
        (
          [#text(size: 0.5cm)[RAlt]],
          k3("q", "й", "q"),
          k3("w", "ц", "w"),
          k3("f", "а", "f"),
          k3("p", "з", "p"),
          k3("b", "и", "b"),
        ),
        (
          k3("a", "ф", "a"),
          sw([#text(size: 0.4cm)[MO(2)]], c2),
          k3("r", "к", "r"),
          k3("s", "ы", "s"),
          k3("t", "е", "t"),
          k3("g", "п", "g"),
        ),
        (k3("z", "я", "z"), [Esc], k3("x", "ч", "x"), k3("c", "с", "c"), k3("d", "в", "d"), k3("v", "м", "v")),
      ),
      ([#emoji.window], [#sym.arrow.t.bar], [#sym.arrow.l.bar]),
      (
        (
          k3("j", "о", "j"),
          k3("l", "д", "l"),
          k3("u", "г", "u"),
          k3("y", "н", "y"),
          [#sym.arrow.b],
          [#text(size: 0.5cm)[RAlt]],
        ),
        (
          k3("m", "ь", "m"),
          k3("n", "т", "n"),
          k3("e", "у", "e"),
          k3("i", "ш", "i"),
          sw([#text(size: 0.4cm)[MO(1)]], c1),
          k3("o", "щ", "o"),
        ),
        (k3("k", "л", "k"), k3("h", "р", "h"), [#sym.arrow.l], [#sym.arrow.r], [#sym.arrow.l.curve], [#sym.arrow.t]),
      ),
      ([s], [t], [u]),
      c0,
    )

    // ================= Layer 1 — Numbers / Symbols =================
    kb_pair(
      ox_c2,
      oy_r1,
      (
        (sw([#text(size: 0.32cm)[TO(1H)]], c4), k3("£", "№", "#"), [9], [5], [0], [3]),
        (k3("&", "?", "&"), k3("[", "х", "["), [(], k3("{", "Х", "{"), k3(":", "Ж", ":"), [7]),
        ([#text(size: 0.4cm)[Lang]], k3("]", "ъ", "]"), [+], [-], k3("#", "\\", "#"), k3("}", "Ъ", "}")),
      ),
      ([Caps], [#text(size: 0.45cm)[Shift]], [#text(size: 0.3cm)[PgDn]]),
      (
        ([2], [1], [4], [8], [], []),
        ([6], [=], k3(",", "б", ","), k3(".", "ю", "."), [], []),
        ([)], [%], k3(";", "ж", ";"), k3(">", "Ю", ">"), [], []),
      ),
      ([#text(size: 0.3cm)[PgUp]], [#text(size: 0.45cm)[Ctrl]], [#text(size: 0.45cm)[Alt]]),
      c1,
    )

    // ================= Layer 2 — Mouse / Media =================
    kb_pair(
      ox_c1,
      oy_r2,
      (
        ([], k3("¬", "Ё", "~"), sw([#text(size: 0.4cm)[MO(3)]], c3), k3("`", "ё", "`"), [!], k3("~", "/", "|")),
        (
          [],
          [],
          [#text(size: 0.22cm)[WheelDn]],
          [#text(size: 0.22cm)[WheelUp]],
          [#text(size: 0.25cm)[LClk]],
          [#text(size: 0.25cm)[MClk]],
        ),
        ([], [], k3("<", "Б", "<"), k3("$", ";", "$"), k3("/", ".", "/"), k3("^", ":", "^")),
      ),
      ([\\], [#text(size: 0.45cm)[Shift]], [#text(size: 0.22cm)[WheelL]]),
      (
        (
          [\_],
          k3("?", ",", "?"),
          k3("'", "э", "'"),
          k3("|", "/", "|"),
          [#text(size: 0.25cm)[Play]],
          [#text(size: 0.25cm)[Prev]],
        ),
        (
          [Tab],
          [#text(size: 0.45cm)[M#sym.arrow.l]],
          [#text(size: 0.45cm)[M#sym.arrow.t]],
          [#text(size: 0.45cm)[M#sym.arrow.b]],
          [#text(size: 0.45cm)[M#sym.arrow.r]],
          [\*],
        ),
        (
          [#text(size: 0.25cm)[RClk]],
          k3("\"", "\"", "@"),
          [Home],
          [End],
          k3("@", "Э", "\""),
          [#text(size: 0.25cm)[Next]],
        ),
      ),
      ([#text(size: 0.22cm)[WheelR]], [#text(size: 0.45cm)[Ctrl]], [#text(size: 0.45cm)[Alt]]),
      c2,
    )

    // ================= Layer 3 — Function / Bluetooth =================
    kb_pair(
      ox_c2,
      oy_r2,
      (
        ([], [], [], [#text(size: 0.22cm)[BTclr]], [BT1], [BT2]),
        ([], [], [], [#text(size: 0.3cm)[BT#sym.arrow.r]], [#text(size: 0.25cm)[BTusb]], [BT3]),
        ([], [], [], [#text(size: 0.3cm)[BT#sym.arrow.l]], [BT5], [BT4]),
      ),
      ([Gui], [#text(size: 0.45cm)[Shift]], [#text(size: 0.45cm)[Ctrl]]),
      (
        ([F1], [F2], [F3], [F4], [F5], [F6]),
        ([F7], [F8], [F9], [F10], [F11], [F12]),
        (
          [#text(size: 0.25cm)[Mute]],
          [#text(size: 0.25cm)[Vol-]],
          [#text(size: 0.25cm)[Vol+]],
          [#text(size: 0.25cm)[Br+]],
          [#text(size: 0.25cm)[Br-]],
          [#text(size: 0.22cm)[PrtSc]],
        ),
      ),
      ([Gui], [#text(size: 0.45cm)[Ctrl]], [#text(size: 0.45cm)[Alt]]),
      c3,
    )

    // ================= One-handed layers =================
    kb_side(
      ox_1h1,
      oy_1hA,
      "left",
      (
        (sw([#text(size: 0.4cm)[TO(0)]], c0), [q], [w], [f], [p], [b]),
        ([a], [#text(size: 0.4cm)[Enter]], [r], [s], [t], [g]),
        ([z], [Esc], [x], [c], [d], [v]),
      ),
      (
        sw([#text(size: 0.35cm)[MO(4)]], c7),
        sw([#text(size: 0.35cm)[MO(2)]], c5),
        sw([#text(size: 0.35cm)[MO(3)]], c6),
      ),
      c4,
    )

    kb_side(
      ox_1h2,
      oy_1hA,
      "left",
      (
        ([Tab], [#"`"], [y], [u], [l], [j]),
        ([o], [#text(size: 0.5cm)[Space]], [i], [e], [n], [m]),
        ([#"!"], [#"("], [#")"], [#text(size: 0.4cm)[BkSp]], [k], [h]),
      ),
      ([], [], []),
      c5,
    )

    kb_side(
      ox_1h3,
      oy_1hA,
      "left",
      (
        ([#"="], [1], [2], [3], [4], [5]),
        ([6], sw([#text(size: 0.35cm)[MO(5)]], c8), [7], [8], [9], [0]),
        ([-], [#"+"], [#text(size: 0.35cm)[PgDn]], [#text(size: 0.35cm)[PgUp]], [Home], [End]),
      ),
      ([], [], []),
      c6,
    )

    kb_side(
      ox_1h4,
      oy_1hB,
      "left",
      (
        ([F1], [F2], [F3], [F4], [F5], [F6]),
        ([F7], [F8], [F9], [F10], [F11], [F12]),
        ([.], [#sym.arrow.l], [#sym.arrow.b], [#sym.arrow.t], [#sym.arrow.r], [#","]),
      ),
      ([], [], []),
      c7,
    )

    kb_side(
      ox_1h5,
      oy_1hB,
      "left",
      (
        ([], [], [#"'"], [\[], [\]], [#";"]),
        ([], [], [#"\\"], [#"<"], [#">"], [#"/"]),
        ([], [], [Del], [#"{"], [#"}"], [Ins]),
      ),
      ([], [], []),
      c8,
    )

    // ================= Connector arrows — routed through corridors, never over key faces =================
    route(((1.5, 11.5), (1.5, 11), (1, 11), (1, 8.5), (2, 8.5), (2, 8)), c2) // L0 MO(2) -> L2 Mouse
    route(((11.5, 11.5), (11.5, 11), (15, 11)), c1) // L0 MO(1) -> L1 Numbers
    route(((15.5, 13), (15.5, 13.6), (-1.3, 13.6), (-1.3, 3.6), (4.5, 3.6), (4.5, 3)), c4) // L1 TO(1H) -> 1H Base
    route(((2.5, 8), (2.5, 8.5), (20, 8.5), (20, 8)), c3) // L2 MO(3) -> L3 Function
    route(((4.5, 3), (4.5, 3.4), (-0.7, 3.4), (-0.7, 13.4), (6.5, 13.4), (6.5, 13)), c0) // 1H Base TO(0) -> L0
    route(((7.5, -0.5), (7.5, -1), (7.5, -2)), c7) // 1H Base MO(4) -> 1H Function
    route(((8.5, -0.5), (8.5, -1), (8.5, -1.3), (14, -1.3), (14, -1)), c5) // 1H Base MO(2) -> 1H Navigation
    route(((9.5, -0.5), (9.5, -1), (9.5, -1.5), (21, -1.5), (21, -1)), c6) // 1H Base MO(3) -> 1H Numbers
    route(((19.5, 1.5), (19.5, 1), (19, 1), (19, -1), (19, -1.7), (17, -1.7), (17, -2)), c8) // 1H Numbers MO(5) -> 1H Editing
  })
}

#align(center, diagram)
