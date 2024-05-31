import 'dart:io';

import 'package:actualia/models/news_settings.dart';
import 'package:actualia/utils/locales.dart';
import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class AccessibilityView extends StatelessWidget {
  const AccessibilityView({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    var nsvm = Provider.of<NewsSettingsViewModel>(context);

    List<String> predefinedPrompts = [
      loc.prompt1,
      loc.prompt2,
      loc.prompt3,
      loc.prompt4,
      loc.prompt5,
      loc.prompt6,
    ];

    return WizardScaffold(
        bottomBar: WizardNavigationBottomBar(
          showCancel: false,
          rText: loc.done,
          rOnPressed: () async {
            if (!await nsvm.pushSettings(null)) {
              if (context.mounted && Platform.isAndroid) {
                Fluttertoast.showToast(msg: loc.accessibilityUpdateError);
              }
            } else {
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
        ),
        body: Column(children: [
          Expanded(
              child: ListView(
            children: [
              Card(
                child: Container(
                  padding: const EdgeInsets.all(UNIT_PADDING),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.accessibilityLanguage,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        DropdownButton(
                          value: loc.localeName,
                          items: AppLocalizations.supportedLocales
                              .map((l) => DropdownMenuItem(
                                  value: l.toLanguageTag(),
                                  child: Text(
                                    LOCALES[l.languageCode]!,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  )))
                              .toList(),
                          onChanged: (value) => nsvm.setLocale(value),
                        )
                      ]),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(UNIT_PADDING),
                child: Text(
                  loc.explainingUserPrompt,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SizedBox(
                width: 250,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: PromptedChoice<String>.single(
                    title: 'Prompt',
                    value: nsvm.userPrompt,
                    onChanged: nsvm.setUserPrompt,
                    itemCount: predefinedPrompts.length,
                    itemBuilder: (state, i) {
                      return RadioListTile(
                        value: predefinedPrompts[i],
                        groupValue: state.single,
                        onChanged: (value) {
                          state.select(predefinedPrompts[i]);
                        },
                        title: ChoiceText(
                          predefinedPrompts[i],
                          highlight: state.search?.value,
                        ),
                      );
                    },
                    promptDelegate: ChoicePrompt.delegateBottomSheet(),
                    anchorBuilder: ChoiceAnchor.create(inline: true),
                  ),
                ),
              )
            ],
          )),
        ]));
  }
}
