import 'package:flutter/material.dart';

import 'press_scale.dart';

/// Primary call-to-action button (Confirm, Save, Scan Now) — see
/// UI_GUIDELINES.md §6.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final button = icon != null
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
          )
        : FilledButton(onPressed: onPressed, child: Text(label));
    return PressScale(enabled: onPressed != null, child: button);
  }
}
