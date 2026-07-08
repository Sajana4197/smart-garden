import 'package:flutter/material.dart';

/// Shared section header for dashboard/list screens — title plus an
/// optional trailing action (e.g. "See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (trailingLabel != null)
          TextButton(onPressed: onTrailingTap, child: Text(trailingLabel!)),
      ],
    );
  }
}
