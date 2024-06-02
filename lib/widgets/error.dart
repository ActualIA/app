import 'package:actualia/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String? title;
  final String description;

  const ErrorDisplayWidget({super.key, this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
          vertical: UNIT_PADDING * 3, horizontal: UNIT_PADDING),
      children: [
        Text(title ?? loc.errorTitle,
            style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
        Text(description,
            style: theme.textTheme.bodyLarge, textAlign: TextAlign.center)
      ],
    );
  }
}
