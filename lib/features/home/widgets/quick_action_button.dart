import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../taps/providers/tap_provider.dart';
import '../../../core/theme/app_theme.dart';

class QuickActionButton extends ConsumerStatefulWidget {
  const QuickActionButton({super.key});

  @override
  ConsumerState<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends ConsumerState<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _isLogging = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLogging) return;
    setState(() => _isLogging = true);

    final tap = await ref.read(tapLoggerProvider.notifier).logCurrentTap(
      gestureType: 'hero_tap',
    );

    if (mounted) {
      setState(() => _isLogging = false);
      if (tap != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.accent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tap logged at ${tap.geohash.toUpperCase()}',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.darkCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.darkBorder),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      AppTheme.primaryLight,
                      AppTheme.primary,
                      AppTheme.primaryDark,
                    ],
                    center: Alignment(-0.2, -0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.45),
                      blurRadius: 30,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLogging) ...[
                        const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Logging...',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.touch_app_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'RECORD TAP',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'GPS + Sensor',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
