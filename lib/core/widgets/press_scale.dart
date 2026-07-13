import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Subtle scale-down-on-press wrapper for buttons/cards — see
/// UI_GUIDELINES.md §5 ("buttons/cards get a subtle scale-down on press,
/// `AnimatedScale` ~0.97"). Uses [Listener] (raw pointer events), not
/// [GestureDetector] — a nested `GestureDetector` would still enter the
/// gesture arena and could win the tap over the child's own recognizer
/// (`FilledButton.onPressed`, `InkWell.onTap`, ...), silently swallowing
/// taps. `Listener` only observes pointer down/up/cancel without competing
/// for the gesture at all, so the child always keeps the actual tap.
class PressScale extends StatefulWidget {
  const PressScale({super.key, required this.child, this.enabled = true});

  final Widget child;

  /// Whether to animate at all — pass `false` when the wrapped control is
  /// disabled (no `onPressed`/`onTap`), so a disabled button doesn't visibly
  /// react to presses it doesn't act on.
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        child: widget.child,
      ),
    );
  }
}
