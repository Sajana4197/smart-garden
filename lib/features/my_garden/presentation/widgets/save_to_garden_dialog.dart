import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

/// Values collected from [SaveToGardenDialog] — a new nickname, a confirmed
/// (editable) species, and optional notes, per ROADMAP.md Phase 9's "Save to
/// My Garden" flow.
class SaveToGardenDialogResult {
  const SaveToGardenDialogResult({required this.name, this.species, this.notes});

  final String name;
  final String? species;
  final String? notes;
}

/// Also reused by `PlantDetailScreen`'s Edit action with the plant's current
/// values pre-filled, since the fields being collected are identical.
class SaveToGardenDialog extends StatefulWidget {
  const SaveToGardenDialog({
    super.key,
    this.title = 'Save to My Garden',
    this.initialName,
    this.initialSpecies,
    this.initialNotes,
  });

  final String title;
  final String? initialName;
  final String? initialSpecies;
  final String? initialNotes;

  static Future<SaveToGardenDialogResult?> show(
    BuildContext context, {
    String title = 'Save to My Garden',
    String? initialName,
    String? initialSpecies,
    String? initialNotes,
  }) {
    return showDialog<SaveToGardenDialogResult>(
      context: context,
      builder: (_) => SaveToGardenDialog(
        title: title,
        initialName: initialName,
        initialSpecies: initialSpecies,
        initialNotes: initialNotes,
      ),
    );
  }

  @override
  State<SaveToGardenDialog> createState() => _SaveToGardenDialogState();
}

class _SaveToGardenDialogState extends State<SaveToGardenDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _speciesController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _speciesController = TextEditingController(text: widget.initialSpecies ?? '');
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      SaveToGardenDialogResult(
        name: _nameController.text.trim(),
        species: _speciesController.text.trim().isEmpty
            ? null
            : _speciesController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Plant name'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Give your plant a name'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _speciesController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Species'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
