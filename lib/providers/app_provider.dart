import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_progress.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../services/notification_service.dart';

class AppProvider with ChangeNotifier {
  // User Preferences
  String _selectedLanguage = 'English (Saheeh International)';
  String _selectedTranslation = 'enSaheeh'; // quran package translation key
  String _selectedReciter = 'arAlafasy'; // quran package reciter key
  String _glassStyle = AppTheme.glassStyleClear;
  String _themeMode = AppTheme.themeLight; // Default to light mode
  String _themeColor = 'lime'; // Default theme color
  bool _isFirstLaunch = true;
  double _arabicTextSize = 24.0; // Default to Medium
  double _baseFontSize = 16.0; // Default base font size (16px-30px range)
  double _translationFontSize = 16.0; // Default translation/English text size (12px-24px range)
  String _hadithLanguage = 'en';
  String _quranDisplayMode = 'both';
  
  // Reading Reminder
  bool _reminderEnabled = false;
  int _reminderHour = 9; // 9 AM default
  int _reminderMinute = 0;
  
  // User Progress
  UserProgress? _userProgress;
  Box<UserProgress>? _progressBox;
  
  // Getters
  String get selectedLanguage => _selectedLanguage;
  String get selectedTranslation => _selectedTranslation;
  String get selectedReciter => _selectedReciter;
  String get glassStyle => _glassStyle;
  String get themeMode => _themeMode;
  String get themeColor => _themeColor;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isDarkMode => _themeMode == AppTheme.themeDark;
  String get hadithLanguage => _hadithLanguage;
  UserProgress? get userProgress => _userProgress;
  double get arabicTextSize => _arabicTextSize;
  double get baseFontSize => _baseFontSize;
  double get translationFontSize => _translationFontSize;
  bool get reminderEnabled => _reminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  String get quranDisplayMode => _quranDisplayMode;
  
  String get reminderTimeFormatted {
    final hour12 = _reminderHour > 12 ? _reminderHour - 12 : (_reminderHour == 0 ? 12 : _reminderHour);
    final period = _reminderHour >= 12 ? 'PM' : 'AM';
    final minute = _reminderMinute.toString().padLeft(2, '0');
    return '$hour12:$minute $period';
  }

