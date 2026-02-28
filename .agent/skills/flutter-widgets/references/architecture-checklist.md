# Architecture Quality Gate

### Structural integrity
- [ ] Widgets are small and composable — no monolithic single-file outputs.
- [ ] Business logic extracted to providers or controllers in `lib/providers/` or `lib/controllers/`.
- [ ] All static text, image URLs, and lists moved to `lib/data/mock_data.dart`.

### Type safety and immutability
- [ ] All widget fields are `final`.
- [ ] `const` constructors used where possible.
- [ ] No `dynamic` types — all parameters are explicitly typed.
- [ ] Placeholders from templates (e.g., `StitchWidget`) have been replaced with actual names.

### Theming and styling
- [ ] Colors sourced from `Theme.of(context).colorScheme` — no hardcoded `Color(0x...)`.
- [ ] Text styles sourced from `Theme.of(context).textTheme` — no inline `TextStyle` with hardcoded sizes.
- [ ] Dark mode supported via separate `ThemeData` in `AppTheme`.
- [ ] Spacing values use consistent constants or theme extensions.

### Flutter best practices
- [ ] `const` widgets used for static subtrees to optimize rebuilds.
- [ ] No unnecessary `setState` calls — all state changes are intentional.
- [ ] Widget tree depth is reasonable — deep nesting extracted into sub-widgets.
- [ ] `Key` parameters included where lists or conditional widgets are used.
- [ ] File passes `dart analyze` with no errors or warnings.
