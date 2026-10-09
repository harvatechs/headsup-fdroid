import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../taps/models/tap_event.dart';
import '../../taps/providers/tap_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class TapDetailBottomSheet extends ConsumerWidget {
  final TapEvent tap;

  const TapDetailBottomSheet({super.key, required this.tap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHeadsUp = tap.postureState.contains('Heads Up') ||
        tap.postureState.contains('Optimal');

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header: Posture Status & Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isHeadsUp ? AppTheme.postureHeadsUp : AppTheme.postureTilted)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isHeadsUp ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                      color: isHeadsUp ? AppTheme.postureHeadsUp : AppTheme.postureTilted,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tap.postureState,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        Formatters.formatRelativeTime(tap.timestamp),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                tooltip: 'Delete tap',
                onPressed: () {
                  ref.read(tapLoggerProvider.notifier).deleteTap(tap.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppTheme.darkBorder),
          const SizedBox(height: 16),

          // Info Grid
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.location_on_outlined,
                  label: 'GPS Coordinates',
                  value: Formatters.formatCoordinates(tap.latitude, tap.longitude),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.grid_view_rounded,
                  label: 'Geohash',
                  value: tap.geohash.toUpperCase(),
                  isMonospace: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.screen_rotation_alt,
                  label: 'Pitch / Roll',
                  value: '${Formatters.formatAngle(tap.pitch)} / ${Formatters.formatAngle(tap.roll)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.touch_app_outlined,
                  label: 'Gesture Type',
                  value: tap.gestureType.replaceAll('_', ' ').toUpperCase(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Recorded: ${Formatters.formatDateTime(tap.timestamp)}',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.primaryLight),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: isMonospace
                ? GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )
                : GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
