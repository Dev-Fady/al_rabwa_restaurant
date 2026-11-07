---
trigger: always_on
---

# Flutter Project Rules

- This is a production Flutter project. Before coding, inspect the project structure and similar implementations; reuse existing widgets, utilities, services, constants, patterns, and architecture. Do not introduce patterns without reason, duplicate functionality, or modify unrelated files.

- Follow Flutter best practices: keep widgets focused/readable, avoid giant widgets/build methods, extract meaningful reusable widgets, and keep business logic out of UI.

- Follow the project's existing architecture. Keep data/domain/presentation responsibilities separate where Clean Architecture is used.

- Use the existing state-management solution. For Bloc/Cubit, keep business logic in Cubit/Bloc, handle loading/success/failure states, and never call repositories directly from UI widgets.

- Reuse existing networking. For Dio/Retrofit, reuse configured Dio, interceptors, and API services. Never create another HTTP client or hardcode API URLs/tokens.

- Use existing dependency injection. For GetIt, register through GetIt; do not instantiate services/repositories in widgets or duplicate registrations.

- Use existing routing. For GoRouter, add routes to the existing router and reuse existing route names/constants. Do not introduce another routing solution.

- Before creating UI, search for and reuse existing colors, text styles, spacing, buttons, inputs, cards, and reusable widgets. Do not duplicate components or hardcode design values when tokens/systems exist.

- Every screen MUST be responsive across applicable small/large phones, tablets, landscape, and desktop/web. Use appropriate responsive constraints (`Expanded`, `Flexible`, `LayoutBuilder`, `ConstrainedBox`, `Wrap`, `GridView`, `FractionallySizedBox`, `MediaQuery`). Avoid unnecessary fixed sizes and Figma frame dimensions. Prevent overflow, clipping, off-screen controls, and overwide content.

- Follow the project's spacing system. When `Gap` is used, follow its established values instead of mixing spacing approaches.

- Avoid magic numbers/strings, duplicate code, unnecessary abstractions/dependencies, giant widgets, and hardcoded design tokens.

- After implementation: format, run Flutter analyzer and relevant tests, verify responsive behavior and overflow, review changed files, and do not claim completion without verification.

- Existing code is the source of truth; consistency with established project patterns takes priority over personal preference.