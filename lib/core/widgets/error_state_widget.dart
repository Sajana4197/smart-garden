import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import 'app_primary_button.dart';

/// Shared error-state widget — used whenever a screen fails to load
/// dynamic data (weather offline, AI failure, etc.), per
/// UI_GUIDELINES.md §6.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.retryLabel,
    this.onRetry,
  });

  final String title;
  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (retryLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(label: retryLabel!, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
