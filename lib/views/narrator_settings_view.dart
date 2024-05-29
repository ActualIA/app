import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/narrator.dart';
import 'package:actualia/widgets/play_button.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NarratorSettingsView extends StatefulWidget {
  const NarratorSettingsView({super.key});

  @override
  State<NarratorSettingsView> createState() => _NarratorSettingsViewState();
}

class _NarratorSettingsViewState extends State<NarratorSettingsView> {
  late String voiceWanted;
  int _selectedOption = 0;
  List<String> options = ["echo", "alloy", "fable", "onyx", "nova", "shimmer"];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<NarratorViewModel>(context, listen: false)
            .fetchVoiceWanted());
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    NarratorViewModel narratorViewModel =
        Provider.of<NarratorViewModel>(context);
    voiceWanted = narratorViewModel.voiceWanted;
    _selectedOption = options.indexOf(voiceWanted);

    return Scaffold(
        appBar: const TopAppBar(),
        body: Container(
          alignment: Alignment.center,
          child: Column(
              //shrinkWrap: true,
              //physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(UNIT_PADDING * 3,
                      UNIT_PADDING * 2, UNIT_PADDING * 3, UNIT_PADDING * 2),
                  child: Text(loc.narratorTitle,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: UNIT_PADDING),
                        child:
                            // Creates a scrollable list of options, followed by a done button
                            ListView.builder(
                          shrinkWrap: true,
                          itemCount: options.length + 1,
                          itemBuilder: (context, index) {
                            return (index != options.length)
                                ? ListTile(
                                    title: Text(
                                        '${loc.voice} ${NarratorViewModel.capitalize(options[index])}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium),
                                    leading: Radio(
                                      value: index,
                                      groupValue: _selectedOption,
                                      onChanged: (int? value) {
                                        setState(() {
                                          _selectedOption = value!;
                                          voiceWanted = options[value];
                                          narratorViewModel
                                              .pushVoiceWanted(voiceWanted);
                                        });
                                      },
                                    ),
                                    trailing: PlayButton(
                                        transcriptId: -1,
                                        source: AssetSource(
                                            "audio/${options[index]}.mp3")),
                                  )
                                : Container(
                                    alignment: Alignment.bottomRight,
                                    padding: const EdgeInsets.fromLTRB(
                                        UNIT_PADDING * 2,
                                        UNIT_PADDING * 2,
                                        UNIT_PADDING * 2,
                                        0),
                                    child: FilledButton.tonal(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall,
                                          loc.done),
                                    ),
                                  );
                          },
                        ))),
              ]),
        ));
  }
}
