---
trigger: always_on
---

# Visual Verification

- A UI screen is NOT complete merely because it compiles/runs.

- For a design-based screen: build/run, capture an `integration_test` screenshot, compare it with the reference, diagnose and fix differences, and repeat until visually close.

- Maximum four verification iterations. If still different, investigate the root cause instead of blindly changing UI values; diagnose before layout changes.

- Diagnostic hints:
  - Shifted content block → check padding, margins, alignment, spacing tokens.
  - Edge text differences → check font weight, letter spacing, size, line height.
  - Global shift/scale → check export scale and device pixel ratio.
  - Different text shape → check bundled/configured font in `pubspec.yaml`.

- Never compensate for font/scaling problems with random padding, margins, or widget sizes. Prefer deterministic visual-verification scripts.

- Before completion, verify build success, screenshot capture/comparison, major spacing/sizing/typography/alignment/component differences, and fixes for obvious differences.