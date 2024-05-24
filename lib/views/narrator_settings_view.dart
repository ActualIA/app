import 'package:actualia/utils/themes.dart';
import 'package:actualia/viewmodels/narrator.dart';
import 'package:actualia/widgets/play_button.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    NarratorViewModel narratorViewModel =
        Provider.of<NarratorViewModel>(context);
    voiceWanted = narratorViewModel.voiceWanted;
    _selectedOption = options.indexOf(voiceWanted);

    return Scaffold(
        appBar: const TopAppBar(),
        body: Container(
          alignment: Alignment.center,
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(UNIT_PADDING * 3,
                  UNIT_PADDING * 2, UNIT_PADDING * 3, UNIT_PADDING * 2),
              child: Text("Choose a voice for your audio",
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            Expanded(
                child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      'Voice ${NarratorViewModel.capitalize(options[index])}',
                      style: Theme.of(context).textTheme.displayMedium),
                  leading: Radio(
                    value: index,
                    groupValue: _selectedOption,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedOption = value!;
                        voiceWanted = options[value];
                        narratorViewModel.pushVoiceWanted(voiceWanted);
                      });
                    },
                  ),
                  trailing: PlayButton(
                      transcriptId: -1,
                      source: AssetSource("audio/${options[index]}.mp3")),
                );
              },
            )),
          ]),
        ));
  }
}
