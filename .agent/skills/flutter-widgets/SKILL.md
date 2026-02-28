---
name: flutter:widgets
description: Converts Stitch designs into modular Flutter widgets using ThemeData mapping and Dart analysis validation.
---

# Stitch to Flutter Widgets

You are a Flutter engineer focused on transforming Stitch designs into clean, idiomatic Flutter widgets. You follow a modular approach and use automated tools to ensure code quality.

## Retrieval and networking
1. **Namespace discovery**: Run `list_tools` to find the Stitch MCP prefix. Use this prefix (e.g., `stitch:`) for all subsequent calls.
2. **Metadata fetch**: Call `[prefix]:get_screen` to retrieve the design JSON.
3. **High-reliability download**: Internal AI fetch tools can fail on Google Cloud Storage domains.
   - Use the `Bash` tool to run: `bash scripts/fetch-stitch.sh "[htmlCode.downloadUrl]" "temp/source.html"`.
   - This script handles the necessary redirects and security handshakes.
4. **Visual audit**: Check `screenshot.downloadUrl` to confirm the design intent and layout details.

## Multi-screen analysis
When converting multiple screens at once, identify reusable elements **before** generating any widgets:

1. **Download all screen HTMLs first.** Scan for repeated DOM patterns — nav bars, buttons with identical classes, card layouts, footers, tab bars.
2. **Build a component inventory**: list each shared element, its visual variants (e.g. filled vs. outlined button), and which screens use it.
3. **Generate shared widgets first** under `lib/widgets/shared/`. Individual screen files import from this directory instead of duplicating code.
4. **Parameterise shared widgets** — e.g. a `PrimaryButton` that accepts `label`, `onPressed`, and `isLoading` — rather than creating a near-identical button widget per screen.

## Architectural rules

### State management — detect, don't dictate
* Inspect `pubspec.yaml` for the project's existing state management (e.g. `flutter_bloc`, `provider`, `riverpod`, `get`, `mobx`).
* **Follow whatever pattern is already in use.** Do not introduce a second state management library.
* If no state management exists, use plain `StatefulWidget` for simple local UI state. Recommend a library only when the complexity clearly warrants it.
* Keep widgets purely presentational: pass data and callbacks in via constructor parameters. A widget should never know *how* state is managed — only *what* data it displays and *what* events it fires.

### Widget structure
* **Modular widgets**: Break the design into independent widget files under `lib/widgets/`. Avoid large, single-file outputs.
* **Immutable constructors**: Every widget must use `final` fields and `const` constructors where possible. Use named parameters with `required` for mandatory props.
* **Widget decomposition**: Extract a private sub-widget (e.g. `_SectionHeader`) when `build()` exceeds ~80 lines or when a subtree is reused within the same file. Prefer composition over deeply nested widget trees.
* **Data decoupling**: Move all static text, image URLs, and lists into `lib/data/mock_data.dart`.
* **Project specific**: Focus on the target project's needs and constraints. Leave Google license headers out of the generated widgets.

### Theming and styling
* Extract the color palette, typography, and spacing values from the HTML `<head>`.
* Sync these values with `references/style-guide.json`.
* Define a custom `AppTheme` class in `lib/theme/app_theme.dart` that maps tokens to Flutter's `ThemeData`.
* Use `Theme.of(context)` to reference colors and text styles — never hardcode hex values via `Color(0xFF...)`.
* Support both light and dark themes. Define separate `ThemeData` for each mode and use `ThemeMode` switching.

### Responsive layout
* Use `LayoutBuilder` or `MediaQuery` to adapt between phone, tablet, and desktop. Never assume a fixed screen width.
* Avoid hardcoded widths on containers; prefer `Expanded`, `Flexible`, `FractionallySizedBox`, or `ConstrainedBox`.

### Accessibility
* Wrap interactive custom-painted areas with `Semantics`. Use `semanticLabel` on `Icon` and `Image` widgets.
* Ensure all tap targets are at least 48 × 48 dp (`kMinInteractiveDimension`).

### Image handling
* Always provide an `errorBuilder` (and a `loadingBuilder` or `FadeInImage` placeholder) on `Image.network`.
* If `cached_network_image` is already in the project, prefer `CachedNetworkImage`.

### Performance
* Mark static subtrees with `const` to prevent unnecessary rebuilds.
* Use `RepaintBoundary` around heavy custom-painting widgets.
* Scope state to the smallest possible widget to minimise rebuild area.

### Navigation awareness
* Check for existing routing (`GoRouter`, `auto_route`, Navigator 2.0) before wiring new screens. Match the existing pattern. Do not introduce a second router.

## Execution steps
1. **Project audit**: Inspect `pubspec.yaml` to detect state management, routing, and image libraries already in use. Adapt all subsequent steps to the project's existing patterns.
2. **Environment setup**: If `pubspec.lock` is missing, run `flutter pub get` to resolve dependencies.
3. **Multi-screen scan** (if multiple screens): Follow the *Multi-screen analysis* section above to build a component inventory and create shared widgets first.
4. **Data layer**: Create `lib/data/mock_data.dart` based on the design content.
5. **Theme setup**: Create `lib/theme/app_theme.dart` with colors, typography, and spacing extracted from the Stitch design, cross-referencing `references/style-guide.json`.
6. **Widget drafting**: Use `assets/widget-template.dart` as a base. Find and replace all instances of `StitchWidget` with the actual name of the widget you are creating.
7. **Application wiring**: Update the project entry point (`lib/main.dart`) or the relevant screen to render the new widgets with the project's existing router.
8. **Quality check**:
    * Run `dart analyze` on the project to catch type errors and lint issues.
    * Run `dart run scripts/validate_widget.dart <file_path>` for each widget to check for hardcoded colors and missing conventions.
    * Verify the final output against `references/architecture-checklist.md`.
    * Start the app with `flutter run` to verify the live result.

## Troubleshooting
* **Fetch errors**: Ensure the URL is quoted in the bash command to prevent shell errors.
* **Analysis errors**: Review `dart analyze` output and fix any missing imports, type mismatches, or lint warnings.
* **Theme issues**: If colors don't match the design, re-check `references/style-guide.json` mapping and ensure `AppTheme` is applied at the `MaterialApp` level.
* **State management conflicts**: If the project uses Bloc but generated code imports Provider, remove the wrong import and adapt to the project's state layer.
