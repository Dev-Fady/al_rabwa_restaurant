---
trigger: always_on
---

# Golden Tests

- Use golden tests for UI regression coverage after UI changes.
- Cover supported baselines and representative variants: small/large phone, tablet, light/dark, text scale 1.0/2.0, LTR/RTL. Do not test the full cross-product.
- NEVER run `flutter test --update-goldens`.