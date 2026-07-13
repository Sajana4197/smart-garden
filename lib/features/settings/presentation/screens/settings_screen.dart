import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_secondary_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../services/app_info/app_info_service.dart';
import '../../../my_garden/presentation/providers/my_garden_provider.dart';
import '../../../plant_health_dashboard/presentation/providers/plant_health_dashboard_provider.dart';
import '../../../scan_history/presentation/providers/scan_history_provider.dart';
import '../../../voice/presentation/widgets/read_aloud_controls.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../domain/entities/speech_settings.dart';
import '../../domain/entities/temperature_unit.dart';
import '../providers/settings_provider.dart';

const String _supportEmail = 'support@smartgarden.ai';

const String _creditsText =
    'Weather data provided by OpenWeatherMap.\n'
    'Icons by Material Symbols.\n'
    'Built with Flutter.';

const String _privacyPolicyPlaceholder =
    'SmartGarden AI does not send your photos or garden data off this '
    "device — diagnosis, storage, and processing all happen locally. This "
    'is a placeholder and will be replaced with a full privacy policy '
    'before release.';

const String _termsPlaceholder =
    'By using SmartGarden AI you agree to use its plant diagnosis features '
    'for informational purposes only — they are not a substitute for '
    'professional horticultural advice. This is a placeholder and will be '
    'replaced with full terms of service before release.';

/// App-level configuration and info — theme, units, TTS, data, and About —
/// replacing the Phase 3 stub per ROADMAP.md Phase 15.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearData(BuildContext context) async {
    final provider = context.read<SettingsProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all garden data?'),
        content: const Text(
          'This permanently deletes every saved plant and scan. This '
          'cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await provider.clearGardenData();
    if (!context.mounted) return;
    context.read<MyGardenProvider>().loadPlants();
    context.read<ScanHistoryProvider>().loadScans();
    context.read<PlantHealthDashboardProvider>().loadSummary();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Garden data cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final settings = provider.settings;

    return Scaffold(
      appBar: const SmartGardenAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SectionHeader(title: 'Appearance'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: _ThemeModeSelector(
              value: settings.themeMode,
              onChanged: provider.setThemeMode,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Units'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: _TemperatureUnitSelector(
              value: settings.temperatureUnit,
              onChanged: provider.setTemperatureUnit,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Voice'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: _VoiceSettings(
              settings: settings.speechSettings,
              onRateChanged: provider.setSpeechRate,
              onPitchChanged: provider.setSpeechPitch,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Data'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: _ClearDataAction(
              isClearing: provider.isClearing,
              onClear: () => _confirmClearData(context),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'About'),
          const SizedBox(height: AppSpacing.sm),
          const AppCard(child: _AboutSection()),
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.value, required this.onChanged});

  final AppThemeMode value;
  final ValueChanged<AppThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AppThemeMode>(
      segments: const [
        ButtonSegment(
          value: AppThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
        ButtonSegment(
          value: AppThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: AppThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _TemperatureUnitSelector extends StatelessWidget {
  const _TemperatureUnitSelector({required this.value, required this.onChanged});

  final TemperatureUnit value;
  final ValueChanged<TemperatureUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TemperatureUnit>(
      segments: const [
        ButtonSegment(value: TemperatureUnit.celsius, label: Text('Celsius (°C)')),
        ButtonSegment(value: TemperatureUnit.fahrenheit, label: Text('Fahrenheit (°F)')),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _VoiceSettings extends StatefulWidget {
  const _VoiceSettings({
    required this.settings,
    required this.onRateChanged,
    required this.onPitchChanged,
  });

  final SpeechSettings settings;
  final ValueChanged<double> onRateChanged;
  final ValueChanged<double> onPitchChanged;

  @override
  State<_VoiceSettings> createState() => _VoiceSettingsState();
}

class _VoiceSettingsState extends State<_VoiceSettings> {
  late double _rate = widget.settings.rate;
  late double _pitch = widget.settings.pitch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Speech Rate', style: textTheme.titleSmall),
        Slider(
          value: _rate,
          min: SpeechSettings.minRate,
          max: SpeechSettings.maxRate,
          label: _rate.toStringAsFixed(2),
          onChanged: (value) => setState(() => _rate = value),
          onChangeEnd: widget.onRateChanged,
        ),
        Text('Speech Pitch', style: textTheme.titleSmall),
        Slider(
          value: _pitch,
          min: SpeechSettings.minPitch,
          max: SpeechSettings.maxPitch,
          label: _pitch.toStringAsFixed(2),
          onChanged: (value) => setState(() => _pitch = value),
          onChangeEnd: widget.onPitchChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        const ReadAloudControls(
          text: 'This is how care recommendations will sound.',
        ),
      ],
    );
  }
}

class _ClearDataAction extends StatelessWidget {
  const _ClearDataAction({required this.isClearing, required this.onClear});

  final bool isClearing;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clear Garden Data', style: textTheme.titleMedium),
              Text(
                'Permanently deletes every saved plant and scan.',
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm2),
        if (isClearing)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        else
          AppSecondaryButton(label: 'Clear', onPressed: onClear),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  Future<void> _showPlaceholderDialog(BuildContext context, String title, String body) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyContactEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _supportEmail));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email address copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final appInfoService = context.read<AppInfoService>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SmartGarden AI', style: textTheme.titleMedium),
        FutureBuilder<String>(
          future: appInfoService.getVersionLabel(),
          builder: (context, snapshot) => Text(
            snapshot.hasData ? 'Version ${snapshot.data}' : 'Version —',
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.favorite_outline),
          title: const Text('Credits'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showPlaceholderDialog(context, 'Credits', _creditsText),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.description_outlined),
          title: const Text('Licenses'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(context: context, applicationName: 'SmartGarden AI'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              _showPlaceholderDialog(context, 'Privacy Policy', _privacyPolicyPlaceholder),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.gavel_outlined),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showPlaceholderDialog(context, 'Terms of Service', _termsPlaceholder),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.mail_outline),
          title: const Text('Contact'),
          subtitle: const Text(_supportEmail),
          trailing: const Icon(Icons.copy_outlined),
          onTap: () => _copyContactEmail(context),
        ),
      ],
    );
  }
}
