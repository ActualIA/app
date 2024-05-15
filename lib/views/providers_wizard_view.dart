import 'dart:io';

import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/views/loading_view.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class ProvidersWizardView extends StatefulWidget {
  final bool cancelable;
  final bool hasNext;

  const ProvidersWizardView(
      {this.cancelable = false, this.hasNext = true, super.key});

  @override
  State<ProvidersWizardView> createState() => _ProvidersWizardView();
}

class _ProvidersWizardView extends State<ProvidersWizardView> {
  List<ProviderWidget>? items;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProvidersViewModel>(context, listen: false)
            .fetchNewsProviders());
  }

  @override
  Widget build(BuildContext context) {
    final ProvidersViewModel pvm = Provider.of<ProvidersViewModel>(context);
    items = pvm.editedProviders.indexed
        .map((e) => ProviderWidget(
            idx: e.$1, onDelete: (w) => pvm.removeEditedProvider(e.$1)))
        .toList();

    Widget body = const LoadingView(text: "Loading your sources");
    if (items != null) {
      var items_ = items as List<ProviderWidget>;

      body = Column(children: [
        Text("Choose the sources for your news",
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: UNIT_PADDING),
        Expanded(
            child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, UNIT_PADDING),
          children: [
            ...items_,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonalIcon(
                    icon: const Icon(Icons.add),
                    onPressed: () => pvm.addEditedProvider(),
                    label: const Text("Add"))
              ],
            )
          ],
        )),
        WizardNavigationBottomBar(
          showCancel: widget.cancelable,
          rText: widget.hasNext ? "Next" : "Done",
          onCancel: () => Navigator.pop(context),
          rOnPressed: () async {
            pvm.updateProvidersFromEdited();
            if (!await pvm.pushNewsProviders()) {
              if (Platform.isAndroid) {
                Fluttertoast.showToast(msg: "Error while updating providers");
              }
            } else if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ]);
    }

    return WizardScaffold(body: Material(child: body));
  }
}
