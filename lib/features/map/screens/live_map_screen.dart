import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../taps/models/tap_event.dart';
import '../../taps/providers/tap_provider.dart';
import '../widgets/map_controls_overlay.dart';
import '../widgets/tap_detail_sheet.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';

class LiveMapScreen extends ConsumerStatefulWidget {
  const LiveMapScreen({super.key});

  @override
  ConsumerState<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends ConsumerState<LiveMapScreen> {
  final MapController _mapController = MapController();
  bool _isDarkModeLayer = true;
  bool _showAllUsers = false;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _fetchCurrentPosition();
  }

  Future<void> _fetchCurrentPosition() async {
    final locationService = ref.read(locationServiceProvider);
    final loc = await locationService.getCurrentLocation();
    if (loc != null && loc.latitude != null && loc.longitude != null && mounted) {
      setState(() {
        _userLocation = LatLng(loc.latitude!, loc.longitude!);
      });
      _mapController.move(_userLocation!, AppConstants.defaultZoom);
    }
  }

  void _recenterOnUser() async {
    final locationService = ref.read(locationServiceProvider);
    final loc = await locationService.getCurrentLocation();
    if (loc != null && loc.latitude != null && loc.longitude != null) {
      final target = LatLng(loc.latitude!, loc.longitude!);
      setState(() {
        _userLocation = target;
      });
      _mapController.move(target, 16.0);
    } else if (_userLocation != null) {
      _mapController.move(_userLocation!, 16.0);
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void _showTapDetails(TapEvent tap) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => TapDetailBottomSheet(tap: tap),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userTapsAsync = ref.watch(userTapsStreamProvider);
    final allTapsAsync = ref.watch(allTapsStreamProvider);

    final tapList = _showAllUsers
        ? (allTapsAsync.value ?? [])
        : (userTapsAsync.value ?? []);

    final tileUrl = _isDarkModeLayer
        ? AppConstants.cartoDarkTileUrl
        : AppConstants.osmTileUrl;

    return Scaffold(
      body: Stack(
        children: [
          // Flutter Map View
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation ?? AppConstants.defaultLocation,
              initialZoom: AppConstants.defaultZoom,
              minZoom: 3,
              maxZoom: 19,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              // Tile Layer
              TileLayer(
                urlTemplate: tileUrl,
                userAgentPackageName: AppConstants.mapUserAgent,
                maxZoom: 19,
              ),

              // Marker Layer for Tap Events
              MarkerLayer(
                markers: [
                  // User Current Position Marker
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.secondary.withValues(alpha: 0.25),
                        ),
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.secondary,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondary.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Tap Events Markers
                  ...tapList.map((tap) {
                    final isHeadsUp = tap.postureState.contains('Heads Up') ||
                        tap.postureState.contains('Optimal');
                    final markerColor = isHeadsUp
                        ? AppTheme.postureHeadsUp
                        : AppTheme.postureTilted;

                    return Marker(
                      point: LatLng(tap.latitude, tap.longitude),
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => _showTapDetails(tap),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: markerColor,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: markerColor.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.touch_app,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Top Info HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.map_outlined,
                            size: 18,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${tapList.length} Tap Location${tapList.length == 1 ? '' : 's'}',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _userLocation != null
                                  ? Formatters.formatCoordinates(
                                      _userLocation!.latitude,
                                      _userLocation!.longitude,
                                    )
                                  : 'Acquiring GPS...',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Filter Toggle Chip
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAllUsers = !_showAllUsers;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _showAllUsers
                              ? AppTheme.primary
                              : AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _showAllUsers ? AppTheme.primary : AppTheme.darkBorder,
                          ),
                        ),
                        child: Text(
                          _showAllUsers ? 'All Taps' : 'My Taps',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _showAllUsers ? Colors.white : const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Map Action Buttons (Right Overlay)
          MapControlsOverlay(
            onRecenter: _recenterOnUser,
            onToggleLayer: () {
              setState(() {
                _isDarkModeLayer = !_isDarkModeLayer;
              });
            },
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
            isDarkModeLayer: _isDarkModeLayer,
          ),
        ],
      ),
    );
  }
}
