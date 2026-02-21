import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../connection/providers/connection_provider.dart';

class MovementControlWidget extends ConsumerStatefulWidget {
  const MovementControlWidget({super.key});

  @override
  ConsumerState<MovementControlWidget> createState() =>
      _MovementControlWidgetState();
}

class _MovementControlWidgetState extends ConsumerState<MovementControlWidget> {
  // Separate distances for movement and extrusion
  double _distance = 10.0;
  double _extrusionDistance = 5.0; // Default extrusion amount

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final apiClient = ref.read(apiClientProvider);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Head Movement Distance Selector
            Text(
              l10n.headMovement,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DistanceButton(
                  label: '0.1',
                  isSelected: _distance == 0.1,
                  onTap: () => setState(() => _distance = 0.1),
                ),
                _DistanceButton(
                  label: '1',
                  isSelected: _distance == 1.0,
                  onTap: () => setState(() => _distance = 1.0),
                ),
                _DistanceButton(
                  label: '10',
                  isSelected: _distance == 10.0,
                  onTap: () => setState(() => _distance = 10.0),
                ),
                _DistanceButton(
                  label: '50',
                  isSelected: _distance == 50.0,
                  onTap: () => setState(() => _distance = 50.0),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // XY Pad and Z Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // XY Cross
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: _JogButton(
                          icon: Icons.keyboard_arrow_up,
                          onPressed: () => apiClient?.jog(y: _distance),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _JogButton(
                          icon: Icons.keyboard_arrow_down,
                          onPressed: () => apiClient?.jog(y: -_distance),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _JogButton(
                          icon: Icons.keyboard_arrow_left,
                          onPressed: () => apiClient?.jog(x: -_distance),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _JogButton(
                          icon: Icons.keyboard_arrow_right,
                          onPressed: () => apiClient?.jog(x: _distance),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: _JogButton(
                          icon: Icons.home,
                          color: theme.colorScheme.primary,
                          onPressed: () => apiClient?.home(['x', 'y']),
                        ),
                      ),
                    ],
                  ),
                ),

                // Z Controls
                Column(
                  children: [
                    _JogButton(
                      icon: Icons.keyboard_double_arrow_up,
                      onPressed: () => apiClient?.jog(z: _distance),
                    ),
                    const SizedBox(height: 8),
                    _JogButton(
                      icon: Icons.home,
                      color: theme.colorScheme.primary,
                      onPressed: () => apiClient?.home(['z']),
                    ),
                    const SizedBox(height: 8),
                    _JogButton(
                      icon: Icons.keyboard_double_arrow_down,
                      onPressed: () => apiClient?.jog(z: -_distance),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => apiClient?.home(['x', 'y', 'z']),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Home All Axes'),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Extrusion Distance Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DistanceButton(
                  label: '1',
                  isSelected: _extrusionDistance == 1.0,
                  onTap: () => setState(() => _extrusionDistance = 1.0),
                ),
                _DistanceButton(
                  label: '5',
                  isSelected: _extrusionDistance == 5.0,
                  onTap: () => setState(() => _extrusionDistance = 5.0),
                ),
                _DistanceButton(
                  label: '10',
                  isSelected: _extrusionDistance == 10.0,
                  onTap: () => setState(() => _extrusionDistance = 10.0),
                ),
                _DistanceButton(
                  label: '50',
                  isSelected: _extrusionDistance == 50.0,
                  onTap: () => setState(() => _extrusionDistance = 50.0),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Extruder Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                    onPressed: () =>
                        apiClient?.extrude(-_extrusionDistance), // Retract
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('Retract'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    onPressed: () =>
                        apiClient?.extrude(_extrusionDistance), // Extrude
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Extrude'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DistanceButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DistanceButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
    );
  }
}

class _JogButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _JogButton({required this.icon, required this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: color ?? theme.colorScheme.onSurface,
        onPressed: onPressed,
      ),
    );
  }
}
