import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class ActivityChartWidget extends StatelessWidget {
  final Map<int, int> hourlyDistribution; // Hour (0-23) -> Count

  const ActivityChartWidget({
    super.key,
    required this.hourlyDistribution,
  });

  @override
  Widget build(BuildContext context) {
    int maxCount = 1;
    for (final count in hourlyDistribution.values) {
      if (count > maxCount) maxCount = count;
    }

    // Generate 6 sample interval blocks: 00, 04, 08, 12, 16, 20
    final intervals = [0, 4, 8, 12, 16, 20];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hourly Activity Distribution',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '24h Timeline',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bar Chart Visualizer
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(24, (hour) {
                final count = hourlyDistribution[hour] ?? 0;
                final heightFraction = count == 0 ? 0.05 : (count / maxCount);
                final isPeak = count == maxCount && count > 0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Tooltip(
                          message: '$hour:00 - $count tap${count == 1 ? '' : 's'}',
                          child: Container(
                            height: 100 * heightFraction,
                            decoration: BoxDecoration(
                              color: isPeak
                                  ? AppTheme.secondary
                                  : (count > 0
                                      ? AppTheme.primary
                                      : AppTheme.darkSurface),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 10),

          // Axis Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: intervals.map((hour) {
              final label = hour == 0
                  ? '12 AM'
                  : (hour < 12 ? '$hour AM' : (hour == 12 ? '12 PM' : '${hour - 12} PM'));
              return Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF64748B),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
