import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';

class WizardSelector extends StatefulWidget {
  final String title;
  final String buttonText;
  final List<String> items;
  final List<String> selectedItems;
  final void Function(List<String>) onPressed;
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
  late List<String> _items;
  List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _selectedItems = widget.selectedItems.toList();
  }

  @override
  Widget build(BuildContext context) {
    Widget title = Text(
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
        widget.title);

    Widget body = Expanded(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING * 2),
            child: SingleChildScrollView(
                child: Wrap(
                    spacing: UNIT_PADDING / 2,
                    runSpacing: UNIT_PADDING / 2.5,
                    alignment: WrapAlignment.center,
                    children: _items
                        .map((e) => FilterChip(
                            label: Text(e),
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
