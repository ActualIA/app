import 'package:flutter/material.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: <Widget>[
          //Invisible box to center the title
          const SizedBox(width: 40),
          // Central button acting as the application title
          Expanded(
            child: TextButton(
              onPressed: () {
                // Action for the title button
              },
              style: TextButton.styleFrom(
                alignment: Alignment.center,
              ),
              child: const Text(
                'ActualIA',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'Fira Code',
                  fontWeight: FontWeight.w300,
                  height: 0.06,
                ),
              ),
            ),
          ),
          // Profile button aligned to the right
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.grey),
            onPressed: () {
              // TODO : Action for the profile button
            },
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