  Future<void> setHadithLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyHadithLanguage, code);
    _hadithLanguage = code;
    notifyListeners();
  }
  
  // Get current accent color
  Color get accentColor => AppTheme.getAccentColor(_themeColor);
  
  // Get reciter display name
  String get selectedReciterName {
    final reciter = AppConstants.reciters.firstWhere(
      (r) => r['key'] == _selectedReciter,
      orElse: () => AppConstants.reciters[0],
    );
    return reciter['name'] ?? 'Mishary Rashid Alafasy';
  }
  
  // Initialize
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load preferences
    _isFirstLaunch = prefs.getBool(AppConstants.keyFirstLaunch) ?? true;
    _selectedLanguage = prefs.getString(AppConstants.keySelectedLanguage) ?? 'English (Saheeh International)';
    _selectedTranslation = prefs.getString(AppConstants.keySelectedTranslation) ?? 'enSaheeh';
    _selectedReciter = prefs.getString(AppConstants.keySelectedReciter) ?? 'arAlafasy';
    _glassStyle = prefs.getString(AppConstants.keyGlassStyle) ?? AppTheme.glassStyleClear;
    _themeMode = prefs.getString(AppConstants.keyThemeMode) ?? AppTheme.themeLight; // Default to light
    _themeColor = prefs.getString(AppConstants.keyThemeColor) ?? 'lime'; // Default to lime
    _arabicTextSize = prefs.getDouble(AppConstants.keyArabicTextSize) ?? 24.0; // Default to Medium
    _baseFontSize = prefs.getDouble(AppConstants.keyBaseFontSize) ?? 16.0; // Default base font size
    _translationFontSize = prefs.getDouble(AppConstants.keyTranslationFontSize) ?? 16.0; // Default translation font size
    _hadithLanguage = prefs.getString(AppConstants.keyHadithLanguage) ?? 'en';
    _quranDisplayMode = prefs.getString(AppConstants.keyQuranDisplayMode) ?? 'both';
    
    // Load reminder settings
    _reminderEnabled = prefs.getBool('reminderEnabled') ?? false;
    _reminderHour = prefs.getInt('reminderHour') ?? 9;
    _reminderMinute = prefs.getInt('reminderMinute') ?? 0;
    
    // Initialize notification service
    await NotificationService().initialize();
    
    // Reschedule daily reminder if enabled (to restore after app restart)
    if (_reminderEnabled) {
      await NotificationService().scheduleDailyReminder(
        hour: _reminderHour,
        minute: _reminderMinute,
      );
    }
    
    // Initialize Hive (only once)
    try {
      await Hive.initFlutter();
    } catch (e) {
      // Already initialized, continue
    }
    
    // Register adapters (only if not already registered)
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserProgressAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(AchievementAdapter());
      }
    } catch (e) {
      // Adapters already registered, continue
    }
    
    // Open boxes (will reuse if already open)
    if (!Hive.isBoxOpen('progress')) {
      _progressBox = await Hive.openBox<UserProgress>('progress');
    } else {
      _progressBox = Hive.box<UserProgress>('progress');
    }
    
    // Load or create user progress
    if (_progressBox!.isNotEmpty) {
      _userProgress = _progressBox!.get('user_progress');
    } else {
      _userProgress = UserProgress();
      await _progressBox!.put('user_progress', _userProgress!);
    }
    
    notifyListeners();
  }
  
  // Complete first launch
  Future<void> completeFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyFirstLaunch, false);
    _isFirstLaunch = false;
    notifyListeners();
  }
  
  // Set language and translation
  Future<void> setLanguage(String language, String translationKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySelectedLanguage, language);
    await prefs.setString(AppConstants.keySelectedTranslation, translationKey);
    _selectedLanguage = language;
    _selectedTranslation = translationKey;
    notifyListeners();
  }
  
  // Set reciter
  Future<void> setReciter(String reciterKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keySelectedReciter, reciterKey);
    _selectedReciter = reciterKey;
    notifyListeners();
  }
  
  // Set glass style
  Future<void> setGlassStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyGlassStyle, style);
    _glassStyle = style;
    notifyListeners();
  }
  
  // Set theme mode
  Future<void> setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyThemeMode, mode);
    _themeMode = mode;
    notifyListeners();
  }
  
  // Toggle theme mode
  Future<void> toggleThemeMode() async {
    final newMode = _themeMode == AppTheme.themeDark 
        ? AppTheme.themeLight 
        : AppTheme.themeDark;
    await setThemeMode(newMode);
  }
  
  // Set theme color
  Future<void> setThemeColor(String colorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyThemeColor, colorId);
    _themeColor = colorId;
    notifyListeners();
  }
  
  // Set Arabic text size
  Future<void> setArabicTextSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyArabicTextSize, size);
    _arabicTextSize = size;
    notifyListeners();
  }
  
  // Set base font size for entire app
  Future<void> setBaseFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyBaseFontSize, size);
    _baseFontSize = size;
    notifyListeners();
  }
  
  // Set translation/English font size
  Future<void> setTranslationFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyTranslationFontSize, size);
    _translationFontSize = size;
    notifyListeners();
  }

  // Set Quran display mode ("arabic", "translation", "both")
  Future<void> setQuranDisplayMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyQuranDisplayMode, mode);
    _quranDisplayMode = mode;
    notifyListeners();
  }
  
  // Update user progress
  Future<void> updateProgress(UserProgress progress) async {
    _userProgress = progress;
    await _progressBox!.put('user_progress', progress);
    notifyListeners();
  }
  
  // Session tracking
  DateTime? _sessionStartTime;
  
  // Start study session
  void startStudySession() {
    _sessionStartTime = DateTime.now();
  }
  
  // End study session and save time
  Future<void> endStudySession() async {
    if (_sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!);
      final seconds = duration.inSeconds;
      
      // Only count sessions longer than 10 seconds
      if (seconds > 10) {
        await addStudyTime(seconds);
      }
      
      _sessionStartTime = null;
    }
  }
  
  // Add study time
  Future<void> addStudyTime(int seconds) async {
    if (_userProgress != null) {
      _userProgress!.addStudyTime(seconds);
      await updateProgress(_userProgress!);
    }
  }
  
  // Toggle bookmark
  Future<void> toggleBookmark(int surahNumber, int ayahNumber) async {
    if (_userProgress != null) {
      final key = '$surahNumber:$ayahNumber';
      if (_userProgress!.bookmarkedVerses.contains(key)) {
        _userProgress!.bookmarkedVerses.remove(key);
      } else {
        _userProgress!.bookmarkedVerses.add(key);
      }
      await updateProgress(_userProgress!);
    }
  }
  
  // Check if verse is bookmarked
  bool isBookmarked(int surahNumber, int ayahNumber) {
    if (_userProgress == null) return false;
    final key = '$surahNumber:$ayahNumber';
    return _userProgress!.bookmarkedVerses.contains(key);
  }
  
  // Update Surah progress
  Future<void> updateSurahProgress(int surahNumber, int ayahNumber) async {
    if (_userProgress != null) {
      _userProgress!.surahProgress[surahNumber.toString()] = ayahNumber;
      await updateProgress(_userProgress!);
    }
  }
  
  // Complete Tajweed lesson
  Future<void> completeTajweedLesson(int lessonId) async {
    if (_userProgress != null) {
      final lessonKey = 'lesson_$lessonId';
      if (!_userProgress!.completedTajweedLessons.contains(lessonKey)) {
        _userProgress!.completedTajweedLessons.add(lessonKey);
        await updateProgress(_userProgress!);
        
        // Check for achievements
        _checkAchievements();
      }
    }
  }
  
  // Update memorization
  Future<void> updateMemorization(
    int surahNumber,
    int ayahNumber,
    int proficiency,
  ) async {
    if (_userProgress != null) {
      final key = '$surahNumber:$ayahNumber';
      _userProgress!.memorizedVerses[key] = proficiency;
      await updateProgress(_userProgress!);
      
      // Check for achievements
      _checkAchievements();
    }
  }
  
  // Check and unlock achievements
  void _checkAchievements() {
    if (_userProgress == null) return;
    
    final allAchievements = Achievements.getAll();
    
    for (final achievementData in allAchievements) {
      final id = achievementData['id'] as String;
      
      // Check if already unlocked
      if (_userProgress!.achievements.any((a) => a.id == id)) {
        continue;
      }
      
      bool shouldUnlock = false;
      
      // Check conditions
      switch (id) {
        case 'first_day':
          shouldUnlock = _userProgress!.totalStudyTime > 0;
          break;
        case 'week_streak':
          shouldUnlock = _userProgress!.currentStreak >= 7;
          break;
        case 'month_streak':
          shouldUnlock = _userProgress!.currentStreak >= 30;
          break;
        case 'tajweed_master':
          shouldUnlock = _userProgress!.completedTajweedLessons.length >= 6;
          break;
        case 'memorization_start':
          shouldUnlock = _userProgress!.memorizedVerses.isNotEmpty;
          break;
        case 'hundred_hours':
          shouldUnlock = _userProgress!.totalStudyTime >= 360000; // 100 hours
          break;
      }
      
      if (shouldUnlock) {
        final achievement = Achievement(
          id: id,
          title: achievementData['title'] as String,
          description: achievementData['description'] as String,
          iconName: achievementData['iconName'] as String,
          unlockedAt: DateTime.now(),
        );
        _userProgress!.achievements.add(achievement);
        // Show achievement notification (implement later)
      }
    }
  }
  
  // Toggle reading reminder
  Future<void> toggleReminder(bool enabled) async {
    _reminderEnabled = enabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminderEnabled', enabled);
    
    if (enabled) {
      // Request permissions and schedule notification
      final hasPermission = await NotificationService().requestPermissions();
      if (hasPermission) {
        await NotificationService().scheduleDailyReminder(
          hour: _reminderHour,
          minute: _reminderMinute,
        );
      } else {
        _reminderEnabled = false;
        await prefs.setBool('reminderEnabled', false);
      }
    } else {
      // Cancel notification
      await NotificationService().cancelDailyReminder();
    }
    
    notifyListeners();
  }
  
  // Update reminder time
  Future<void> updateReminderTime(int hour, int minute) async {
    _reminderHour = hour;
    _reminderMinute = minute;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderHour', hour);
    await prefs.setInt('reminderMinute', minute);
    
    // Reschedule if reminder is enabled
    if (_reminderEnabled) {
      await NotificationService().scheduleDailyReminder(
        hour: hour,
        minute: minute,
      );
    }
    
    notifyListeners();
  }
}
