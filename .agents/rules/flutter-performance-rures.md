---
trigger: always_on
---

# Performance

- Every screen/component MUST consider performance; prefer simple, high-impact, measurable, maintainable changes. Do not sacrifice readability/architecture or optimize speculatively.

- Extract meaningful independent, reusable, or rebuild-isolating sections into widgets, not large helper methods; do not extract trivial widgets. Use `const` constructors/widgets where possible.

- Keep rebuild scopes small; observe only needed state with project selectors/listenables (`BlocSelector`, `context.select`, `Selector`, `ValueListenableBuilder`). Use `AnimatedBuilder` for animation-driven rebuild isolation; avoid global state for local UI.

- Keep `build()` lightweight: NEVER do API/database/file work, JSON/image processing, expensive calculations/sort/filter, or recreate expensive Futures/Streams. Use stable Future/Stream or project state management.

- Use lazy `ListView.builder`/`GridView.builder` for large/dynamic collections; keep items lightweight and do no per-item I/O, parsing, or heavy work. Use stable identity keys (`ValueKey(item.id)`) for reorderable/insertable/removable/stateful items; never use a changing index.

- For significantly downscaled network images, use an appropriate decode size (for example `cacheWidth`) based on rendered size/DPR; never use a blind constant or full-resolution thumbnail. Reuse existing image caching; do not add duplicate caching packages.

- Do NOT add `RepaintBoundary` everywhere; use it only when profiling shows repaint isolation helps. Keep animations small; prefer built-in animation widgets and do not rebuild large static trees or optimize animations without evidence.

- Every controller, listener, subscription, and timer must have a clear lifecycle and be disposed by its owner. Avoid synchronous UI-thread heavy work; use isolates only for genuinely heavy work.

- Use pagination/infinite scroll/lazy loading for large remote datasets; do not load thousands of records or repeatedly sort/filter them during rebuilds.

- Cache only when beneficial; consider memory, freshness, invalidation, and storage. Before adding a performance package, check Flutter and project solutions, reuse them, and add one only for meaningful value.

- Use DevTools to investigate rebuilds, frame drops, memory/image memory, repaints, and CPU; base optimization on evidence when possible.