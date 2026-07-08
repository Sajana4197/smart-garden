import 'package:flutter/material.dart';

/// Semantic plant-health severity colors, kept distinct from
/// [ColorScheme.error] which is reserved for generic error/destructive
/// states (see UI_GUIDELINES.md §2).
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.healthy,
    required this.onHealthy,
    required this.mild,
    required this.onMild,
    required this.moderate,
    required this.onModerate,
    required this.severe,
    required this.onSevere,
  });

  final Color healthy;
  final Color onHealthy;
  final Color mild;
  final Color onMild;
  final Color moderate;
  final Color onModerate;
  final Color severe;
  final Color onSevere;

  static const AppColors light = AppColors(
    healthy: Color(0xFF388E3C),
    onHealthy: Color(0xFFFFFFFF),
    mild: Color(0xFFFF8F00),
    onMild: Color(0xFF000000),
    moderate: Color(0xFFEF6C00),
    onModerate: Color(0xFF000000),
    severe: Color(0xFFC62828),
    onSevere: Color(0xFFFFFFFF),
  );

  static const AppColors dark = AppColors(
    healthy: Color(0xFF81C784),
    onHealthy: Color(0xFF000000),
    mild: Color(0xFFFFD54F),
    onMild: Color(0xFF000000),
    moderate: Color(0xFFFFB74D),
    onModerate: Color(0xFF000000),
    severe: Color(0xFFE57373),
    onSevere: Color(0xFF000000),
  );

  @override
  AppColors copyWith({
    Color? healthy,
    Color? onHealthy,
    Color? mild,
    Color? onMild,
    Color? moderate,
    Color? onModerate,
    Color? severe,
    Color? onSevere,
  }) {
    return AppColors(
      healthy: healthy ?? this.healthy,
      onHealthy: onHealthy ?? this.onHealthy,
      mild: mild ?? this.mild,
      onMild: onMild ?? this.onMild,
      moderate: moderate ?? this.moderate,
      onModerate: onModerate ?? this.onModerate,
      severe: severe ?? this.severe,
      onSevere: onSevere ?? this.onSevere,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      healthy: Color.lerp(healthy, other.healthy, t)!,
      onHealthy: Color.lerp(onHealthy, other.onHealthy, t)!,
      mild: Color.lerp(mild, other.mild, t)!,
      onMild: Color.lerp(onMild, other.onMild, t)!,
      moderate: Color.lerp(moderate, other.moderate, t)!,
      onModerate: Color.lerp(onModerate, other.onModerate, t)!,
      severe: Color.lerp(severe, other.severe, t)!,
      onSevere: Color.lerp(onSevere, other.onSevere, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get statusColors => Theme.of(this).extension<AppColors>()!;
}
