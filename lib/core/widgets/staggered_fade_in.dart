import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Wraps a list/grid item in a subtle fade+slide-up entrance, staggered by
/// [index] — see UI_GUIDELINES.md §5 ("subtle staggered fade+slide-in on
/// first build, not on every rebuild"). The delay is capped so long lists
/// don't produce an ever-growing total entrance time (UI_GUIDELINES.md §5:
/// "avoid... anything over ~600ms for a routine interaction").
class StaggeredFadeIn extends StatefulWidget {
  const StaggeredFadeIn({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  static const int _maxStaggeredIndex = 10;
  static const Duration _perItemDelay = Duration(milliseconds: 40);

  @override
  State<StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<StaggeredFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: AppCurves.standard,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void initState() {
    super.initState();
    final cappedIndex = widget.index.clamp(0, StaggeredFadeIn._maxStaggeredIndex);
    Future.delayed(StaggeredFadeIn._perItemDelay * cappedIndex, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
