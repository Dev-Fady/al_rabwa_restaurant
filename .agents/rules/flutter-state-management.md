---
trigger: always_on
---

# State Management

- Use Cubit/BLoC for feature state.
- Prefer immutable sealed/Freezed states representing meaningful `initial`, `loading`, `success`, and `failure` states; never mutate state objects or collections.
- Every async Cubit method MUST check `isClosed` after each `await` and before `emit`.
- Use `BlocBuilder` for full-state UI, `BlocSelector` for specific fields to limit rebuilds, `BlocListener` only for side effects (navigation, snackbars, dialogs, sheets, messages), and `BlocConsumer` only when both building and side effects are required.
- Keep business rules in domain, not Cubits. Never store `BuildContext`, `Widget`, `TextEditingController`, animation controllers, or other UI objects in Cubits.
- Keep each Cubit focused on one feature/responsibility; avoid God Cubits and unnecessary rebuilds.