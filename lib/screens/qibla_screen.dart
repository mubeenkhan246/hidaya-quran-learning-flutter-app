import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class QiblaScreen extends StatefulWidget {
  final bool showBackButton;
  const QiblaScreen({super.key, this.showBackButton = false});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  double? _qiblaDirection;
  double? _deviceHeading;
  String _location = 'Detecting location...';
  bool _isLoading = true;
  String? _errorMessage;
  double? _distanceToKaaba;
  StreamSubscription<CompassEvent>? _compassSubscription;
  late AnimationController _animationController;

  // Kaaba coordinates
  final double kaabaLat = 21.4225;
  final double kaabaLng = 39.8262;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true); // Pulsing animation
    _calculateQiblaDirection();
    _initCompass();
  }

  void _initCompass() {
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted && event.heading != null) {
        setState(() {
          _deviceHeading = event.heading;
        });
      }
    }, onError: (error) {
      print('Compass error: $error');
    });
    
    // Check if compass is available
    FlutterCompass.events?.isEmpty.then((isEmpty) {
      if (isEmpty == true) {
        print('⚠️ Compass not available on this device');
      }
    });
  }

  Future<void> _calculateQiblaDirection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.\nPlease enable location services.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied.\nPlease grant permission to find Qibla direction.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permission permanently denied.\nPlease enable it in settings.';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate Qibla direction
      double direction = _calculateBearing(
        position.latitude,
        position.longitude,
        kaabaLat,
        kaabaLng,
      );

      // Calculate distance to Kaaba
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        kaabaLat,
        kaabaLng,
      );

      setState(() {
        _qiblaDirection = direction;
        _distanceToKaaba = distance / 1000; // Convert to kilometers
        _location = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  double _calculateBearing(double lat1, double lng1, double lat2, double lng2) {
    double dLng = (lng2 - lng1) * pi / 180;
    lat1 = lat1 * pi / 180;
    lat2 = lat2 * pi / 180;
    lng1 = lng1 * pi / 180;

    double y = sin(dLng) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    double bearing = atan2(y, x);
    
    bearing = bearing * 180 / pi;
    bearing = (bearing + 360) % 360;
    
    return bearing;
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground(appProvider.themeMode),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(appProvider, isDark),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState(appProvider)
                    : _errorMessage != null
                        ? _buildErrorState(appProvider, isDark)
                        : _buildQiblaCompass(appProvider, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppProvider appProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Qibla Direction',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
                Text(
                  'Find direction to Kaaba',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppTheme.textLight.withOpacity(0.7)
                        : AppTheme.textDark.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _calculateQiblaDirection,
            icon: Icon(
              Icons.refresh_rounded,
              color: appProvider.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppProvider appProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(appProvider.accentColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Detecting location...',
            style: TextStyle(
              fontSize: 16,
              color: appProvider.isDarkMode ? AppTheme.textLight : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppProvider appProvider, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_off_rounded,
                  size: 64,
                  color: appProvider.accentColor,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _calculateQiblaDirection,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appProvider.accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQiblaCompass(AppProvider appProvider, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Location & Distance Info
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _location,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.textLight.withOpacity(0.8)
                                : AppTheme.textDark.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_distanceToKaaba != null) ...[
                    const SizedBox(height: 12),
                    Divider(color: appProvider.accentColor.withOpacity(0.2)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          color: appProvider.accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Distance: ${_distanceToKaaba!.toStringAsFixed(0)} km',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppTheme.textLight : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Main Compass
          FadeTransition(
            opacity: _animationController,
            child: GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    // Direction Text
                    Text(
                      'Qibla Direction',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_qiblaDirection!.toStringAsFixed(1)}° from North',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: appProvider.accentColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Compass Visual with Real-time Tracking
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Circle with Cardinals (rotates with device)
                          if (_deviceHeading != null)
                            AnimatedRotation(
                              duration: const Duration(milliseconds: 200),
                              turns: -_deviceHeading! / 360,
                              child: Container(
                                width: 300,
                                height: 300,
                                child: CustomPaint(
                                  painter: CompassRingPainter(
                                    accentColor: appProvider.accentColor,
                                    isDark: isDark,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 300,
                              height: 300,
                              child: CustomPaint(
                                painter: CompassRingPainter(
                                  accentColor: appProvider.accentColor,
                                  isDark: isDark,
                                ),
                              ),
                            ),
                          
                          // Kaaba Icon at Qibla Direction (rotates to stay at qibla)
                          _deviceHeading != null
                              ? AnimatedRotation(
                                  duration: const Duration(milliseconds: 200),
                                  turns: -_deviceHeading! / 360,
                                  child: Transform.rotate(
                                    angle: _qiblaDirection! * pi / 180,
                                    child: Transform.translate(
                                      offset: const Offset(0, -120), // Position on the ring
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: 0.9, end: 1.1).animate(_animationController),
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: appProvider.accentColor,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: appProvider.accentColor.withOpacity(0.6),
                                                blurRadius: 20,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            FlutterIslamicIcons.solidKaaba,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Transform.rotate(
                                  angle: _qiblaDirection! * pi / 180,
                                  child: Transform.translate(
                                    offset: const Offset(0, -120),
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.9, end: 1.1).animate(_animationController),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: appProvider.accentColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: appProvider.accentColor.withOpacity(0.6),
                                              blurRadius: 20,
                                              spreadRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          FlutterIslamicIcons.kaaba,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          
                          // Static Arrow Pointing Up (shows where to align device)
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  appProvider.accentColor.withOpacity(0.15),
                                  appProvider.accentColor.withOpacity(0.03),
                                ],
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Device Direction Arrow (always points up)
                                Transform.translate(
                                  offset: const Offset(0, -30),
                                  child: Icon(
                                    Icons.arrow_upward_rounded,
                                    size: 80,
                                    color: appProvider.accentColor.withOpacity(0.5),
                                    shadows: [
                                      Shadow(
                                        color: appProvider.accentColor.withOpacity(0.3),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Center Dot
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: appProvider.accentColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? Colors.white : Colors.black,
                                width: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Debug Info - Compass Values
                    if (_deviceHeading != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Qibla: ${_qiblaDirection!.toStringAsFixed(0)}° | Device: ${_deviceHeading!.toStringAsFixed(0)}°',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    // Real-time Status
                    if (_deviceHeading != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: appProvider.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: appProvider.accentColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.explore_rounded,
                              color: appProvider.accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Device: ${_deviceHeading!.toStringAsFixed(0)}°',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Compass not available',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    
                    // Instructions
                    Text(
                      _deviceHeading != null
                          ? 'Rotate until the Kaaba icon aligns with the top arrow'
                          : 'Hold your device flat and move in a figure-8 pattern',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The Kaaba icon shows the actual direction to Mecca',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.textLight.withOpacity(0.7)
                            : AppTheme.textDark.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}

// Custom Painter for Compass Ring
class CompassRingPainter extends CustomPainter {
  final Color accentColor;
  final bool isDark;

  CompassRingPainter({required this.accentColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer circle
    final circlePaint = Paint()
      ..color = accentColor.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 10, circlePaint);

    // Draw cardinal directions
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < directions.length; i++) {
      final angle = angles[i] * pi / 180;
      final x = center.dx + (radius - 30) * sin(angle);
      final y = center.dy - (radius - 30) * cos(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: i == 0 ? accentColor : (isDark ? Colors.white70 : Colors.black54),
          fontSize: i == 0 ? 24 : 18,
          fontWeight: i == 0 ? FontWeight.bold : FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );

      // Draw tick marks
      final tickStart = Offset(
        center.dx + (radius - 15) * sin(angle),
        center.dy - (radius - 15) * cos(angle),
      );
      final tickEnd = Offset(
        center.dx + (radius - 8) * sin(angle),
        center.dy - (radius - 8) * cos(angle),
      );
      
      final tickPaint = Paint()
        ..color = i == 0 ? accentColor : accentColor.withOpacity(0.5)
        ..strokeWidth = i == 0 ? 3 : 2;
      canvas.drawLine(tickStart, tickEnd, tickPaint);
    }

    // Draw minor tick marks (every 45 degrees)
    for (int i = 0; i < 8; i++) {
      if (i % 2 == 1) { // Skip cardinal directions
        final angle = (i * 45) * pi / 180;
        final tickStart = Offset(
          center.dx + (radius - 15) * sin(angle),
          center.dy - (radius - 15) * cos(angle),
        );
        final tickEnd = Offset(
          center.dx + (radius - 10) * sin(angle),
          center.dy - (radius - 10) * cos(angle),
        );
        
        final tickPaint = Paint()
          ..color = accentColor.withOpacity(0.3)
          ..strokeWidth = 1.5;
        canvas.drawLine(tickStart, tickEnd, tickPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CompassRingPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor || oldDelegate.isDark != isDark;
  }
}
