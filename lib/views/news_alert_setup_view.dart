import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/widgets/alarms_widget.dart';
import 'package:actualia/widgets/top_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewsAlertSetupView extends StatefulWidget {
  const NewsAlertSetupView({super.key});

  @override
  State<StatefulWidget> createState() => _NewsAlertSetupViewState();
}

class _NewsAlertSetupViewState extends State<NewsAlertSetupView> {
  late bool loading;

  late bool enabled;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late double volume;
  late String assetAudio;

  @override
  void initState() {
    super.initState();
    AlarmsViewModel alarmModel = Provider.of(context, listen: false);
    final previousAlarm = alarmModel.alarm;
    loading = false;

    if (previousAlarm == null) {
      enabled = false;
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volume = 0.3;
      assetAudio = 'assets/audio/boom.mp3';
    } else {
      enabled = true;
      selectedDateTime = previousAlarm.dateTime;
      loopAudio = previousAlarm.loopAudio;
      vibrate = previousAlarm.vibrate;
      volume = previousAlarm.volume!;
      assetAudio = previousAlarm.assetAudioPath;
    }
  }

  Future<void> saveAlarm(BuildContext context) async {
    AlarmsViewModel model = Provider.of(context, listen: false);
    NewsSettingsViewModel newsSettingsModel =
        Provider.of(context, listen: false);
    await newsSettingsModel.fetchSettings();
    final settingsId = newsSettingsModel.settingsId!;
    await model.setAlarm(
        selectedDateTime, assetAudio, loopAudio, vibrate, volume, settingsId);
  }

  // Cov: Alarm logic strictly depends on mobile platform
  // coverage:ignore-start
  Future<void> updateAlarm(BuildContext context) async {
    if (!enabled) {
      return;
    }
    AlarmsViewModel model = Provider.of(context, listen: false);
    await model.setAlarm(
        selectedDateTime, assetAudio, loopAudio, vibrate, volume, null);
  }

  Future<void> testAlarm(BuildContext context) async {
    AlarmsViewModel model = Provider.of(context, listen: false);
    await model.setAlarm(
        DateTime.now(), assetAudio, loopAudio, vibrate, volume, null);
  }

  Future<void> deleteAlarm(BuildContext context) async {
    AlarmsViewModel model = Provider.of(context, listen: false);
    await model.unsetAlarm();
  }
  // coverage:ignore-end

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    AlarmsViewModel alarmModel = Provider.of(context);

    Widget body = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    PickTimeButton(
                        initialTime: selectedDateTime,
                        onTimeSelected: (t) => selectedDateTime = t),
                    Column(
                      children: [
                        Icon(
                          enabled ? Icons.alarm_on : Icons.alarm_off,
                          size: 30.0,
                        ),
                        Switch(
                          value: enabled,
                          onChanged: (value) => {
                            setState(() => enabled = value),
                            if (value)
                              {saveAlarm(context)}
                            else
                              {deleteAlarm(context)}
                          },
                          key: const Key("switch-on-off"),
                        ),
                      ],
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(
                    enabled
                        ? loc.alarmSetFor(selectedDateTime)
                        : loc.alarmNotSet,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
                  ),
                ),
              ])),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20.0),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.lightBlueAccent),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      volume > 0.7
                          ? Icons.volume_up_rounded
                          : volume > 0.1
                              ? Icons.volume_down_rounded
                              : Icons.volume_mute_rounded,
                    ),
                    Text(
                      "${(volume * 100).round()}%",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Expanded(
                      child: Slider(
                        value: volume,
                        onChanged: (value) {
                          setState(() => volume = value);
                        },
                        onChangeEnd: (value) {
                          updateAlarm(context);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.alarmLoop,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Switch(
                      value: loopAudio,
                      onChanged: (value) {
                        setState(() {
                          loopAudio = value;
                        });
                        updateAlarm(context);
                      },
                      key: const Key("switch-loop"),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vibrate',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Switch(
                      value: vibrate,
                      onChanged: (value) {
                        setState(() {
                          vibrate = value;
                        });
                        updateAlarm(context);
                      },
                      key: const Key("switch-vibrate"),
                    ),
                  ],
                ),
                FilledButton.tonal(
                    onPressed: () => testAlarm(context), child: Text(loc.test)),
              ],
            ),
          ),
        ],
      ),
    );

    Widget bottomBar = Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.tonal(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(loc.done)),
        ],
      ),
    );

    return Scaffold(
        appBar: const TopAppBar(), body: body, bottomNavigationBar: bottomBar);
  }
}
