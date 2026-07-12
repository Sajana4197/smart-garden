import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../domain/entities/speech_status.dart';
import '../../domain/repositories/speech_repository.dart';
import '../../domain/usecases/pause_speech.dart';
import '../../domain/usecases/speak_text.dart';
import '../../domain/usecases/stop_speech.dart';
import '../providers/speech_provider.dart';

/// "Read aloud" button + stop control + speaking indicator, dropped into
/// any screen that wants to speak [text] — see ROADMAP.md Phase 13. Owns
/// its own screen-scoped [SpeechProvider] (see that class's doc comment).
class ReadAloudControls extends StatelessWidget {
  const ReadAloudControls({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SpeechProvider>(
      create: (context) => SpeechProvider(
        context.read<SpeechRepository>(),
        context.read<SpeakText>(),
        context.read<PauseSpeech>(),
        context.read<StopSpeech>(),
      ),
      child: _ReadAloudControlsView(text: text),
    );
  }
}

class _ReadAloudControlsView extends StatelessWidget {
  const _ReadAloudControlsView({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SpeechProvider>();
    final status = provider.status;

    final String label;
    final IconData icon;
    switch (status) {
      case SpeechStatus.idle:
        label = 'Read Aloud';
        icon = Icons.volume_up_outlined;
      case SpeechStatus.speaking:
        label = 'Pause';
        icon = Icons.pause;
      case SpeechStatus.paused:
        label = 'Resume';
        icon = Icons.play_arrow;
    }

    void handlePrimaryTap() {
      switch (status) {
        case SpeechStatus.idle:
          provider.speak(text);
        case SpeechStatus.speaking:
          provider.pause();
        case SpeechStatus.paused:
          provider.speak(text);
      }
    }

    return Row(
      children: [
        Expanded(
          child: AppSecondaryButton(
            label: label,
            icon: icon,
            onPressed: handlePrimaryTap,
          ),
        ),
        if (status != SpeechStatus.idle) ...[
          const SizedBox(width: AppSpacing.sm),
          _SpeakingIndicator(active: status == SpeechStatus.speaking),
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            tooltip: 'Stop reading',
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: provider.stop,
          ),
        ],
      ],
    );
  }
}

/// Pulsing equalizer-style icon shown only while actively speaking (not
/// while paused) — the dedicated visual "speaking" state indicator called
/// for by ROADMAP.md Phase 13, distinct from the button's own label/icon
/// change.
class _SpeakingIndicator extends StatefulWidget {
  const _SpeakingIndicator({required this.active});

  final bool active;

  @override
  State<_SpeakingIndicator> createState() => _SpeakingIndicatorState();
}

class _SpeakingIndicatorState extends State<_SpeakingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _SpeakingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && oldWidget.active) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: _controller.drive(
        Tween(
          begin: 0.35,
          end: 1.0,
        ).chain(CurveTween(curve: AppCurves.standard)),
      ),
      child: Icon(Icons.graphic_eq, color: colorScheme.primary),
    );
  }
}
