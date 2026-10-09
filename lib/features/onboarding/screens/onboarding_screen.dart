import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/haptics_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      icon: Icons.location_on_rounded,
      title: 'Precision Geospatial Tagging',
      description:
          'Every tap captures exact latitude, longitude, and computes a standardized geohash for spatial clustering.',
      accentColor: AppTheme.primaryLight,
    ),
    _OnboardingItem(
      icon: Icons.sensors_rounded,
      title: '3D Posture & Motion Sensor',
      description:
          'Real-time accelerometer and gyroscope streams monitor device tilt and inclination, classifying your posture health.',
      accentColor: AppTheme.postureHeadsUp,
    ),
    _OnboardingItem(
      icon: Icons.map_rounded,
      title: 'Live Interactive Map & Cloud Sync',
      description:
          'Inspect your activity hotspots on real OpenStreetMap layers, backed by real-time Firestore persistence.',
      accentColor: AppTheme.secondary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticsService.lightImpact();
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentPage];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: widget.onFinish,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final pageItem = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pageItem.accentColor.withValues(alpha: 0.15),
                            border: Border.all(
                              color: pageItem.accentColor.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            pageItem.icon,
                            size: 56,
                            color: pageItem.accentColor,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          pageItem.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          pageItem.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.5,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Indicators & Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? item.accentColor
                              : AppTheme.darkBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.accentColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentPage == _items.length - 1 ? 'Get Started' : 'Next',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
  });
}
