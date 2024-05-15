import 'package:actualia/models/auth_model.dart';
import 'package:actualia/viewmodels/alarms.dart';
import 'package:actualia/viewmodels/news_settings.dart';
import 'package:actualia/widgets/alarms_widget.dart';
import 'package:actualia/widgets/wizard_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlarmWizardView extends StatefulWidget {
  const AlarmWizardView({super.key});

  @override
  State<AlarmWizardView> createState() => _AlarmWizardView();
}

class _AlarmWizardView extends State<AlarmWizardView> {
  late DateTime _selectedTime;
  late final String assetAudio;
  late final bool vibrate;
  late final double volume;
  late final bool loopAudio;

  @override
  void initState() {
    super.initState();
    _selectedTime = DateTime.now()
        .add(const Duration(minutes: 5))
        .copyWith(second: 0, millisecond: 0);
    loopAudio = true;
    vibrate = true;
    volume = 0.3;
    assetAudio = "assets/audio/boom.mp3";
  }

  @override
  Widget build(BuildContext context) {
    AlarmsViewModel avm = Provider.of<AlarmsViewModel>(context);
    AuthModel auth = Provider.of<AuthModel>(context);

    Widget body = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Choose your first alarm!",
            style: Theme.of(context).textTheme.titleLarge),
        PickTimeButton(
            initialTime: _selectedTime,
            onTimeSelected: (time) {
              _selectedTime = time;
            }),
        WizardNavigationBottomBar(
          showCancel: true,
          cancelText: "Skip",
          onCancel: () async {
            if (auth.isOnboardingRequired) {
              await auth.setOnboardingIsDone();
            }
            if (context.mounted) {
              Navigator.popUntil(
                  context, (route) => !route.hasActiveRouteBelow);
            }
          },
          showRight: true,
          rText: "Validate",
          rOnPressed: () async {
            avm.setAlarm(
                _selectedTime,
                assetAudio,
                loopAudio,
                vibrate,
                volume,
                Provider.of<NewsSettingsViewModel>(context, listen: false)
                    .settingsId);
            if (auth.isOnboardingRequired) {
              await auth.setOnboardingIsDone();
            }
            Navigator.popUntil(context, (route) => !route.hasActiveRouteBelow);
          },
        )
      ],
    );

    return WizardScaffold(
      body: body,
    );
  }
}
