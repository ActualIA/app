import 'package:actualia/utils/themes.dart';
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

    Widget body = Container(
        padding: const EdgeInsets.symmetric(horizontal: UNIT_PADDING * 3),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
                padding: const EdgeInsets.only(
                    top: UNIT_PADDING * 3, bottom: UNIT_PADDING * 2),
                alignment: AlignmentDirectional.bottomStart,
                child: Text(
                    style: Theme.of(context).textTheme.titleLarge,
                    "Alarm settings")),
            Container(
                padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING / 2),
                key: const Key("switch-on-off"),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          style: Theme.of(context).textTheme.displayMedium,
                          "Enable alarm"),
                      Switch(
                          value: enabled,
                          onChanged: (value) => {
                                setState(() => enabled = value),
                                if (value)
                                  saveAlarm(context)
                                else
                                  deleteAlarm(context)
                              }),
                    ])),
            Container(
                padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING / 2),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          style: Theme.of(context).textTheme.displayMedium,
                          "Time"),
                      PickTimeButton(
                          initialTime: selectedDateTime,
                          onTimeSelected: (t) => selectedDateTime = t),
                    ])),
            Container(
                padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING / 2),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          style: Theme.of(context).textTheme.displayMedium,
                          "Vibrate"),
                      Switch(
                          value: vibrate,
                          onChanged: (value) {
                            setState(() {
                              vibrate = value;
                            });
                            updateAlarm(context);
                          },
                          key: const Key("switch-vibrate")),
                    ])),
            Container(
                padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING / 2),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                          style: Theme.of(context).textTheme.displayMedium,
                          "Loop audio"),
                      Switch(
                          value: loopAudio,
                          onChanged: (value) {
                            setState(() {
                              loopAudio = value;
                            });
                            updateAlarm(context);
                          },
                          key: const Key("switch-loop")),
                    ])),
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
                Container(
                    padding: const EdgeInsets.only(left: UNIT_PADDING / 4),
                    child: Text(
                      "${(volume * 100).round()}%",
                      style: Theme.of(context).textTheme.displayMedium,
                    )),
                Expanded(
                  child: Slider(
                    value: volume,
                    onChanged: (value) {
                      setState(() => volume = value);
                    },
                    onChangeEnd: (value) {
                      updateAlarm(context);
                    },
                    key: const Key("slider"),
                  ),
                ),
              ],
            ),
          ],
        ));

    Widget bottomBar = Container(
      padding: const EdgeInsets.all(UNIT_PADDING * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FilledButton.tonal(
              onPressed: () {
                testAlarm(context);
              },
              child: Text(loc.test)),
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
