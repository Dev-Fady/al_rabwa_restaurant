---
trigger: always_on
---

# Flutter Testing Rules

- Before changing code, inspect related tests and reuse project test utilities, mocks, fixtures, helpers, conventions, and naming. Do not add duplicate/competing test tooling or modify unrelated tests.

- Do not skip tests for business-logic changes or write tests solely to increase coverage; tests MUST verify real behavior. Keep tests simple, readable, deterministic, and isolated. Add practical regression tests for bugs.

- Use unit tests for use cases, repositories, data sources, mappers, models, helpers, validators, business logic, and Cubit/BLoC logic. Use widget tests for observable rendering, interaction, forms, states, navigation where appropriate, and important responsive behavior. Use integration tests only for important full flows.

- Respect architecture: test presentation Cubit/BLoC and key UI states/interactions; domain use cases/rules/entities/value objects with behavior; data serialization, repositories, sources, and mapping. Do not depend on internal/private implementation.

- Cubit/BLoC tests: cover initial, loading, success, failure, edge cases, and meaningful state transitions. Repository/API tests: cover success, source failure/error, mapping, invalid/unexpected data, and auth behavior when applicable, using mocks/fakes/controlled responses.

- For meaningful model mapping, test JSON↔model, nullable/nested/special enum fields; never test generated code line by line.

- Widget tests MUST assert user-observable behavior (find/tap/type/scroll/visible state), not fragile tree structure or private details. Important forms cover empty/invalid/valid input, validation, submission, loading, failure, and success when applicable.

- Test important responsive screens at meaningful small/large mobile, tablet, landscape, and supported desktop/web breakpoints; use test size/MediaQuery as appropriate. Verify no RenderFlex/text overflow, clipping, off-screen controls, or broken layouts. Do not exhaust pixel widths.

- Unit tests MUST NOT depend on real network, database, or external services. Mock external dependencies, not the behavior under test; avoid over-mocking.

- Use clear behavior-describing test names, e.g. `emits loading and success when login succeeds`.