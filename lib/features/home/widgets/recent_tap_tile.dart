import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../taps/models/tap_event.dart';
import '../../taps/providers/tap_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class RecentTapTile extends ConsumerWidget {
  final TapEvent tap;
  final VoidCallback? onTap;

  const RecentTapTile({
    super.key,
    required this.tap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHeadsUp = tap.postureState.contains('Heads Up') ||
        tap.postureState.contains('Optimal');
    final badgeColor = isHeadsUp ? AppTheme.postureHeadsUp : AppTheme.postureTilted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isHeadsUp ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: badgeColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                tap.geohash.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                Formatters.formatCoordinates(tap.latitude, tap.longitude),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFFE2E8F0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                Formatters.formatRelativeTime(tap.timestamp),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•  Pitch: ${Formatters.formatAngle(tap.pitch)}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF64748B)),
          tooltip: 'Delete tap',
          onPressed: () {
            ref.read(tapLoggerProvider.notifier).deleteTap(tap.id);
          },
        ),
      ),
    );
  }
}
