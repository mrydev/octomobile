import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../connection/providers/connection_provider.dart';
import '../providers/print_job_provider.dart';

class PrintProgressWidget extends ConsumerWidget {
  const PrintProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobState = ref.watch(printJobProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final progress = jobState.progress;
    final status = jobState.status;
    final fileName = jobState.fileName;
    final printTimeLeft = jobState.printTimeLeft;
    final printTime = jobState.printTime;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: _getStatusColor(status, theme),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      fileName.isNotEmpty ? fileName : l10n.noFilesFound,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Circular Progress Indicator
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress > 0 ? progress / 100 : 0,
                  strokeWidth: 12,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: theme.colorScheme.primary,
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${progress.toStringAsFixed(1)}%',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        l10n.progress,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeStat(l10n.elapsed, _formatDuration(printTime), theme),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                _buildTimeStat(l10n.eta, _formatDuration(printTimeLeft), theme),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              final s = status.toLowerCase();
              final isPrinting = s.contains('printing');
              final isPaused = s.contains('paus');

              if (isPrinting || isPaused) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (isPrinting)
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.pause),
                            label: Text(l10n.pause),
                            onPressed: () =>
                                _handleAction(context, ref, 'pause'),
                          ),
                        ),
                      if (isPaused)
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l10n.resume),
                            onPressed: () =>
                                _handleAction(context, ref, 'resume'),
                          ),
                        ),
                      if (isPrinting || isPaused) const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.error,
                            side: BorderSide(color: theme.colorScheme.error),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.cancel),
                          label: Text(l10n.cancel),
                          onPressed: () =>
                              _handleConfirmCancel(context, ref, l10n),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    final apiClient = ref.read(apiClientProvider);
    if (action == 'pause') apiClient?.pausePrint();
    if (action == 'resume') apiClient?.resumePrint();
  }

  void _handleConfirmCancel(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelPrintTitle),
        content: Text(l10n.cancelPrintDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(apiClientProvider)?.cancelPrint();
              Navigator.pop(context);
            },
            child: Text(l10n.yesCancel),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeStat(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    final s = status.toLowerCase();
    if (s.contains('printing')) {
      return theme.colorScheme.primary;
    }
    if (s.contains('paus')) {
      return theme.colorScheme.secondary;
    }
    if (s.contains('error') || s.contains('offline')) {
      return theme.colorScheme.error;
    }
    return theme.colorScheme.onSurface;
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return "--:--:--";
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
