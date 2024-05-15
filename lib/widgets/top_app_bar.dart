import 'package:actualia/utils/themes.dart';
import 'package:actualia/views/profile_view.dart';
import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool enableReturnButton;
  final bool enableProfileButton;
  final void Function()? onPressed;

  const TopAppBar({
    this.enableReturnButton = false,
    this.enableProfileButton = true,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    if (enableProfileButton) {
      actions.add(
        IconButton(
          key: const Key("profile"),
          visualDensity: const VisualDensity(horizontal: 4),
          iconSize: 28.0,
          icon: const Icon(Icons.account_circle, color: THEME_GREY),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => const ProfilePageView()));
          },
        ),
      );
    }

    return AppBar(
      centerTitle: true,
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: UNIT_PADDING),
        child: TextButton(
          onPressed: () {
            // Action for the title button
          },
          child: Text('ActualIA',
              style: Theme.of(context).textTheme.displayMedium),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
