# 01. The scaffold

What `very_good create flutter_app keeper --org-name engineer.jamiebrown --platforms android,ios` produced in `app/`, and what each file is for. Read this with the tree open. Nothing here needs writing; it is the worked example the rest of the phases build on.

## The shape

```
app/
  lib/
    main_development.dart   entry point, one per flavor
    main_staging.dart
    main_production.dart
    bootstrap.dart          shared startup: error handler, observer, runApp
    app_bloc_observer.dart  logs every Bloc change and error
    app/
      app.dart              barrel: exports the feature
      view/app.dart         the MaterialApp: theme, localization, home
    counter/
      counter.dart          barrel
      cubit/counter_cubit.dart
      view/counter_page.dart
    l10n/
      l10n.dart             the context.l10n extension
      arb/app_en.arb        the strings, one file per language
      gen/                  generated, never edited
  test/                     mirrors lib/ one to one
    helpers/pump_app.dart   wraps a widget in MaterialApp with localization
    helpers/helpers.dart    barrel for the helpers
  very_good.yaml            the test gate's settings
  analysis_options.yaml     the lint set
  l10n.yaml                 where the strings live and where codegen writes
  pubspec.yaml              dependencies
```

## Three flavors, one bootstrap

`main_development.dart` is four lines:

```dart
import 'package:keeper/app/app.dart';
import 'package:keeper/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
```

The three `main_*.dart` files are identical today. They exist so each flavor can later point at a different backend: development at the in-process fake, staging at the local simulator. `flutter run --flavor development --target lib/main_development.dart` picks the file and the matching iOS scheme and Android product flavor.

`bootstrap.dart` does the startup every flavor shares. It installs a `FlutterError.onError` handler, sets `Bloc.observer`, and calls `runApp` on whatever widget the flavor passed in. The observer moved to its own file in PR 1 so the coverage gate can measure it; `bootstrap.dart` is excluded from coverage because a test that calls `runApp` proves nothing.

## Feature folders: Page, View, and the barrel

Every feature is a folder with the same three parts. The counter is the template's worked example.

- `counter/counter.dart` is a **barrel**: a file of `export` lines. Other code imports the barrel, never a file inside the folder. When a feature moves its internals around, importers do not change.
- `counter/cubit/counter_cubit.dart` holds the state. `Cubit<int>` with `increment()` and `decrement()`. A Cubit is the simple form of a Bloc: methods that call `emit`. The plan uses a Bloc for the inbox because events give a trail, and a Cubit for the detail view because the state is simple.
- `counter/view/counter_page.dart` holds two widgets. `CounterPage` **provides** the Cubit with `BlocProvider`. `CounterView` **consumes** it with `context.select` and `context.read`. That split is the convention everywhere in this repository: the Page is the one place a Bloc is created, the View only reads it, so a widget test can hand the View a mock.

Read `counter_page.dart` for the three ways a widget talks to a Bloc:

- `context.select((CounterCubit cubit) => cubit.state)` rebuilds this widget when the selected value changes. Used in `build`.
- `context.read<CounterCubit>().increment()` gets the Cubit without subscribing. Used in callbacks.
- `BlocProvider(create: (_) => CounterCubit(), child: ...)` creates and owns the Cubit, closing it when the widget goes away.

## Localization: `context.l10n`

No user-facing string is a literal in a widget. `app_en.arb` is a JSON file of keys to strings. Codegen turns it into `AppLocalizations` under `lib/l10n/gen/`, and `l10n.dart` adds one extension so widgets write `context.l10n.counterAppBarTitle`. When you add a screen in Phase 6, the strings go in the ARB first and the widget reads them from `context.l10n`.

## Tests mirror `lib/`

`test/counter/cubit/counter_cubit_test.dart` is a `blocTest` for the Cubit. `test/counter/view/counter_page_test.dart` mocks the Cubit and checks the View. `test/app/view/app_test.dart` pumps the whole app once. The rule is one test file per source file, same path, `_test` suffix.

`test/helpers/pump_app.dart` is the helper every widget test uses:

```dart
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: widget,
      ),
    );
  }
}
```

An extension adds a method to a type you do not own. Here it gives `WidgetTester` a `pumpApp` that wraps the widget in a `MaterialApp` with localization, so no test builds that by hand.

## The gate

`very_good.yaml` holds the settings for `very_good test`: coverage on, 100 percent floor, collect from all files, four exclusions. Running `very_good test` inside `app/` is the full gate. For a fast loop while writing, use `flutter test test/domain` in a terminal instead; it runs one folder and skips coverage.

`analysis_options.yaml` pulls in `very_good_analysis` and `bloc_lint`. The analyzer is strict: it will ask for `const` where it can be used, for `final` fields, and for the `new` constructor shorthand. Treat every info as a fix, because CI does.

<details>
<summary><strong>Hints for reading the scaffold. Open if something above did not land.</strong></summary>

- `const` in Dart marks a compile-time constant. A `const` constructor promises every field is `final` and the instance can be built at compile time. Widgets are `const` wherever possible so Flutter can skip rebuilding them. When the analyzer says "use const", it is right.
- `late` means "assigned before first use, trust me". Tests use it for objects created in `setUp`. The analyzer also asks for it on private fields that are always set before being read.
- `extension` adds methods to an existing type. `extension type` is different: it is a zero-cost wrapper that gives an existing value a new static type. Both appear in Phase 2.
- `part` and `part of` split one library across files. The Bloc convention uses them so the event and state files share the Bloc's imports without their own.
- `Future<void> main() async` is an async entry point. `await` works the same way as in Swift.
- A file that starts with `// dart format off` or `// coverage:ignore-file` is generated. Do not edit it; edit its source and regenerate.

</details>
