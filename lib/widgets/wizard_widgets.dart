import 'package:actualia/models/providers.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';

class WizardSelector extends StatefulWidget {
  final String title;
  final String buttonText;
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
      this.buttonText = "Next",
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
      rText: widget.buttonText,
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
  final String rText;
  final void Function()? rOnPressed;
  final void Function()? onCancel;

  const WizardNavigationBottomBar(
      {this.showCancel = true,
      this.showRight = true,
      this.rText = "right button",
      this.rOnPressed,
      this.onCancel,
      super.key});

  @override
  Widget build(BuildContext context) {
    Widget right = const SizedBox();
    Widget cancel = const SizedBox();
    if (showRight) {
      right = FilledButton.tonal(onPressed: rOnPressed, child: Text(rText));
    }
    if (showCancel) {
      cancel =
          FilledButton.tonal(onPressed: onCancel, child: const Text("Cancel"));
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [cancel, right]);
  }
}

class WizardScaffold extends StatelessWidget {
  final PreferredSizeWidget topBar;
  final Widget body;

  const WizardScaffold(
      {this.topBar = const TopAppBar(),
      this.body = const Text("unimplemented"),
      super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: topBar,
        body: Container(
          padding: const EdgeInsets.fromLTRB(48.0, 48.0, 48.0, 48.0),
          alignment: Alignment.topCenter,
          child: body,
        ));
  }
}

class ProviderWidget extends StatefulWidget {
  ProviderType type;
  late List<String> values;
  void Function(ProviderWidget) onDelete;

  NewsProvider toProvider() {
    return NewsProvider(
        url: type.basePath.isNotEmpty
            ? values.isNotEmpty
                ? "${type.basePath}/${values.join("/")}"
                : type.basePath
            : values.join("/"));
  }

  ProviderWidget(NewsProvider? provider, {super.key, required this.onDelete})
      : type = provider?.type ?? ProviderType.rss {
    values = provider?.parameters.toList() ??
        List.filled(type.parameters.length, "");
  }

  @override
  State<StatefulWidget> createState() => _ProviderWidgetState();
}

class _ProviderWidgetState extends State<ProviderWidget> {
  @override
  Widget build(BuildContext context) {
    var fields = widget.type.parameters.map((e) {
      var index = widget.type.parameters.indexOf(e);
      return TextField(
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(hintText: e),
          autocorrect: false,
          maxLines: 1,
          controller: TextEditingController(text: widget.values[index]),
          onChanged: (v) => widget.values[index] = v);
    });

    var title = DropdownButton(
        value: widget.type,
        items: ProviderType.values
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.displayName),
                ))
            .toList(),
        onChanged: (e) => setState(() {
              widget.type = e!;
              widget.values = List.filled(widget.type.parameters.length, "");
            }));

    return Card(
        margin: const EdgeInsets.all(UNIT_PADDING),
        child: ListView(
            padding: const EdgeInsets.all(UNIT_PADDING),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  title,
                  FilledButton.tonalIcon(
                      label: const Text("Remove"),
                      onPressed: () => widget.onDelete(widget),
                      icon: const Icon(Icons.delete))
                ],
              ),
              ...fields,
            ]));
  }
}
