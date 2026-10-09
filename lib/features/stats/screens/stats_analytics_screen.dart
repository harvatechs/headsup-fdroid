import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/metric_summary_card.dart';
import '../widgets/activity_chart_widget.dart';
import '../../taps/providers/tap_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class StatsAnalyticsScreen extends ConsumerWidget {
  const StatsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tapsAsync = ref.watch(userTapsStreamProvider);
    final taps = tapsAsync.value ?? [];

    // Aggregations
    final totalTaps = taps.length;
    final headsUpTaps = taps.where((t) =>
        t.postureState.contains('Heads Up') || t.postureState.contains('Optimal')).length;
    final tiltedTaps = taps.where((t) =>
        t.postureState.contains('Down') || t.postureState.contains('Bad')).length;
    final otherTaps = totalTaps - headsUpTaps - tiltedTaps;

    final postureScore = totalTaps > 0
        ? ((headsUpTaps / totalTaps) * 100).round()
        : 100;

    // Unique Geohashes
    final geohashCounts = <String, int>{};
    for (final tap in taps) {
      final code = tap.geohash.toUpperCase();
      if (code.isNotEmpty) {
        geohashCounts[code] = (geohashCounts[code] ?? 0) + 1;
      }
    }
    final sortedGeohashes = geohashCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final uniqueZonesCount = sortedGeohashes.length;

    // Average Pitch
    final totalPitch = taps.fold<double>(0.0, (acc, t) => acc + t.pitch.abs());
    final avgPitch = totalTaps > 0 ? (totalPitch / totalTaps) : 0.0;

    // Hourly Distribution (0-23)
    final hourlyDist = <int, int>{};
    for (final tap in taps) {
      final hour = tap.timestamp.hour;
      hourlyDist[hour] = (hourlyDist[hour] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics & Metrics',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // KPI Cards Grid
            Row(
              children: [
                Expanded(
                  child: MetricSummaryCard(
                    title: 'Total Logs',
                    value: '$totalTaps',
                    subtitle: 'Lifetime interactions',
                    icon: Icons.touch_app,
                    accentColor: AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricSummaryCard(
                    title: 'Posture Quality',
                    value: '$postureScore%',
                    subtitle: 'Heads Up compliance',
                    icon: Icons.health_and_safety_outlined,
                    accentColor: AppTheme.postureHeadsUp,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricSummaryCard(
                    title: 'Unique Zones',
                    value: '$uniqueZonesCount',
                    subtitle: 'Geohashes visited',
                    icon: Icons.travel_explore,
                    accentColor: AppTheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricSummaryCard(
                    title: 'Avg Pitch Tilt',
                    value: Formatters.formatAngle(avgPitch),
                    subtitle: 'Device inclination',
                    icon: Icons.screen_rotation_alt,
                    accentColor: AppTheme.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 24h Activity Distribution Chart
            ActivityChartWidget(hourlyDistribution: hourlyDist),

            const SizedBox(height: 20),

            // Posture Breakdown Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Posture Breakdown',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PostureBar(
                    label: 'Heads Up (Optimal)',
                    count: headsUpTaps,
                    total: totalTaps,
                    color: AppTheme.postureHeadsUp,
                  ),
                  const SizedBox(height: 12),
                  _PostureBar(
                    label: 'Looking Down (Bad Angle)',
                    count: tiltedTaps,
                    total: totalTaps,
                    color: AppTheme.postureDown,
                  ),
                  const SizedBox(height: 12),
                  _PostureBar(
                    label: 'Neutral / Incline / Flat',
                    count: otherTaps,
                    total: totalTaps,
                    color: AppTheme.secondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Top Geohash Hotspots
            Container(
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
                        'Top Geohash Hotspots',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Cluster Rank',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (sortedGeohashes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No spatial data recorded yet.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    )
                  else
                    ...sortedGeohashes.take(5).map((entry) {
                      final rank = sortedGeohashes.indexOf(entry) + 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$rank',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryLight,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  entry.key,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.darkSurface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.darkBorder),
                              ),
                              child: Text(
                                '${entry.value} tap${entry.value == 1 ? '' : 's'}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostureBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _PostureBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total) : 0.0;
    final percentInt = (percentage * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            Text(
              '$count ($percentInt%)',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppTheme.darkSurface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
