import 'package:flutter/material.dart';

/// App-branded [AppBar] used across every screen so title style, elevation,
/// and surface color stay consistent — see UI_GUIDELINES.md §6.
class SmartGardenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SmartGardenAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), actions: actions, leading: leading);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
