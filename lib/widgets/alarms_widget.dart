import 'dart:developer';

import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class PickTimeButton extends StatefulWidget {
  final DateTime initialTime;
  final void Function(DateTime) onTimeSelected;

  const PickTimeButton(
      {required this.initialTime, required this.onTimeSelected, super.key});

  @override
  State<PickTimeButton> createState() => _PickTimeButton();
}

class _PickTimeButton extends State<PickTimeButton> {
  late DateTime _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  Future<void> pickTime() async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        final now = DateTime.now();
        _selectedTime = now.copyWith(
          hour: res.hour,
          minute: res.minute,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );
        if (_selectedTime.isBefore(now)) {
          widget.onTimeSelected(_selectedTime.add(const Duration(days: 1)));
        }
        log("Selected date time : $_selectedTime",
            name: "Debug", level: Level.WARNING.value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: pickTime,
      fillColor: Theme.of(context).colorScheme.secondaryContainer,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(BOX_BORDER_RADIUS))),
      child: Container(
        margin: const EdgeInsets.all(UNIT_PADDING),
        child: Text(
          TimeOfDay.fromDateTime(_selectedTime).format(context),
          style: Theme.of(context).textTheme.displayMedium!,
        ),
      ),
    );
  }
}
