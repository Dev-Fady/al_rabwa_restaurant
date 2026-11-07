---
trigger: always_on
---

# Flutter UI Rules

- Every screen/component MUST be responsive, adaptive, accessible, RTL-compatible, and localization-ready. Figma is a visual reference, not a device size; support real devices/windows, content, languages, text scale, keyboards, and accessibility.

- Do not build for one size/copy artboard dimensions or use device-size values (for example `390×844`) unless genuinely required. Support applicable widths from ~320 to 1280+ and adapt behavior, not uniform scaling. Support dynamic/API/user content.

- Reuse existing design system, spacing, typography, colors, components, helpers, breakpoints, localization, and accessibility utilities; do not duplicate patterns.

- Use `LayoutBuilder` for component/parent constraints and `MediaQuery.sizeOf(context)` for screen/window decisions such as navigation, breakpoints, orientation, and full-screen layout. Use requirement-based breakpoints, never exact device-width checks.

- Prefer `Expanded`, `Flexible`, `ConstrainedBox`, `FractionallySizedBox`, `Wrap`, `ListView`, `GridView`, `SliverGrid`, `CustomScrollView`, and `AspectRatio` when appropriate; avoid unnecessary fixed width/height.

- Adapt structure: mobile favors single-column/stacked layouts; tablet may use two columns, navigation rail, or side-by-side sections; desktop may use sidebar/rail, multi-column layouts, max-width, and centered content. Use existing design-system max-width values when available.

- Text MUST NOT overflow, clip, hide content, or make UI unusable. Use flexible/wrapping/maxLines/overflow appropriately; NEVER blindly reduce font size to hide overflow. Do not unnecessarily truncate errors, instructions, validation, legal, or other critical content.

- NEVER globally disable/clamp text scaling. Avoid fixed heights around dynamic text; use content-driven sizing. Buttons MUST grow for long/localized labels. Do not assume English and Arabic strings have equal length.

- Make content scroll when needed for small screens, landscape, large text, long translations, dynamic content, user content, or keyboard visibility. Forms MUST work across applicable sizes, landscape, large text, RTL, and keyboard states. Avoid fixed-height form/validation areas and unnecessarily wide desktop forms. Never remove scrolling just to match Figma.

- Images, cards, and grids MUST respect available constraints. Cards respond to their actual available width; use `LayoutBuilder` when internal layout changes. Adapt grids to available space rather than hardcoded columns; typically 1 mobile, 2 tablet, 3+ desktop.

- Use existing design-system spacing; do not scale every spacing value from screen width. Fix, never hide, RenderFlex/text/horizontal overflow, clipping, off-screen controls/images, or keyboard-hidden content. Support portrait/landscape when applicable; never assume height > width.

- If RTL is supported, use Flutter `Directionality` rather than duplicate UIs. Use directional padding/alignment/positioning and `TextAlign.start/end` when meaning follows direction; use left/right only for physical screen sides. Mirror only directional icons (back/forward, chevrons, previous/next, directional/send); do not automatically mirror non-directional icons or logos.

- Localize all user-facing strings, including labels, dialogs, errors, validation, tooltips, empty states, and semantics labels, when the project has localization. Do not hardcode them.

- Interactive elements MUST be understandable by screen readers. Icon-only controls need meaningful semantics unless native widget semantics already suffice. Exclude decorative images from semantics when appropriate and provide semantic alternatives for meaningful images. Use approximately `48×48 dp` or the project's accessibility standard as the minimum touch target; visible icons may be smaller.

- Test meaningful combinations: small/large phones, tablet, desktop/web when supported, landscape, large text, long localized strings, keyboard-visible states, and RTL. Before completion, verify responsive behavior, overflow, text scaling, localization, RTL, accessibility, and design-system reuse.