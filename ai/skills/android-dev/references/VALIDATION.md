# Skill Validation

Use these checks when updating this skill or investigating agent confusion. They test skill behavior, not Android app code.

## Trigger Checks

Should trigger this skill:

- "Bootstrap a new Android project with the core modules."
- "Generate a dashboard feature module."
- "Add Wear support to this feature."
- "Where should this Compose component live?"
- "Can this feature depend on `:core:data`?"
- "Add a home screen widget."
- "Add a Wear widget."
- "Add a Wear complication."

Should not trigger this skill:

- Generic Kotlin questions unrelated to Android project structure.
- Generic Gradle troubleshooting outside an Android module architecture.
- Frontend, backend, or document-generation tasks with no Android/Kotlin/Compose context.

## Regression Checks

- Ambiguous platform request: ask whether the target is `:app`, `:wear`, both, `:widget:app`, `:widget:wear`, `:complications`, or another surface before generating modules or writing platform UI.
- Feature dependency request: reject direct feature dependencies on `:core:data`; data implementations are wired by platform shells.
- Shared UI request: keep feature-scoped components in `features/<name>/<platform>/component/` unless a Lazy Design-System Promotions trigger exists.
- Promoted design-system dependency: allow only the matching platform module, such as `:features:*:app` to `:core:designsystem:app` or `:features:*:wear` to `:core:designsystem:wear`.
- Widget or complication request: use `widget/` root modules (`:widget:common`, `:widget:app`, `:widget:wear`, `:complications`), not `:app`, `:wear`, or `:features:*` source packages.
- Wear glanceable surface request: use `:widget:wear` with Glance Wear Widgets — reject legacy Tiles API (`androidx.wear.tiles`).
- Core module request: bootstrap creates the five starter core modules only; generated shells, feature platform modules, OS surfaces, and promoted design-system modules are added later.
