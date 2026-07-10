import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../domain/usecases/store_captured_photo.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  String? _errorMessage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() => _errorMessage = null);
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No camera was found on this device.');
        return;
      }
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException catch (e) {
      final isDenied = e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted';
      setState(() {
        _errorMessage = isDenied
            ? 'Camera access was denied. Enable it in your device settings '
                'to scan plants.'
            : 'Could not start the camera. Please try again.';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _isCapturing) return;

    setState(() => _isCapturing = true);
    final storeCapturedPhoto = context.read<StoreCapturedPhoto>();
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await controller.takePicture();
      final storedPath = await storeCapturedPhoto(file.path);
      if (!mounted) return;
      router.push(AppRoutes.preview, extra: storedPath);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Couldn't capture the photo. Please try again."),
        ),
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_errorMessage != null) {
      return SizedBox.expand(
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: ErrorStateWidget(
            title: 'Camera unavailable',
            message: _errorMessage!,
            retryLabel: 'Try Again',
            onRetry: _initializeCamera,
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: AppLoadingIndicator(),
      );
    }

    // A camera viewfinder stays black chrome regardless of app theme, same
    // as any camera app — the live preview is the content, not a themed
    // surface (see UI_GUIDELINES.md §2's image-overlay rule).
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        Positioned(
          left: 0,
          right: 0,
          bottom: AppSpacing.xxl,
          child: Center(
            child: _CaptureButton(isBusy: _isCapturing, onPressed: _capture),
          ),
        ),
      ],
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.isBusy, required this.onPressed});

  final bool isBusy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Capture photo',
      child: GestureDetector(
        onTap: isBusy ? null : onPressed,
        child: Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.white54, width: 4),
            ),
          ),
          child: isBusy
              ? const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : null,
        ),
      ),
    );
  }
}
