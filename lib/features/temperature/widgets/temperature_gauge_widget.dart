import 'package:flutter/material.dart';
import 'dart:math';

class TemperatureGaugeWidget extends StatelessWidget {
  final String title;
  final double currentTemp;
  final double targetTemp;
  final double maxTemp;
  final Color activeColor;
  final VoidCallback? onTap;

  const TemperatureGaugeWidget({
    super.key,
    required this.title,
    required this.currentTemp,
    required this.targetTemp,
    this.maxTemp = 300.0,
    required this.activeColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (currentTemp / maxTemp).clamp(0.0, 1.0);
    final targetPercentage = (targetTemp / maxTemp).clamp(0.0, 1.0);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                width: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Gauge Background
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 8,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    // Current Temp Gauge
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 8,
                        color: activeColor,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Target Indicator (optional overlay)
                    if (targetTemp > 0)
                      Transform.rotate(
                        angle: targetPercentage * 2 * pi,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 4,
                            height: 14,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    // Text values
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${currentTemp.toStringAsFixed(1)}°',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: activeColor,
                          ),
                        ),
                        if (targetTemp > 0)
                          Text(
                            '${targetTemp.toStringAsFixed(0)}°',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
