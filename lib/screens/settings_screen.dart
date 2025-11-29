import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../constants/app_constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/test_voice_dialog.dart';
import 'donation_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isRestored = false;
  bool _isRestoring = false;
  bool _prayerRemindersEnabled = false;
  FlutterLocalNotificationsPlugin? _notificationsPlugin;
  PrayerTimes? _prayerTimes;

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
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final progress = appProvider.userProgress;
    
    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                SizedBox(height: 8),
                Text(
                  'Customize your experience',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: appProvider.accentColor,
                      ),
                ),
                
                SizedBox(height: 32),
                
                // // Progress Stats
                // Text(
                //   'Your Progress',
                //   style: Theme.of(context).textTheme.headlineMedium,
                // ),
                // SizedBox(height: 16),
                
                // _buildStatsGrid(context, appProvider, progress),
                
                // SizedBox(height: 32),
                
                // Appearance Settings
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 16),
                
                // Theme Mode
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            appProvider.isDarkMode 
                                ? Icons.dark_mode_rounded 
                                : Icons.light_mode_rounded,
                            color: appProvider.accentColor,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Theme Mode',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  appProvider.isDarkMode ? 'Dark' : 'Light',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: appProvider.isDarkMode,
                            onChanged: (value) {
                              appProvider.toggleThemeMode();
                            },
                            activeColor: appProvider.accentColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                       Divider(height: 1, color: appProvider.accentColor),
                      SizedBox(height: 20),
                      
                      InkWell(
                  onTap: () {
                    _showThemeColorSelector(context, appProvider);
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: appProvider.accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: appProvider.accentColor.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Theme Color',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              AppTheme.themeColors.firstWhere(
                                (c) => c['id'] == appProvider.themeColor,
                                orElse: () => AppTheme.themeColors[0],
                              )['name'] as String,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                    ],
                  ),
                ),
                
                SizedBox(height: 12),

                // GlassCard(
                //   onTap: () {
                //     _showThemeColorSelector(context, appProvider);
                //   },
                //   child: Row(
                //     children: [
                //       Container(
                //         width: 40,
                //         height: 40,
                //         decoration: BoxDecoration(
                //           color: appProvider.accentColor,
                //           shape: BoxShape.circle,
                //           boxShadow: [
                //             BoxShadow(
                //               color: appProvider.accentColor.withOpacity(0.4),
                //               blurRadius: 8,
                //               spreadRadius: 2,
                //             ),
                //           ],
                //         ),
                //       ),
                //       SizedBox(width: 16),
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Text(
                //               'Accent Color',
                //               style: Theme.of(context).textTheme.titleMedium,
                //             ),
                //             Text(
                //               AppTheme.themeColors.firstWhere(
                //                 (c) => c['id'] == appProvider.themeColor,
                //                 orElse: () => AppTheme.themeColors[0],
                //               )['name'] as String,
                //               style: Theme.of(context).textTheme.bodySmall,
                //             ),
                //           ],
                //         ),
                //       ),
                //       Icon(
                //         Icons.arrow_forward_ios_rounded,
                //         color: appProvider.accentColor,
                //         size: 20,
                //       ),
                //     ],
                //   ),
                // ),
                
                SizedBox(height: 12),
                
                
                // Glass Style
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.blur_on_rounded,
                            color: appProvider.accentColor,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Glass Style',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGlassStyleOption(
                              context,
                              'Clear',
                              AppTheme.glassStyleClear,
                              appProvider.glassStyle == AppTheme.glassStyleClear,
                              () => appProvider.setGlassStyle(AppTheme.glassStyleClear),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildGlassStyleOption(
                              context,
                              'Tinted',
                              AppTheme.glassStyleTinted,
                              appProvider.glassStyle == AppTheme.glassStyleTinted,
                              () => appProvider.setGlassStyle(AppTheme.glassStyleTinted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Font Size Adjustment
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.format_size_rounded,
                            color: appProvider.accentColor,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Text Size',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${appProvider.baseFontSize.toInt()}px - Applies to entire app',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      
                      // Slider for base font size
                      Row(
                        children: [
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 14,
                              color: appProvider.accentColor,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: appProvider.baseFontSize,
                              min: 16.0,
                              max: 30.0,
                              divisions: 14,
                              activeColor: appProvider.accentColor,
                              inactiveColor: appProvider.accentColor.withOpacity(0.3),
                              onChanged: (value) {
                                appProvider.setBaseFontSize(value);
                              },
                            ),
                          ),
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: appProvider.accentColor,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Preview text
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: appProvider.isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: appProvider.accentColor.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview:',
                              style: TextStyle(
                                fontSize: 12,
                                color: appProvider.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            // Text(
                            //   'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
                            //   style: TextStyle(
                            //     fontSize: appProvider.baseFontSize,
                            //     color: appProvider.isDarkMode
                            //         ? AppTheme.textLight
                            //         : AppTheme.textDark,
                            //   ),
                            // ),
                            SizedBox(height: 8),
                            Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              style: TextStyle(
                                fontSize: appProvider.baseFontSize * 1.5,
                                fontFamily: 'Amiri',
                                color: appProvider.isDarkMode
                                    ? AppTheme.textLight
                                    : AppTheme.textDark,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Translation/English Font Size Adjustment
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.translate_rounded,
                            color: appProvider.accentColor,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Translation Text Size',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${appProvider.translationFontSize.toInt()}px - English & translation text',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      
                      // Slider for translation size
                      Row(
                        children: [
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 12,
                              color: appProvider.accentColor,
                            ),
                          ),
                          Expanded(
                            child: Slider(
                              value: appProvider.translationFontSize,
                              min: 12.0,
                              max: 24.0,
                              divisions: 12,
                              activeColor: appProvider.accentColor,
                              inactiveColor: appProvider.accentColor.withOpacity(0.3),
                              onChanged: (value) {
                                appProvider.setTranslationFontSize(value);
                              },
                            ),
                          ),
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: appProvider.accentColor,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Preview text for translation
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: appProvider.isDarkMode
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: appProvider.accentColor.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview:',
                              style: TextStyle(
                                fontSize: 12,
                                color: appProvider.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'In the name of Allah, the Most Gracious, the Most Merciful',
                              style: TextStyle(
                                fontSize: appProvider.translationFontSize,
                                color: appProvider.isDarkMode
                                    ? AppTheme.textLight
                                    : AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Language Settings
                Text(
                  'Language',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 16),
                
                GlassCard(
                  onTap: () {
                    _showLanguageSelector(context, appProvider);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.language_rounded,
                        color: appProvider.accentColor,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Translation Language',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              appProvider.selectedLanguage,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Audio Settings
                Text(
                  'Audio',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 16),
                
                GlassCard(
                  child: Column(
                    children: [
                      // Select Reciter
                      InkWell(
                        onTap: () {
                          _showReciterSelector(context, appProvider);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.record_voice_over_rounded,
                                color: appProvider.accentColor,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reciter',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      appProvider.selectedReciterName,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: appProvider.accentColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      Divider(height: 1, color: appProvider.accentColor),
                      
                      // Test Voice
                      InkWell(
                        onTap: () {
                          _showTestVoiceDialog(context, appProvider);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline_rounded,
                                color: appProvider.accentColor,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Test Voice',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      'Preview reciter audio',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: appProvider.accentColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Notifications
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 16),
                
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Reading Reminder Toggle
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: appProvider.accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.notifications_active_rounded,
                                color: appProvider.accentColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Reading Reminder',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    appProvider.reminderEnabled 
                                        ? 'Reminder set for ${appProvider.reminderTimeFormatted}'
                                        : 'Get daily reminder to read Quran',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: appProvider.reminderEnabled
                                          ? appProvider.accentColor
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CupertinoSwitch(
                              value: appProvider.reminderEnabled,
                              onChanged: (value) async {
                                await appProvider.toggleReminder(value);
                              },
                              activeColor: appProvider.accentColor,
                            ),
                          ],
                        ),
                        
                        // Time Picker (shown when reminder is enabled)
                        if (appProvider.reminderEnabled) ...[
                          SizedBox(height: 16),
                          Divider(height: 1),
                          SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: appProvider.reminderHour,
                                  minute: appProvider.reminderMinute,
                                ),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: appProvider.accentColor,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              
                              if (picked != null) {
                                await appProvider.updateReminderTime(
                                  picked.hour,
                                  picked.minute,
                                );
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: appProvider.accentColor,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reminder Time',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Text(
                                        'Tap to change',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: appProvider.accentColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: appProvider.accentColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    appProvider.reminderTimeFormatted,
                                    style: TextStyle(
                                      color: appProvider.accentColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                                    //     ],
                                    //   ),
                                    // ),
                                    
                                    // SizedBox(height: 12),
                                    
                                    // // Prayer Reminders Toggle
                     SizedBox(height: 20),
                        Divider(height: 1, color: appProvider.accentColor),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: appProvider.accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.mosque_rounded,
                                color: appProvider.accentColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Prayer Time Reminders',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    _prayerRemindersEnabled
                                        ? 'Notifications enabled for all 5 prayers'
                                        : 'Get notified at prayer times',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _prayerRemindersEnabled
                                          ? appProvider.accentColor
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CupertinoSwitch(
                              value: _prayerRemindersEnabled,
                              onChanged: _togglePrayerReminders,
                              activeColor: appProvider.accentColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Support & About
                Text(
                  'Support & About',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
//                 SizedBox(height: 16),
                
//                 GlassCard(
                  
//                   child: Column(
//                     children: [
//                       InkWell(
//                         onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => DonationScreen(),
//                           ),
//                         );
//                       },
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.favorite_rounded,
//                               color: const Color(0xFFFF6B6B),
//                             ),
//                             SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Support the App',
//                                     style: Theme.of(context).textTheme.titleMedium,
//                                   ),
//                                   Text(
//                                     'Help us continue developing',
//                                     style: Theme.of(context).textTheme.bodySmall,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Icon(
//                               Icons.arrow_forward_ios_rounded,
//                               color: appProvider.accentColor,
//                               size: 20,
//                             ),
//                           ],
//                         ),
//                       ),
                      
//                       // Restore Purchases Button
//                       if (!_isRestored) ...[
//                         const SizedBox(height: 16),
//                         Divider(height: 1, color: appProvider.accentColor),
//                         const SizedBox(height: 16),
//                         InkWell(
//                           onTap: _isRestoring ? null : _restorePurchases,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.restore_rounded,
//                                 color: _isRestoring 
//                                     ? Colors.grey 
//                                     : appProvider.accentColor,
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Restore Purchases',
//                                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                         color: _isRestoring ? Colors.grey : null,
//                                       ),
//                                     ),
//                                     Text(
//                                       _isRestoring 
//                                           ? 'Restoring...' 
//                                           : 'Restore your previous purchases',
//                                       style: Theme.of(context).textTheme.bodySmall,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               if (_isRestoring)
//                                 SizedBox(
//                                   width: 20,
//                                   height: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                       appProvider.accentColor,
//                                     ),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ],
// // SizedBox(height: 25),

// // Feedback
                
                
                
//                     ],
//                   ),
//                 ),
                

                //   Text(
                //   'More',
                //   style: Theme.of(context).textTheme.headlineMedium,
                // ),
                SizedBox(height: 16),
                
                GlassCard(
                  
                  child: Column(
                    children: [
                      

// Feedback
                InkWell(
                  onTap: () => _sendFeedback(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bug_report,
                        color: appProvider.accentColor,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Report Bug',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Report bug or suggest a feature',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 25),
                      InkWell(
                  onTap: () => _shareApp(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.share_rounded,
                        color: appProvider.accentColor,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share App',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Share with friends and family',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 25),

                
                // Rate App
                InkWell(
                  onTap: () => _rateApp(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: appProvider.accentColor,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rate App',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Rate us on App Store',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 25),
                
                // Feedback
                InkWell(
                  onTap: () => _sendFeedback(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.feedback_rounded,
                        color: appProvider.accentColor,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feedback',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Send us your suggestions',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 25),
                
                // View All Apps
                InkWell(
                  onTap: () => _viewAllApps(),
                  child: Row(
                    children: [
                      Icon(
                        Icons.apps_rounded,
                        color: appProvider.accentColor,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'More Apps',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'View all our apps on App Store',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                 SizedBox(height: 25),
                // About
                InkWell(
                  onTap: () {
                    _showAboutDialog(context);
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: appProvider.accentColor,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About Hidayah',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'Version ${AppConstants.appVersion}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                    ],
                  ),
                ),
                
                // SizedBox(height: 25),
                
                // Share App
                
                
                SizedBox(height: 40),
                
                // Made with love
                Center(
                  child: Text(
                    'Made with ❤️ for the Muslim community',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: appProvider.isDarkMode 
                              ? AppTheme.textLight.withOpacity(0.5)
                              : AppTheme.textDark.withOpacity(0.5),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Prayer Reminder Methods
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

  Future<void> _calculatePrayerTimes() async {
    try {
      // Try to get user's location with timeout
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      double latitude = 21.4225; // Default to Mecca
      double longitude = 39.8262;
      
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        
        if (permission != LocationPermission.denied && 
            permission != LocationPermission.deniedForever) {
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
            
            latitude = position.latitude;
            longitude = position.longitude;
          } catch (e) {
            print('Error getting location: $e');
            // Use default Mecca coordinates
          }
        }
      }
      
      final coordinates = Coordinates(latitude, longitude);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      
      final prayers = PrayerTimes.today(coordinates, params);
      
      if (!mounted) return;
      
      setState(() {
        _prayerTimes = prayers;
      });
    } catch (e) {
      print('Error calculating prayer times: $e');
      // Fallback to Mecca if error
      final coordinates = Coordinates(21.4225, 39.8262);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      
      final prayers = PrayerTimes.today(coordinates, params);
      
      if (!mounted) return;
      
      setState(() {
        _prayerTimes = prayers;
      });
    }
  }

  Future<void> _togglePrayerReminders(bool value) async {
    setState(() {
      _prayerRemindersEnabled = value;
    });
    await _savePrayerReminderPreference(value);
    
    if (value) {
      await _schedulePrayerNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Prayer reminders enabled'),
            backgroundColor: context.read<AppProvider>().accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      await _cancelPrayerNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer reminders disabled'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
                sound: RawResourceAndroidNotificationSound('azan'),
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
  
  Widget _buildStatsGrid(BuildContext context, AppProvider appProvider, dynamic progress) {
    final totalHours = (progress?.totalStudyTime ?? 0) ~/ 3600;
    final streak = progress?.currentStreak ?? 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Study Hours',
            totalHours.toString(),
            Icons.schedule_rounded,
            appProvider.isDarkMode,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Day Streak',
            streak.toString(),
            Icons.local_fire_department_rounded,
            appProvider.isDarkMode,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: appProvider.accentColor,
            size: 32,
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: appProvider.accentColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildGlassStyleOption(
    BuildContext context,
    String label,
    String value,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final appProvider = context.watch<AppProvider>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? appProvider.accentColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? appProvider.accentColor : appProvider.accentColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? appProvider.accentColor : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
          ),
        ),
      ),
    );
  }
  
  void _showLanguageSelector(BuildContext context, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: appProvider.isDarkMode 
                ? AppTheme.primaryDark 
                : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            
            children: [
              Text(
                'Select Translation Language',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        Text(""),
                        SizedBox(height: 24),
                        ...AppConstants.supportedTranslations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final translation = entry.value;
                      final language = translation['name']!;
                      final key = translation['key']!;
                      final isSelected = appProvider.selectedLanguage == language;
                      return ListTile(
                        leading: Text("${index + 1}. "),
                        title: Text("$language [${key}]"),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: appProvider.accentColor)
                            : null,
                        selected: isSelected,
                        selectedTileColor: appProvider.accentColor.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          appProvider.setLanguage(language, key);
                          Navigator.pop(context);
                        },
                      );
                    }),
                      ],
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  void _showReciterSelector(BuildContext context, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: appProvider.isDarkMode 
                ? AppTheme.primaryDark 
                : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Reciter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 8),
              Text(
                'Choose your preferred Qari',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: appProvider.accentColor,
                    ),
              ),
              SizedBox(height: 24),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: AppConstants.reciters.map((reciter) {
                    final name = reciter['name']!;
                    final arabicName = reciter['arabicName']!;
                    final key = reciter['key']!;
                    final isSelected = appProvider.selectedReciter == key;
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                      ),
                      subtitle: Text(
                        arabicName,
                        style: AppTheme.arabicTextStyle(
                          fontSize: 16,
                          color: appProvider.isDarkMode 
                              ? AppTheme.textLight.withOpacity(0.7)
                              : AppTheme.textDark.withOpacity(0.7),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: appProvider.accentColor,
                            )
                          : Icon(
                              Icons.circle_outlined,
                              color: Colors.grey,
                            ),
                      selected: isSelected,
                      selectedTileColor: appProvider.accentColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        appProvider.setReciter(key);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  void _showTestVoiceDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      
      builder: (context) => TestVoiceDialog(
        reciterKey: appProvider.selectedReciter,
        reciterName: appProvider.selectedReciterName,
      ),
    );
  }
  
  void _showThemeColorSelector(BuildContext context, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: appProvider.isDarkMode 
                ? AppTheme.primaryDark 
                : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Theme Color',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: AppTheme.themeColors.map((colorMap) {
                  final colorId = colorMap['id'] as String;
                  final colorName = colorMap['name'] as String;
                  final color = colorMap['color'] as Color;
                  final isSelected = appProvider.themeColor == colorId;
                  
                  return GestureDetector(
                    onTap: () {
                      appProvider.setThemeColor(colorId);
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 32,
                                )
                              : null,
                        ),
                        SizedBox(height: 8),
                        Text(
                          colorName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // backgroundColor: AppTheme.primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Icon(
              Icons.mosque_rounded,
              color: appProvider.accentColor,
            ),
            SizedBox(width: 12),
            Text('About Hidayah'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${AppConstants.appVersion}',
              style: TextStyle(
                // color: AppTheme.textLight,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Hidayah is a comprehensive Quran learning application designed to help Muslims strengthen their connection with the Quran through reading, memorization, and daily supplications.',
              // style: TextStyle(color: AppTheme.textLight),
            ),
            SizedBox(height: 16),
            Text(
              '✨ Features:',
              style: TextStyle(
                color: appProvider.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Complete Quran with translations\n'
              '• Daily Duas & Azkar\n'
              '• Memorization tracking\n'
              '• Audio recitation\n'
              '• Free & Ad-free',
              // style: TextStyle(color: AppTheme.textLight),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: appProvider.accentColor),
            ),
          ),
        ],
      ),
    );
  }
  
  // Share App
  void _shareApp(BuildContext context) {
    SharePlus.instance.share(ShareParams(text:
      'Check out Hidayah - A beautiful Quran learning app!\n\n'
      'Download now: https://apps.apple.com/us/app/id6755522997',
      ),
    );
  }
  
  // Rate App
  Future<void> _rateApp() async {
    final Uri url = Uri.parse('https://apps.apple.com/us/app/id6755522997');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
  
  // Send Feedback
  Future<void> _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'mubeenkhan2461@gmail.com',
      query: 'subject=Hidayah App Feedback&body=',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  // Send Feedback
  Future<void> reportBug() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'mubeenkhan2461@gmail.com',
      query: 'subject=Hidayah App ReportBug&body=',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
  
  // View All Apps
  Future<void> _viewAllApps() async {
    final Uri url = Uri.parse('https://apps.apple.com/us/developer/muhammad-mubeen/id1553722821');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
  
  // Restore Purchases
  Future<void> _restorePurchases() async {
    setState(() {
      _isRestoring = true;
    });
    
    try {
      // Simulate restore purchases process
      // TODO: Integrate with your actual in-app purchase system
      await Future.delayed(const Duration(seconds: 2));
      
      // Check if user has any purchases
      // TODO: Replace with actual purchase check
      final bool hasPurchases = false; // This should check actual purchase history
      
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
        
        if (hasPurchases) {
          // User has purchases - restore them
          setState(() {
            _isRestored = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✓ Purchases restored successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // No purchases found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No previous purchases found'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore purchases: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
