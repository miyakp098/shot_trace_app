import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late CameraController _controller;
  final Completer<bool> _cameraLoaded = Completer<bool>();
  bool _isRecording = false;
  String? _videoPath;

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
        orElse: () => cameras.isNotEmpty
            ? cameras.first
            : throw StateError('No cameras available'),
      );

      _controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: true,
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
              title: Text('権限が必要です'),
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

  // 画像撮影は行わず、録画トグルを提供します
  Future<void> _toggleVideoRecording(BuildContext context) async {
    if (!_cameraLoaded.isCompleted) return;
    try {
      if (!_isRecording) {
        await _controller.prepareForVideoRecording();
        await _controller.startVideoRecording();
        if (mounted) setState(() => _isRecording = true);
      } else {
        final XFile file = await _controller.stopVideoRecording();
        if (mounted) setState(() => _isRecording = false);
        _videoPath = file.path;
        try {
          final bool? result = await GallerySaver.saveVideo(
            file.path,
            albumName: 'Shot Trace App',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result == true ? '動画を保存しました' : '動画の保存に失敗しました'),
              ),
            );
          }
        } catch (e) {
          if (mounted)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('動画保存中にエラーが発生しました')));
        }
      }
    } on CameraException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('録画エラー: ${e.code}')));
      if (mounted) setState(() => _isRecording = false);
    }
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
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Positioned.fill(child: CameraPreview(_controller)),
                          Center(
                            child: SizedBox(
                              // TODO: オーバーレイ画像のサイズを後で調整する
                              width: constraints.maxWidth * 0.25,
                              height: constraints.maxWidth * 0.25,
                              child: IgnorePointer(
                                child: SvgPicture.asset(
                                  'assets/overlays/svg/ball.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Stack(
                children: [
                  // Zoom control removed for now; will implement later.
                  Center(
                    child: ElevatedButton(
                      onPressed: (!_cameraLoaded.isCompleted)
                          ? null
                          : () => _toggleVideoRecording(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording ? Colors.red : null,
                      ),
                      child: Text(_isRecording ? '録画停止' : '録画開始'),
                    ),
                  ),
                ],
              ),
            ),
            // 画像プレビューは無効（動画専用のため）
          ],
        ),
      ),
    );
  }
}
