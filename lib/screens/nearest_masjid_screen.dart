import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:i_app/utils/api_key.dart';
import 'package:provider/provider.dart';

import '../constants/app_theme.dart';
import '../providers/app_provider.dart';

class NearestMasjidScreen extends StatefulWidget {
  const NearestMasjidScreen({super.key});

  @override
  State<NearestMasjidScreen> createState() => _NearestMasjidScreenState();
}

class _NearestMasjidScreenState extends State<NearestMasjidScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _error;
  final Set<Marker> _markers = {};

  // TODO: Replace with your actual Places API key and keep it out of source control
  static  String _googlePlacesApiKey = APIKEY().google_map_key;

  @override
  void initState() {
    super.initState();
    _initLocationAndMasajid();
  }

  Future<void> _initLocationAndMasajid() async {
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        setState(() {
          _error = 'Location permission denied. Enable location to find nearby masajid.';
          _isLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = currentLatLng;
      });

      await _fetchNearbyMasajid(currentLatLng);
    } catch (e) {
      setState(() {
        _error = 'Failed to load nearby masajid.';
        _isLoading = false;
      });
    }
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _fetchNearbyMasajid(LatLng location) async {
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${location.latitude},${location.longitude}'
        '&radius=5000'
        '&type=mosque'
        '&key=$_googlePlacesApiKey',
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        setState(() {
          _error = 'Unable to fetch nearby masajid.';
          _isLoading = false;
        });
        return;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = (data['results'] as List<dynamic>? ?? []);

      final markers = <Marker>{};
      for (final result in results) {
        final geometry = result['geometry']?['location'];
        if (geometry == null) continue;

        final lat = (geometry['lat'] as num).toDouble();
        final lng = (geometry['lng'] as num).toDouble();
        final name = result['name'] as String? ?? 'Masjid';
        final vicinity = result['vicinity'] as String? ?? '';

        markers.add(
          Marker(
            markerId: MarkerId('${lat}_$lng'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: name,
              snippet: vicinity,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }

      setState(() {
        _markers
          ..clear()
          ..addAll(markers);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch nearby masajid.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Nearest Masjid'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: AppTheme.gradientBackground(appProvider.themeMode),
        child: _buildBody(isDark),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_currentPosition == null) {
      return const Center(child: Text('Location not available'));
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _currentPosition!,
        zoom: 14,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: _markers,
      onMapCreated: (controller) {
        if (!_mapController.isCompleted) {
          _mapController.complete(controller);
        }
      },
    );
  }
}
