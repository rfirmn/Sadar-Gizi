import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService extends StatefulWidget {
  final CameraDescription camera;
  const CameraService({super.key, required this.camera});

  @override
  State<CameraService> createState() => _CameraServiceState();
}

class _CameraServiceState extends State<CameraService>
    with WidgetsBindingObserver {
  CameraController? controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    controller = CameraController(
      widget.camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup:
          Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    try {
      await controller!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(controller!),
                Align(
                  alignment: const Alignment(0, 0.9),
                  child: FloatingActionButton(
                    heroTag: "capture-image",
                    tooltip: "Capture Image",
                    onPressed: _onCaptureImage,
                    child: const Icon(Icons.camera_alt_outlined),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _onCaptureImage() async {
    try {
      final image = await controller?.takePicture();
      if (image != null) {
        Navigator.pop(context, File(image.path));
      }
    } catch (e) {
      debugPrint("Error capturing image: $e");
    }
  }
}
