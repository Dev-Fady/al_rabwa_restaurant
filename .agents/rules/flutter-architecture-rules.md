---
trigger: always_on
---


# Architecture

- Use feature-first structure: `feature/data`, `feature/domain`, `feature/presentation`.

- Dependencies point inward: `presentation → domain`; `data → domain`.
  Domain must not depend on data, presentation, Flutter, or external packages.
  Never allow `domain → data/presentation`, `data → presentation`, or `core/shared → feature`.

- Domain owns business rules, entities, repository contracts, and meaningful use cases.
  No Flutter imports or types (`material.dart`, `widgets.dart`, `foundation.dart`, `Color`, `BuildContext`, `Widget`, `TextStyle`).

- Data owns API/local models, DTO mapping, data sources, and repository implementations.
  Map models/DTOs to domain entities before exposing them to presentation.

- Presentation owns widgets, Cubits/BLoCs, UI state, navigation, and formatting.
  Keep business policy out of widgets/Cubits/BLoCs.

- Place logic in its owning layer:
  `balance >= amount` → domain;
  display formatting → presentation;
  API representation → data;
  retry policy → data/repository.

- Skip a use case that only forwards one repository call.
  Add use cases, interfaces, mappers, or layers only for a real boundary, business rule, or testable behavior.

- Features must not import another feature's data/presentation implementation.
  Put only genuinely shared code in `core/shared`.

- Before adding a file, identify its owning layer. If unclear, do not add it.
  Before accepting architecture changes, verify the rules above.