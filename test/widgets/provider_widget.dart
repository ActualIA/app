import 'package:actualia/models/providers.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabase extends Fake implements SupabaseClient {}

class MockProvidersViewModel extends ProvidersViewModel {
  final List<(ProviderType, List<String>)> providers;

  MockProvidersViewModel(this.providers) : super(FakeSupabase());

  @override
  List<(ProviderType, List<String>)> get editedProviders => providers;

  @override
  void updateEditedProvider(int index, ProviderType type, List<String> values) {
    providers[index] = (type, values);
  }
}

class ProviderWrapper extends StatelessWidget {
  final Widget _child;
  final ProvidersViewModel pvm;

  const ProviderWrapper(this._child, this.pvm, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "ActualIA",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: ChangeNotifierProvider<ProvidersViewModel>(
            create: (context) => pvm, child: Material(child: _child)));
  }
}

void main() {
  testWidgets("Correctly display initial data", (tester) async {
    var w = ProviderWidget(idx: 0, onDelete: (e) {});
    await tester.pumpWidget(ProviderWrapper(
        w,
        MockProvidersViewModel(const [
          (ProviderType.telegram, ["clicnews"])
        ])));

    expect(find.textContaining("Telegram"), findsOneWidget);
    expect(find.textContaining("clicnews"), findsOneWidget);
  });

  testWidgets("Can delete", (tester) async {
    var deleted = false;
    await tester.pumpWidget(ProviderWrapper(
        ProviderWidget(
            idx: 0,
            onDelete: (e) {
              deleted = true;
            }),
        MockProvidersViewModel(const [
          (ProviderType.telegram, ["clicnews"])
        ])));

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(deleted, isTrue);
  });

  testWidgets("Can change type", (tester) async {
    var w = ProviderWidget(idx: 0, onDelete: (e) {});
    var pvm = MockProvidersViewModel(List.of([
      (ProviderType.telegram, List<String>.of(["clicnews"]))
    ]));
    await tester.pumpWidget(ProviderWrapper(w, pvm));

    await tester.tap(find.textContaining("Telegram"));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining("Google News"));
    await tester.pumpAndSettle();

    expect(find.textContaining("Google News"), findsOneWidget);
    expect(pvm.providers[0].$1, equals(ProviderType.google));
  });

  testWidgets("Can change field", (tester) async {
    var w = ProviderWidget(idx: 0, onDelete: (e) {});
    var pvm = MockProvidersViewModel(List.of([
      (ProviderType.telegram, List<String>.of(["clicnews"]))
    ]));
    await tester.pumpWidget(ProviderWrapper(w, pvm));

    await tester.enterText(find.textContaining("clicnews"), "clic_bonplans");
    await tester.pumpAndSettle();

    expect(find.textContaining("Telegram"), findsOneWidget);
    expect(find.textContaining("clic_bonplans"), findsOneWidget);
    expect(listEquals(pvm.providers[0].$2, ["clic_bonplans"]), isTrue);
  });
}
