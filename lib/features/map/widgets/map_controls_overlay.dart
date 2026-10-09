import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/haptics_service.dart';

class MapControlsOverlay extends StatelessWidget {
  final VoidCallback onRecenter;
  final VoidCallback onToggleLayer;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final bool isDarkModeLayer;

  const MapControlsOverlay({
    super.key,
    required this.onRecenter,
    required this.onToggleLayer,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.isDarkModeLayer,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapButton(
            icon: isDarkModeLayer ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: 'Toggle Map Style',
            onTap: () {
              HapticsService.lightImpact();
              onToggleLayer();
            },
          ),
          const SizedBox(height: 10),
          _MapButton(
            icon: Icons.add,
            tooltip: 'Zoom In',
            onTap: () {
              HapticsService.lightImpact();
              onZoomIn();
            },
          ),
          const SizedBox(height: 6),
          _MapButton(
            icon: Icons.remove,
            tooltip: 'Zoom Out',
            onTap: () {
              HapticsService.lightImpact();
              onZoomOut();
            },
          ),
          const SizedBox(height: 10),
          _MapButton(
            icon: Icons.my_location,
            tooltip: 'Locate Me',
            isPrimary: true,
            onTap: () {
              HapticsService.lightImpact();
              onRecenter();
            },
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isPrimary;

  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isPrimary ? AppTheme.primary : AppTheme.darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: AppTheme.darkBorder, width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : const Color(0xFFE2E8F0),
            ),
          ),
        ),
      ),
    );
  }
}
