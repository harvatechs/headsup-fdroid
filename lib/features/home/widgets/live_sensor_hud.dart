import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/sensor_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../taps/providers/tap_provider.dart';

class LiveSensorHud extends ConsumerWidget {
  const LiveSensorHud({super.key});

  Color _getCategoryColor(PostureCategory category) {
    switch (category) {
      case PostureCategory.headsUp:
        return AppTheme.postureHeadsUp;
      case PostureCategory.neutral:
        return AppTheme.postureNeutral;
      case PostureCategory.tiltedLateral:
        return AppTheme.postureTilted;
      case PostureCategory.tiltedDown:
      case PostureCategory.flat:
        return AppTheme.postureDown;
    }
  }

  IconData _getCategoryIcon(PostureCategory category) {
    switch (category) {
      case PostureCategory.headsUp:
        return Icons.sentiment_very_satisfied;
      case PostureCategory.neutral:
        return Icons.sentiment_satisfied;
      case PostureCategory.tiltedLateral:
        return Icons.screen_rotation;
      case PostureCategory.tiltedDown:
        return Icons.arrow_downward;
      case PostureCategory.flat:
        return Icons.phone_android;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postureAsync = ref.watch(postureStreamProvider);
    final posture = postureAsync.value ?? ref.read(sensorServiceProvider).currentPosture;

    final statusColor = _getCategoryColor(posture.category);
    final statusIcon = _getCategoryIcon(posture.category);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Status Badge & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Posture Sensor',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        posture.label,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'LIVE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Visual Tilt Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ((posture.pitch.abs() / 90.0).clamp(0.0, 1.0)),
              backgroundColor: AppTheme.darkSurface,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 14),

          // Angle Metric Pills
          Row(
            children: [
              Expanded(
                child: _AnglePill(
                  label: 'Pitch (Tilt)',
                  value: Formatters.formatAngle(posture.pitch),
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AnglePill(
                  label: 'Roll (Side)',
                  value: Formatters.formatAngle(posture.roll),
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AnglePill(
                  label: 'Z-Axis',
                  value: '${posture.z.toStringAsFixed(1)} m/s²',
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnglePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AnglePill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
