import 'package:actualia/utils/themes.dart';
import 'package:actualia/views/profile_view.dart';
import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool enableReturnButton;
  final void Function()? onPressed;

  const TopAppBar({
    this.enableReturnButton = false,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
      actions: <Widget>[
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
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
