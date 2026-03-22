import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_theme.dart';
import 'industrial_widgets.dart';

/// Industrial-style location picker with a center pin marker
class LocationPickerDialog extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerDialog({super.key, this.initialLocation});

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final MapController _mapController = MapController();
  LatLng _centerLocation = const LatLng(28.6139, 77.2090); // Default Delhi
  String _addressDisplay = 'MOVE MAP TO SELECT';
  bool _isLoading = true;
  bool _isMoving = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _centerLocation = widget.initialLocation!;
    }
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      if (widget.initialLocation != null) {
        _centerLocation = widget.initialLocation!;
        setState(() => _isLoading = false);
        _updateAddressFromLatLng(_centerLocation);
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );

      _centerLocation = LatLng(position.latitude, position.longitude);
      setState(() => _isLoading = false);
      _updateAddressFromLatLng(_centerLocation);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final address = [
          place.street,
          place.subLocality,
          place.locality,
        ].where((s) => s != null && s.isNotEmpty).join(', ');

        setState(() {
          _addressDisplay = address.isNotEmpty ? address.toUpperCase() : 'LOCATION SELECTED';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _addressDisplay =
              '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  void _onCameraMoveStarted() {
    if (!_isMoving) {
      setState(() => _isMoving = true);
    }
  }

  void _onCameraIdle() {
    if (_isMoving) {
      setState(() => _isMoving = false);
      _updateAddressFromLatLng(_centerLocation);
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      final newLocation = LatLng(position.latitude, position.longitude);
      _mapController.move(newLocation, 16);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('UNABLE TO ACCESS GPS')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: HardShadowCard(
        padding: EdgeInsets.zero,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          color: AppTheme.surface,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _centerLocation,
                              initialZoom: 16,
                              onPositionChanged: (position, hasGesture) {
                                if (hasGesture) {
                                  _centerLocation = position.center;
                                }
                              },
                              onMapEvent: (event) {
                                if (event is MapEventMoveStart) {
                                  _onCameraMoveStarted();
                                } else if (event is MapEventMoveEnd) {
                                  _onCameraIdle();
                                }
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                                subdomains: const ['a', 'b', 'c', 'd'],
                                userAgentPackageName: 'com.foody.vrinda.v2',
                              ),
                            ],
                          ),
                          Center(child: _buildCenterPin()),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: _buildLocationFAB(),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            right: 12,
                            child: _buildAddressCard(),
                          ),
                        ],
                      ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_searching, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'PICK DELIVERY LOCATION',
              style: AppTheme.monoMedium.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
    );
  }

  Widget _buildCenterPin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 200),
          tween: Tween<double>(begin: 0, end: _isMoving ? -15 : 0),
          curve: Curves.easeOutCubic,
          builder: (context, translateY, child) {
            return Transform.translate(
              offset: Offset(0, translateY),
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [AppTheme.hardShadow],
                ),
              ),
              const Icon(Icons.location_on, color: Colors.white, size: 24),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationFAB() {
    return GestureDetector(
      onTap: _goToCurrentLocation,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.borderDark),
          boxShadow: const [AppTheme.hardShadow],
        ),
        child: const Icon(Icons.my_location, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.9),
        border: Border.all(color: AppTheme.borderDark),
        boxShadow: const [AppTheme.hardShadow],
      ),
      child: Row(
        children: [
          const Icon(Icons.pin_drop, color: AppTheme.primary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const MonoLabel('DELIVERY AREA'),
                const SizedBox(height: 2),
                Text(
                  _isMoving ? 'SELECTING...' : _addressDisplay,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _centerLocation),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  boxShadow: [AppTheme.hardShadow],
                ),
                child: Center(
                  child: Text(
                    'CONFIRM LOCATION',
                    style: AppTheme.monoLarge.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
