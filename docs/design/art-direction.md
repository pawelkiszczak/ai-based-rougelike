# Art direction

## Visual identity

Emergence Protocol uses a dark observability-console style: quiet navy surfaces, thin blue structure lines, and restrained cyan/green/gold signals. The interface should feel like a machine inspection tool that has become a place of memory.

Use crisp vector or pixel-shaped forms with no gradients in gameplay-critical icons. Shapes carry meaning first; color reinforces it. Every threat state has a shape or label in addition to color.

## Palette

| Token | Hex | Use |
|---|---|---|
| `bg` | `#09111F` | Page and world background |
| `panel` | `#111D31` | Primary panels and cards |
| `panel_alt` | `#172741` | Focused cards and controls |
| `line` | `#294363` | Borders, dividers, inactive structure |
| `text` | `#E8F0FF` | Primary readable text |
| `muted` | `#8DA2C1` | Secondary text and explanations |
| `cyan` | `#70E1FF` | Adaptation, focus, interactive emphasis |
| `green` | `#8FF0BD` | Integrity, success, safe outcomes |
| `red` | `#FF8E9E` | Damage, failure, destructive actions |
| `gold` | `#FFD477` | Alignment, warnings, rare decisions |

No asset may introduce a color outside this list without an explicit art-direction review.

## Resolution and scaling

- Logical viewport: **640×360**.
- Default desktop window: **1280×720**, exactly 2× logical scale.
- Scale by integer multiples only; preserve aspect ratio and pillarbox non-matching windows.
- Disable texture filtering for pixel-shaped assets; do not blur icons during scaling.
- Minimum gameplay-critical text is 16 logical pixels at the reference viewport.
- Reference assets live at their logical dimensions or an integer divisor/multiple of them.

## Renderer

Use Godot's **Compatibility renderer (OpenGL)** for this 2D, UI-heavy game. The game has no renderer-dependent effects; broad hardware support is more valuable than advanced 3D features. Visual effects must have a flat-color fallback.

## Asset rules

- Prefer geometric silhouettes, 1–3 logical-pixel structure lines, and deliberate negative space.
- Keep mutation icons recognizable at 16×16 logical pixels.
- Use shape, label, and position in addition to color for threat/state communication.
- Avoid decorative animation until the static state is legible.
- Name assets by stable content id, not display text.
- Reference samples: `docs/design/samples/emergence-sprite.svg` and `docs/design/samples/ui-panel.svg`.
