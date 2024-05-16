import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:alarm/model/alarm_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlarmsViewModel extends ChangeNotifier {
  late SupabaseClient supabase;

  static const int _alarmId = 1;
  bool isAlarmRinging = false;
  bool isAlarmActive = false;

  AlarmSettings? get alarm =>
      Alarm.hasAlarm() ? Alarm.getAlarm(_alarmId) : null;
  bool get isAlarmSet => Alarm.hasAlarm() && Alarm.getAlarm(_alarmId) != null;

  AlarmsViewModel(SupabaseClient supabaseClient) {
    supabase = supabaseClient;
    if (!Alarm.ringStream.hasListener) {
      Alarm.ringStream.stream.listen((_) {
        isAlarmRinging = true;
        isAlarmActive = true;
        notifyListeners();
      });
    } else {
      log("Alarm.ringStream already had a listener ! Callback ignored",
          level: Level.WARNING.value);
    }
    checkAndroidScheduleExactAlarmPermission();
  }

  Future<void> setAlarm(DateTime dateTime, String assetAudioPath,
      bool loopAudio, bool vibrate, double volume, int? settingsId) async {
    final settings = AlarmSettings(
        id: _alarmId,
        dateTime: dateTime,
        assetAudioPath: assetAudioPath,
        loopAudio: loopAudio,
        vibrate: vibrate,
        volume: volume,
        fadeDuration: 3.0,
        notificationTitle: 'News Alert !',
        notificationBody: 'Your customized News Alert is ready !',
        enableNotificationOnKill: true,
        androidFullScreenIntent: true);
    await Alarm.set(alarmSettings: settings);

    if (settingsId != null) {
      final timetz =
          "${dateTime.hour}:${dateTime.minute}:${dateTime.second}+${dateTime.timeZoneOffset.inHours}";
      try {
        await supabase.from("alarms").upsert({
          'created_by': supabase.auth.currentUser!.id,
          'timetz': timetz,
          'transcript_settings_id': settingsId
        }, onConflict: "created_by");
      } catch (e) {
        log("Error pushing alarm: $e", level: Level.SEVERE.value);
      }
    }
  }

  Future<void> unsetAlarm() async {
    await Alarm.stop(_alarmId);
  }

  Future<void> stopAlarms() async {
    await Alarm.stopAll();
    isAlarmRinging = false;
    notifyListeners();
  }

  void dismissAlarm() {
    isAlarmActive = false;
    notifyListeners();
  }

  Future<void> checkAndroidScheduleExactAlarmPermission() async {
    try {
      final scheduleExactAlarmStatus =
          await Permission.scheduleExactAlarm.status;
      if (!scheduleExactAlarmStatus.isGranted) {
        await Permission.scheduleExactAlarm.request();
      }

      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        await Permission.notification.request();
      }
    } catch (e) {
      log("Could not get correct permissions: $e", level: Level.SEVERE.value);
    }
  }
}
