import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FullscreenWebcamView extends ConsumerStatefulWidget {
  final String streamUrl;

  const FullscreenWebcamView({super.key, required this.streamUrl});

  @override
  ConsumerState<FullscreenWebcamView> createState() =>
      _FullscreenWebcamViewState();
}

class _FullscreenWebcamViewState extends ConsumerState<FullscreenWebcamView> {
  @override
  void initState() {
    super.initState();
    // Force landscape mode when entering fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    // Hide status bar and navigation bar in fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore preferred orientations and UI overlays when leaving fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: RotatedBox(
                quarterTurns: 2, // Rotate 180 degrees
                child: Mjpeg(
                  isLive: true,
                  stream: widget.streamUrl,
                  fit: BoxFit.contain,
                  error: (context, error, stack) => const Center(
                    child: Text(
                      'Kamera Bağlantı Hatası',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
