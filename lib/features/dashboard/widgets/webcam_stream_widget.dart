import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../connection/providers/connection_provider.dart';
import 'fullscreen_webcam_view.dart';

class WebcamStreamWidget extends ConsumerWidget {
  const WebcamStreamWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(connectionSettingsProvider);
    final theme = Theme.of(context);

    if (settings == null) {
      return _buildPlaceholder(theme, 'Ağ Bağlantısı Bekleniyor');
    }

    // Usually OctoPrint webcam streams are hosted at /webcam/?action=stream
    final streamUrl = '${settings.baseUrl}/webcam/?action=stream';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    FullscreenWebcamView(streamUrl: streamUrl),
              ),
            );
          },
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RotatedBox(
                  quarterTurns: 2, // 180 degrees rotation
                  child: Mjpeg(
                    isLive: true,
                    error: (context, error, stack) => _buildPlaceholder(
                      theme,
                      'Kamera Bağlantı Hatası:\n$error',
                    ),
                    stream: streamUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme, String text) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
