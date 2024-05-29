import 'package:actualia/models/providers.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WizardSelector extends StatefulWidget {
  final String title;
  final String? buttonText;
  final List<(Object, String)> items;
  final List<(Object, String)> selectedItems;
  final void Function(List<(Object, String)>) onPressed;
  final bool isInitialOnboarding;
  final void Function()? onCancel;

  const WizardSelector(
      {required this.items,
      required this.onPressed,
      this.selectedItems = const [],
      this.title = "",
      this.buttonText,
      this.isInitialOnboarding = false,
      this.onCancel,
      super.key});

  @override
  State<WizardSelector> createState() => _WizardSelector();
}

class _WizardSelector extends State<WizardSelector> {
  late List<(Object, String)> _items;
  List<(Object, String)> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _selectedItems = widget.selectedItems.toList();
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    Widget title = WizardSelectorTitle(title: widget.title);

    Widget body = Expanded(
        child: Container(
            padding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 24.0),
            child: SingleChildScrollView(
                child: Wrap(
                    spacing: UNIT_PADDING / 2,
                    runSpacing: UNIT_PADDING / 2.5,
                    alignment: WrapAlignment.center,
                    children: _items
                        .map((e) => FilterChip(
                            label: Text(e.$2),
                            onSelected: (v) {
                              setState(() {
                                _selectedItems.contains(e)
                                    ? _selectedItems.remove(e)
                                    : _selectedItems.add(e);
                              });
                            },
                            selected: _selectedItems.contains(e)))
                        .toList()))));

    Widget bottomBar = WizardNavigationBottomBar(
      showCancel: !widget.isInitialOnboarding,
      onCancel: widget.onCancel,
      showRight: true,
      rText: widget.buttonText ?? loc.next,
      rOnPressed: () {
        widget.onPressed(_selectedItems);
      },
    );

    return Column(
      children: [title, body, bottomBar],
    );
  }
}

class WizardTopBar extends StatelessWidget {
  final String text;

  const WizardTopBar({super.key, this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 50, 16, 8.0),
      child: Text(
        text,
        textScaler: const TextScaler.linear(2.0),
        style: const TextStyle(
            fontFamily: 'EB Garamond',
            fontWeight: FontWeight.w700,
            color: Colors.black),
        maxLines: 2,
      ),
    );
  }
}

class WizardSelectorTitle extends StatelessWidget {
  final String title;

  const WizardSelectorTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
        style: const TextStyle(
            fontFamily: "Fira Code",
            fontWeight: FontWeight.w700,
            fontSize: 32.0),
        textAlign: TextAlign.center,
        title);
  }
}

class WizardNavigationBottomBar extends StatelessWidget {
  final bool showCancel;
  final bool showRight;
  final String? rText;
  final String? cancelText;
  final void Function()? rOnPressed;
  final void Function()? onCancel;

  const WizardNavigationBottomBar(
      {this.showCancel = true,
      this.showRight = true,
      this.rText,
      this.cancelText,
      this.rOnPressed,
      this.onCancel,
      super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    Widget right = const SizedBox();
    Widget cancel = const SizedBox();
    if (showRight) {
      right = FilledButton.tonal(
          onPressed: rOnPressed,
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateColor.resolveWith((states) => THEME_BUTTON)),
          child: Text(
            rText ?? loc.button,
            style: Theme.of(context).textTheme.bodyLarge,
          ));
    }
    if (showCancel) {
      cancel = FilledButton.tonal(
          onPressed: onCancel,
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateColor.resolveWith((states) => THEME_BUTTON)),
          child: Text(
            cancelText ?? loc.cancel,
            style: Theme.of(context).textTheme.bodyLarge,
          ));
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [cancel, right]);
  }
}

class WizardScaffold extends StatelessWidget {
  final PreferredSizeWidget topBar;
  final Widget? body;

  const WizardScaffold({this.topBar = const TopAppBar(), this.body, super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: topBar,
      body: Container(
        padding: const EdgeInsets.fromLTRB(48.0, 48.0, 48.0, 48.0),
        alignment: Alignment.topCenter,
        child: body ?? Text(loc.notImplemented),
      ),
    );
  }
}

class ProviderWidget extends StatefulWidget {
  final void Function(ProviderWidget) onDelete;
  final int idx;

  const ProviderWidget({required this.idx, super.key, required this.onDelete});

  @override
  State<StatefulWidget> createState() => _ProviderWidgetState();
}

class _ProviderWidgetState extends State<ProviderWidget> {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    var pvm = Provider.of<ProvidersViewModel>(context);

    var type = pvm.editedProviders[widget.idx].$1;
    var values = pvm.editedProviders[widget.idx].$2;
    var errors = pvm.editedProviders[widget.idx].$3;

    var fields = type.parameters.indexed.expand((el) {
      var index = el.$1;
      var e = el.$2;

      var error = errors?[index];
      var erroredTheme =
          const TextStyle(color: THEME_ERROR_TEXT, fontWeight: FontWeight.bold);

      var textField = TextField(
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(hintText: e),
          autocorrect: false,
          maxLines: 1,
          controller: TextEditingController(text: values[index]),
          onChanged: (v) {
            values[index] = v;
            pvm.updateEditedProvider(widget.idx, type, values);
          });

      var errorMessage = error != null
          ? Container(
              padding: const EdgeInsets.fromLTRB(UNIT_PADDING, 0, 0, 0),
              child: Text(error,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.merge(erroredTheme)))
          : null;

      return errorMessage != null
          ? [textField, const SizedBox(height: UNIT_PADDING / 3), errorMessage]
          : [textField];
    });

    var title = DropdownButton(
        value: type,
        items: ProviderType.values
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.displayName),
                ))
            .toList(),
        onChanged: (e) => setState(() {
              type = e!;
              values = List.filled(type.parameters.length, "");
              pvm.updateEditedProvider(widget.idx, type, values);
            }));

    return Card(
        color: errors != null ? THEME_ERROR_BACKGROUND : null,
        margin: const EdgeInsets.all(UNIT_PADDING),
        child: Container(
            padding: const EdgeInsets.all(UNIT_PADDING),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              title,
              ...fields,
              const SizedBox(height: UNIT_PADDING / 2),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                FilledButton.tonalIcon(
                    label: Text(loc.remove),
                    onPressed: () => widget.onDelete(widget),
                    icon: const Icon(Icons.delete))
              ]),
            ])));
  }
}
