import 'dart:io';

import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/providers.dart';
import 'package:actualia/views/loading_view.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../models/auth_model.dart';
import 'alarm_wizard.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProvidersWizardView extends StatefulWidget {
  const ProvidersWizardView({super.key});

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
    var loc = AppLocalizations.of(context)!;
    final AuthModel auth = Provider.of<AuthModel>(context);
    final ProvidersViewModel pvm = Provider.of<ProvidersViewModel>(context);
    items = pvm.editedProviders.indexed
        .map((e) => ProviderWidget(
            idx: e.$1, onDelete: (w) => pvm.removeEditedProvider(e.$1)))
        .toList();

    Widget body = LoadingView(text: loc.providersWizardLoading);
    if (pvm.isPushing) {
      body = LoadingView(text: loc.providersWizardUpdating);
    } else if (items != null) {
      var items_ = items as List<ProviderWidget>;
      body = Column(children: [
        Text(loc.providersWizardTitle,
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
                    label: Text(loc.add))
              ],
            )
          ],
        )),
        WizardNavigationBottomBar(
          showCancel: !auth.isOnboardingRequired,
          rText: auth.isOnboardingRequired ? loc.next : loc.done,
          onCancel: () => Navigator.pop(context),
          rOnPressed: () async {
            pvm.updateProvidersFromEdited();
            if (!await pvm.pushNewsProviders(loc)) {
              if (context.mounted && Platform.isAndroid) {
                Fluttertoast.showToast(msg: loc.providersUpdateError);
              }
            } else if (context.mounted) {
              if (auth.isOnboardingRequired) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AlarmWizardView()));
              } else if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
        ),
      ]);
    }

    return WizardScaffold(body: Material(child: body));
  }
}
