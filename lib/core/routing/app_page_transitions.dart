import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';

/// Shared route-transition pattern (M3 "fade through": incoming content
/// fades/scales in while outgoing content fades out) applied uniformly to
/// every pushed route — see UI_GUIDELINES.md §5 ("consistent shared-axis or
/// fade-through pattern app-wide"). Not applied to the bottom-nav shell's
/// own branch routes (`StatefulShellRoute.indexedStack` swaps tabs via
/// `IndexedStack`, not a page transition — a push-style animation there
/// would fight the platform's own bottom-nav convention).
CustomTransitionPage<void> buildAppPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.medium,
    reverseTransitionDuration: AppDurations.medium,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final incoming = CurvedAnimation(parent: animation, curve: AppCurves.standard);
      final outgoing = CurvedAnimation(parent: secondaryAnimation, curve: AppCurves.standard);
      return FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(outgoing),
        child: FadeTransition(
          opacity: incoming,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(incoming),
            child: child,
          ),
        ),
      );
    },
  );
}
