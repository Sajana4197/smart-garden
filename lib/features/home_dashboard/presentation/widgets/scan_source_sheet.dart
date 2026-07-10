import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../gallery/domain/usecases/store_picked_photo.dart';

/// Camera/Gallery choice sheet for the Home Dashboard's quick-scan CTA —
/// M3 modal bottom sheet per UI_GUIDELINES.md §6.
Future<void> showScanSourceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusLarge),
      ),
    ),
    builder: (context) => const _ScanSourceSheet(),
  );
}

class _ScanSourceSheet extends StatelessWidget {
  const _ScanSourceSheet();

  Future<void> _pickFromGallery(BuildContext context) async {
    final storePickedPhoto = context.read<StorePickedPhoto>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();

    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final storedPath = await storePickedPhoto(picked.path);
      router.push(AppRoutes.preview, extra: storedPath);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Couldn't access your photos. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => _pickFromGallery(context),
            ),
          ],
        ),
      ),
    );
  }
}
