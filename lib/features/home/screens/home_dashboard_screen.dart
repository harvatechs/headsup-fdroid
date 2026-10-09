import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/live_sensor_hud.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/recent_tap_tile.dart';
import '../../taps/providers/tap_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../map/widgets/tap_detail_sheet.dart';
import '../../../core/theme/app_theme.dart';

class HomeDashboardScreen extends ConsumerWidget {
  final void Function(int index)? onNavigateTab;

  const HomeDashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final tapsAsync = ref.watch(userTapsStreamProvider);
    final taps = tapsAsync.value ?? [];

    // Calculate quick metrics
    final totalTaps = taps.length;
    final headsUpTaps = taps.where((t) =>
        t.postureState.contains('Heads Up') || t.postureState.contains('Optimal')).length;
    final postureHealthPercent = totalTaps > 0
        ? ((headsUpTaps / totalTaps) * 100).round()
        : 100;
    final currentGeohash = taps.isNotEmpty ? taps.first.geohash.toUpperCase() : 'SCANNING';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.sensors, color: AppTheme.primaryLight, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Dashboard',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20, color: Color(0xFF94A3B8)),
            tooltip: 'Sign Out',
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.darkSurface,
                  title: Text(
                    'Sign Out',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    'Are you sure you want to sign out?',
                    style: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                ref.read(authControllerProvider.notifier).signOut();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Greeting & Zone Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user?.displayName ?? "Explorer"}',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.isAnonymous == true
                          ? 'Guest Mode • Cloud Sync Active'
                          : 'Pro Explorer • Synchronized',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                if (user?.isAnonymous == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      'GUEST',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.warning,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Live Posture Sensor HUD
            const LiveSensorHud(),

            const SizedBox(height: 16),

            // Quick Stats Row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Taps',
                    value: '$totalTaps',
                    icon: Icons.touch_app,
                    color: AppTheme.primaryLight,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Posture Index',
                    value: '$postureHealthPercent%',
                    icon: Icons.favorite,
                    color: AppTheme.postureHeadsUp,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Current Zone',
                    value: currentGeohash,
                    icon: Icons.pin_drop,
                    color: AppTheme.secondary,
                    isMonospace: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Central Hero Action Button
            const QuickActionButton(),

            const SizedBox(height: 24),

            // Recent Taps Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity Feed',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (taps.isNotEmpty && onNavigateTab != null)
                  TextButton.icon(
                    onPressed: () => onNavigateTab!(1), // Map tab
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('View on Map'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Recent Taps List
            if (taps.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.touch_app_outlined,
                      size: 40,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No taps recorded yet',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hit the pulsating button above to record your first GPS & sensor tap event.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: taps.length > 5 ? 5 : taps.length,
                itemBuilder: (context, index) {
                  final tap = taps[index];
                  return RecentTapTile(
                    tap: tap,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => TapDetailBottomSheet(tap: tap),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isMonospace;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: isMonospace
                ? GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )
                : GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
