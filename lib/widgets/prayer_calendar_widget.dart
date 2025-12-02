import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../utils/responsive_helper.dart';

class PrayerCalendarWidget extends StatefulWidget {
  const PrayerCalendarWidget({super.key});

  @override
  State<PrayerCalendarWidget> createState() => _PrayerCalendarWidgetState();
}

class _PrayerCalendarWidgetState extends State<PrayerCalendarWidget> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  PrayerTimes? _prayerTimes;
  String? _nextPrayer;
  String _location = 'Mecca, Saudi Arabia';
  bool _isLoadingLocation = true;
  bool _prayerRemindersEnabled = false;
  FlutterLocalNotificationsPlugin? _notificationsPlugin;

  // Prayer icons
  final prayerIcons = {
    'Fajr': Icons.wb_twilight_rounded,
    'Dhuhr': Icons.wb_sunny_rounded,
    'Asr': Icons.wb_sunny_outlined,
    'Maghrib': Icons.wb_twilight_outlined,
    'Isha': Icons.nights_stay_rounded,
  };

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadPrayerReminderPreference().then((_) {
      // Reschedule prayer reminders if enabled (after app restart)
      if (_prayerRemindersEnabled) {
        _schedulePrayerNotifications();
      }
    });
    _calculatePrayerTimes();
    // Update every minute instead of every second to reduce rebuilds
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
          _updateCurrentPrayer();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _calculatePrayerTimes() async {
    // Load cached location first for instant display
    await _loadCachedLocationAndPrayerTimes();
    
    try {
      // Try to get user's location with timeout
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission == LocationPermission.whileInUse || 
            permission == LocationPermission.always) {
          try {
            Position? position;
            
            // Try last known position first (instant)
            try {
              position = await Geolocator.getLastKnownPosition();
            } catch (e) {
              print('Could not get last known position: $e');
            }
            
            // If no last known position, get current with timeout
            if (position == null) {
              position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.low,
                timeLimit: const Duration(seconds: 10),
              );
            }
            
            // Save location to cache
            final prefs = await SharedPreferences.getInstance();
            await prefs.setDouble('cached_latitude', position.latitude);
            await prefs.setDouble('cached_longitude', position.longitude);
            
            // Get location name
            String locationName = 'Current Location';
            try {
              List<Placemark> placemarks = await placemarkFromCoordinates(
                position.latitude,
                position.longitude,
              );
              
              if (placemarks.isNotEmpty) {
                final place = placemarks.first;
                locationName = place.locality ?? 
                            place.subAdministrativeArea ?? 
                            place.administrativeArea ??
                            'Unknown Location';
                await prefs.setString('cached_location_name', locationName);
              }
            } catch (e) {
              print('Could not get location name: $e');
            }
            
            if (!mounted) return;
            
            setState(() {
              _location = locationName;
              _isLoadingLocation = false;
            });
            
            // Calculate prayer times with user's location
            final coordinates = Coordinates(position.latitude, position.longitude);
            final params = CalculationMethod.muslim_world_league.getParameters();
            params.madhab = Madhab.shafi;
            
            final prayers = PrayerTimes.today(coordinates, params);
            
            if (!mounted) return;
            
            setState(() {
              _prayerTimes = prayers;
              _updateCurrentPrayer();
            });
            
            // Reschedule notifications if enabled
            if (_prayerRemindersEnabled) {
              await _schedulePrayerNotifications();
            }
            return;
          } catch (e) {
            print('Error getting location: $e');
            // Fall through to cached/default location
          }
        }
      }
    } catch (e) {
      print('Error in location service: $e');
      // Fall through to cached/default location
    }
    
    // If we already loaded cached data, we're done
    if (_prayerTimes != null) {
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
      });
      return;
    }
    
    // Default to Mecca if no cached data and location failed
    if (!mounted) return;
    
    setState(() {
      _location = 'Mecca, Saudi Arabia';
      _isLoadingLocation = false;
    });
    
    final coordinates = Coordinates(21.4225, 39.8262);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    
    final prayers = PrayerTimes.today(coordinates, params);
    
    if (!mounted) return;
    
    setState(() {
      _prayerTimes = prayers;
      _updateCurrentPrayer();
    });
    
    // Reschedule notifications if enabled
    if (_prayerRemindersEnabled) {
      await _schedulePrayerNotifications();
    }
  }

  Future<void> _loadCachedLocationAndPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedLat = prefs.getDouble('cached_latitude');
      final cachedLng = prefs.getDouble('cached_longitude');
      final cachedName = prefs.getString('cached_location_name');
      
      if (cachedLat != null && cachedLng != null) {
        // Calculate prayer times with cached location
        final coordinates = Coordinates(cachedLat, cachedLng);
        final params = CalculationMethod.muslim_world_league.getParameters();
        params.madhab = Madhab.shafi;
        
        final prayers = PrayerTimes.today(coordinates, params);
        
        if (!mounted) return;
        
        setState(() {
          _location = cachedName ?? 'Current Location';
          _prayerTimes = prayers;
          _isLoadingLocation = false;
          _updateCurrentPrayer();
        });
      }
    } catch (e) {
      print('Error loading cached location: $e');
    }
  }

  void _updateCurrentPrayer() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final prayers = [
      {'name': 'Fajr', 'time': _prayerTimes!.fajr},
      {'name': 'Dhuhr', 'time': _prayerTimes!.dhuhr},
      {'name': 'Asr', 'time': _prayerTimes!.asr},
      {'name': 'Maghrib', 'time': _prayerTimes!.maghrib},
      {'name': 'Isha', 'time': _prayerTimes!.isha},
    ];

    String? next;

    for (int i = 0; i < prayers.length; i++) {
      final prayerTime = prayers[i]['time'] as DateTime;
      
      if (prayerTime.isAfter(now)) {
        next = prayers[i]['name'] as String;
        break;
      }
    }

    if (next == null) {
      next = 'Fajr';
    }

    setState(() {
      _nextPrayer = next;
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  Future<void> _initializeNotifications() async {
    // Initialize timezone database
    tz_data.initializeTimeZones();
    
    // Get and set the device's local timezone
    try {
      final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback to UTC if timezone cannot be determined
      print('Error setting timezone: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin?.initialize(initSettings);
  }

  Future<void> _loadPrayerReminderPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _prayerRemindersEnabled = prefs.getBool('prayer_reminders_enabled') ?? false;
    });
  }

  Future<void> _savePrayerReminderPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_reminders_enabled', value);
  }

  Future<void> _togglePrayerReminders(bool value) async {
    setState(() {
      _prayerRemindersEnabled = value;
    });
    await _savePrayerReminderPreference(value);
    
    if (value) {
      await _schedulePrayerNotifications();
    } else {
      await _cancelPrayerNotifications();
    }
  }

  Future<void> _schedulePrayerNotifications() async {
    if (_notificationsPlugin == null) return;

    // Request permissions for iOS
    final iosPermission = await _notificationsPlugin!
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    // Request permissions for Android 13+
    final androidPermission = await _notificationsPlugin!
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    // Request exact alarm permission for Android
    await _notificationsPlugin!
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
    
    // Check if permission was granted
    if (iosPermission == false || androidPermission == false) {
      print('Notification permission denied');
      return;
    }

    // Cancel existing prayer notifications first
    await _cancelPrayerNotifications();

    // Get location for calculating prayer times
    double latitude = 21.4225; // Default to Mecca
    double longitude = 39.8262;
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission != LocationPermission.denied && 
            permission != LocationPermission.deniedForever) {
          try {
            Position? position = await Geolocator.getLastKnownPosition();
            
            if (position == null) {
              position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.low,
                timeLimit: const Duration(seconds: 10),
              );
            }
            
            latitude = position.latitude;
            longitude = position.longitude;
          } catch (e) {
            print('Error getting location: $e');
          }
        }
      }
    } catch (e) {
      print('Location error: $e');
    }

    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;

    // Schedule prayers for the next 7 days
    int notificationId = 100;
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final targetDate = DateTime.now().add(Duration(days: dayOffset));
      final prayers = PrayerTimes(coordinates, DateComponents(targetDate.year, targetDate.month, targetDate.day), params);

      final prayerMap = {
        'Fajr': prayers.fajr,
        'Dhuhr': prayers.dhuhr,
        'Asr': prayers.asr,
        'Maghrib': prayers.maghrib,
        'Isha': prayers.isha,
      };

      for (final entry in prayerMap.entries) {
        final prayerName = entry.key;
        final prayerTime = entry.value;
        
        // Only schedule if prayer time is in the future
        if (prayerTime.isAfter(DateTime.now())) {
          await _notificationsPlugin!.zonedSchedule(
            notificationId,
            'Prayer Time: $prayerName',
            "It's time for $prayerName prayer",
            tz.TZDateTime.from(prayerTime, tz.local),
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'prayer_reminders',
                'Prayer Reminders',
                channelDescription: 'Notifications for prayer times',
                importance: Importance.high,
                priority: Priority.high,
                // sound: RawResourceAndroidNotificationSound('azan'), // Use default sound if azan resource is not available
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
          notificationId++;
        }
      }
    }
  }

  Future<void> _cancelPrayerNotifications() async {
    if (_notificationsPlugin == null) return;
    // Cancel prayer notifications (IDs 100-199 to cover 7 days worth)
    for (int i = 100; i <= 199; i++) {
      await _notificationsPlugin!.cancel(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriCalendar.now();
    final responsive = context.responsive;

    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = appProvider.isDarkMode;
        
        return Padding(
          padding: responsive.screenPadding,
          child: Column(
            children: [
              // Calendar Card - Full Width
              GlassCard(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(
                    children: [
                      // Date & Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('h:mm a').format(_currentTime),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d').format(_currentTime),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark 
                                    ? AppTheme.textLight.withOpacity(0.7)
                                    : AppTheme.textDark.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Islamic Date Badge
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              appProvider.accentColor.withOpacity(0.2),
                              appProvider.accentColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: appProvider.accentColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                              Icons.calendar_today_rounded,
                              color: appProvider.accentColor,
                              size: 20,
                            ),
                            const SizedBox(height: 8, width: 8,),
                            Text(
                              '${hijriDate.hDay}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: appProvider.accentColor,
                              ),
                            ),
                              ],
                            ),
                            Text(
                              hijriDate.longMonthName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: appProvider.accentColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${hijriDate.hYear} AH',
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark 
                                    ? AppTheme.textLight.withOpacity(0.6)
                                    : AppTheme.textDark.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          //     ],
          //   ),
          // ),
          
          // const SizedBox(height: 16),
          
          // // Prayer Times - 5 Cards in Full Width Row
          // GlassCard(
          //   child: Column(
          //     children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Location Header
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: appProvider.accentColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _location,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark 
                                  ? AppTheme.textLight.withOpacity(0.8)
                                  : AppTheme.textDark.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.left,
                          ),
                          if (_isLoadingLocation) ...[
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                valueColor: AlwaysStoppedAnimation(appProvider.accentColor),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Prayer Times Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPrayerItem(context, 'Fajr', _prayerTimes?.fajr, appProvider, isDark),
                          _buildDivider(isDark),
                          _buildPrayerItem(context, 'Dhuhr', _prayerTimes?.dhuhr, appProvider, isDark),
                          _buildDivider(isDark),
                          _buildPrayerItem(context, 'Asr', _prayerTimes?.asr, appProvider, isDark),
                          _buildDivider(isDark),
                          _buildPrayerItem(context, 'Maghrib', _prayerTimes?.maghrib, appProvider, isDark),
                          _buildDivider(isDark),
                          _buildPrayerItem(context, 'Isha', _prayerTimes?.isha, appProvider, isDark),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Prayer Reminder Toggle
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      //   decoration: BoxDecoration(
                      //     color: isDark 
                      //         ? Colors.white.withOpacity(0.05)
                      //         : Colors.black.withOpacity(0.03),
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(
                      //       color: appProvider.accentColor.withOpacity(0.2),
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Row(
                      //     children: [
                      //       Icon(
                      //         Icons.notifications_active_rounded,
                      //         size: 20,
                      //         color: appProvider.accentColor,
                      //       ),
                      //       const SizedBox(width: 12),
                      //       Expanded(
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Text(
                      //               'Prayer Reminders',
                      //               style: TextStyle(
                      //                 fontSize: 14,
                      //                 fontWeight: FontWeight.w600,
                      //                 color: isDark 
                      //                     ? AppTheme.textLight
                      //                     : AppTheme.textDark,
                      //               ),
                      //             ),
                      //             Text(
                      //               'Notify me at prayer times',
                      //               style: TextStyle(
                      //                 fontSize: 11,
                      //                 color: isDark 
                      //                     ? AppTheme.textLight.withOpacity(0.6)
                      //                     : AppTheme.textDark.withOpacity(0.6),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //       Switch(
                      //         value: _prayerRemindersEnabled,
                      //         onChanged: _togglePrayerReminders,
                      //         activeColor: appProvider.accentColor,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                ],
              ),
            ),
          ],
        ),
      );
      },
    );
  }
  
  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 50,
      color: isDark 
          ? AppTheme.textLight.withOpacity(0.1)
          : AppTheme.textDark.withOpacity(0.1),
    );
  }

  Widget _buildPrayerItem(BuildContext context, String name, DateTime? time, AppProvider appProvider, bool isDark) {
    if (time == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation(appProvider.accentColor),
            ),
          ),
        ],
      );
    }

    final isNext = name == _nextPrayer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prayer Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isNext 
                ? appProvider.accentColor.withOpacity(0.15)
                : (isDark 
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(12),
            border: isNext
                ? Border.all(
                    color: appProvider.accentColor.withOpacity(0.4),
                    width: 1.5,
                  )
                : null,
          ),
          child: Icon(
            prayerIcons[name],
            size: 20,
            color: isNext 
                ? appProvider.accentColor
                : (isDark 
                    ? AppTheme.textLight.withOpacity(0.6)
                    : AppTheme.textDark.withOpacity(0.6)),
          ),
        ),
        const SizedBox(height: 8),
        // Prayer Name
        Text(
          name,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
            color: isNext 
                ? appProvider.accentColor
                : (isDark 
                    ? AppTheme.textLight.withOpacity(0.7)
                    : AppTheme.textDark.withOpacity(0.7)),
          ),
        ),
        const SizedBox(height: 4),
        // Prayer Time
        Text(
          _formatTime(time),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isNext 
                ? appProvider.accentColor
                : (isDark ? AppTheme.textLight : AppTheme.textDark),
          ),
        ),
        if (isNext) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: appProvider.accentColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'NEXT',
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
