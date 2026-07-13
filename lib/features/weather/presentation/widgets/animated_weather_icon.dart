import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/current_weather.dart';

/// A small looping animation matched to [condition] — sun rotates gently,
/// clouds/fog drift side to side, rain/snow fall and fade, thunderstorms
/// flash — replacing a single static icon on the Home weather card.
/// Hand-rolled with a plain `AnimationController` + `CustomPainter` rather
/// than a new icon-pack dependency, matching this project's existing
/// custom-animation convention (`SkeletonBox`, the AI Loading sweep, the
/// TTS speaking indicator).
class AnimatedWeatherIcon extends StatefulWidget {
  const AnimatedWeatherIcon({
    super.key,
    required this.condition,
    this.size = 40,
    this.color,
  });

  final WeatherCondition condition;
  final double size;
  final Color? color;

  @override
  State<AnimatedWeatherIcon> createState() => _AnimatedWeatherIconState();
}

class _AnimatedWeatherIconState extends State<AnimatedWeatherIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _iconFor(widget.condition, _controller.value, color),
      ),
    );
  }

  Widget _iconFor(WeatherCondition condition, double t, Color color) {
    switch (condition) {
      case WeatherCondition.clear:
        return Transform.rotate(
          angle: t * 2 * math.pi,
          child: Icon(Icons.wb_sunny, size: widget.size, color: color),
        );
      case WeatherCondition.clouds:
        return _drift(t, Icon(Icons.cloud, size: widget.size, color: color));
      case WeatherCondition.atmosphere:
        return _drift(t, Icon(Icons.foggy, size: widget.size, color: color));
      case WeatherCondition.rain:
      case WeatherCondition.drizzle:
        return _Precipitation(t: t, size: widget.size, color: color, style: _PrecipStyle.rain);
      case WeatherCondition.snow:
        return _Precipitation(t: t, size: widget.size, color: color, style: _PrecipStyle.snow);
      case WeatherCondition.thunderstorm:
        return Stack(
          alignment: Alignment.center,
          children: [
            _Precipitation(t: t, size: widget.size, color: color, style: _PrecipStyle.rain),
            Opacity(
              opacity: _flashOpacity(t),
              child: Icon(Icons.bolt, size: widget.size * 0.6, color: color),
            ),
          ],
        );
      case WeatherCondition.unknown:
        return Icon(Icons.help_outline, size: widget.size, color: color);
    }
  }

  Widget _drift(double t, Widget child) {
    final dx = math.sin(t * 2 * math.pi) * (widget.size * 0.08);
    return Transform.translate(offset: Offset(dx, 0), child: child);
  }

  /// Two quick flashes per loop rather than a constant flicker.
  double _flashOpacity(double t) {
    final cycle = (t * 2) % 1.0;
    return cycle < 0.12 ? 1.0 : 0.0;
  }
}

enum _PrecipStyle { rain, snow }

class _Precipitation extends StatelessWidget {
  const _Precipitation({
    required this.t,
    required this.size,
    required this.color,
    required this.style,
  });

  final double t;
  final double size;
  final Color color;
  final _PrecipStyle style;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.cloud, size: size * 0.85, color: color),
        Positioned.fill(
          child: CustomPaint(painter: _PrecipitationPainter(t: t, color: color, style: style)),
        ),
      ],
    );
  }
}

class _PrecipitationPainter extends CustomPainter {
  _PrecipitationPainter({required this.t, required this.color, required this.style});

  final double t;
  final Color color;
  final _PrecipStyle style;

  static const int _dropCount = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < _dropCount; i++) {
      final phase = (t + i / _dropCount) % 1.0;
      final x = size.width * (0.28 + 0.22 * i);
      final startY = size.height * 0.62;
      final y = startY + phase * size.height * 0.35;
      final opacity = (1 - phase).clamp(0.0, 1.0);
      paint.color = color.withValues(alpha: opacity);

      if (style == _PrecipStyle.snow) {
        canvas.drawCircle(Offset(x, y), 1.4, paint);
      } else {
        canvas.drawLine(Offset(x, y), Offset(x - 1.5, y + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PrecipitationPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color || oldDelegate.style != style;
}
