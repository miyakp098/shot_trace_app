import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  late CameraController _controller;
  final Completer<bool> _cameraLoaded = Completer<bool>();
  bool _isZooming = false;
  bool _isTakingPicture = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.isNotEmpty ? cameras.first : throw StateError('No cameras available'),
      );

      _controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller.initialize();
      if (!_cameraLoaded.isCompleted) _cameraLoaded.complete(true);
      if (mounted) setState(() {});
    } on CameraException catch (e) {
      if (!_cameraLoaded.isCompleted) _cameraLoaded.completeError(e);
      if (mounted) {
        if (e.code == 'CameraAccessDenied') {
          showDialog<void>(
            context: context,
            builder: (context) => const AlertDialog(
              content: Text('カメラへのアクセスが許可されていません。設定から許可してください。'),
            ),
          );
        }
      }
    } catch (e) {
      if (!_cameraLoaded.isCompleted) _cameraLoaded.completeError(e);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_cameraLoaded.isCompleted) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraLoaded.isCompleted) return;
    final controller = _controller;
    if (!controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  Future<void> onTakePicture(BuildContext context) async {
    try {
      setState(() {
        _isTakingPicture = true;
      });
      final XFile image = await _controller.takePicture();
      setState(() {
        _imageFile = File(image.path);
      });
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _imageFile = null);
    } on CameraException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('撮影失敗: ${e.code}')));
    } finally {
      if (mounted) setState(() => _isTakingPicture = false);
    }
  }

  void zoomingChanged(bool? value) {
    if (value == null) return;
    setState(() {
      _isZooming = value;
    });
    _controller.setZoomLevel(_isZooming ? 2.0 : 1.0).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<bool>(
                future: _cameraLoaded.future,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return CameraPreview(_controller);
                },
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 16),
                      const Text('2倍ズーム'),
                      Switch(value: _isZooming, onChanged: zoomingChanged),
                    ],
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: (!_cameraLoaded.isCompleted || _isTakingPicture)
                          ? null
                          : () => onTakePicture(context),
                      child: const Text('撮影'),
                    ),
                  ),
                ],
              ),
            ),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.file(_imageFile!),
              ),
          ],
        ),
      ),
    );
  }
}
