/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Hidayah';
  static const String appVersion = '1.0.0';
  
  // Supported Translation Languages (from quran package)
  static const List<Map<String, String>> supportedTranslations = [
    {'name': 'English (Saheeh International)', 'code': 'en_saheeh', 'key': 'enSaheeh'},
    {'name': 'English (Clear Quran)', 'code': 'en_clear', 'key': 'enClearQuran'},
    {'name': 'Urdu', 'code': 'ur', 'key': 'urdu'},
    {'name': 'Indonesian', 'code': 'id', 'key': 'indonesian'},
    {'name': 'French', 'code': 'fr', 'key': 'frHamidullah'},
    {'name': 'Turkish', 'code': 'tr', 'key': 'trSaheeh'},
    {'name': 'Malayalam', 'code': 'ml', 'key': 'mlAbdulHameed'},
    {'name': 'Farsi', 'code': 'fa', 'key': 'faHusseinDari'},
    {'name': 'Portuguese', 'code': 'pt', 'key': 'portuguese'},
    {'name': 'Italian', 'code': 'it', 'key': 'itPiccardo'},
    {'name': 'Dutch', 'code': 'nl', 'key': 'nlSiregar'},
    {'name': 'Russian', 'code': 'ru', 'key': 'ruKuliev'},
    {'name': 'Bengali', 'code': 'bn', 'key': 'bengali'},
    {'name': 'Chinese', 'code': 'zh', 'key': 'chinese'},
    {'name': 'Swedish', 'code': 'sv', 'key': 'swedish'},
    {'name': 'Spanish', 'code': 'es', 'key': 'spanish'},
  ];
  
  // Legacy support - kept for backward compatibility
  static const List<String> supportedLanguages = [
    'English (Saheeh International)',
    'English (Clear Quran)',
    'Urdu',
    'Indonesian',
    'French',
    'Turkish',
    'Malayalam',
    'Farsi',
    'Portuguese',
    'Italian',
    'Dutch',
    'Russian',
    'Bengali',
    'Chinese',
    'Swedish',
    'Spanish',
  ];
  
  // Available Reciters (from quran package)
  static const List<Map<String, String>> reciters = [
    {
      'name': 'Mishary Rashid Alafasy',
      'arabicName': 'مشاري راشد العفاسي',
      'key': 'arAlafasy',
      'identifier': 'Alafasy',
    },
    {
      'name': 'Mahmoud Khalil Al-Hussary',
      'arabicName': 'محمود خليل الحصري',
      'key': 'arHusary',
      'identifier': 'Husary',
    },
    {
      'name': 'Ahmed al-Ajamy',
      'arabicName': 'أحمد العجمي',
      'key': 'arAhmedAjamy',
      'identifier': 'Ahmed al-Ajamy',
    },
    {
      'name': 'Ali Hudhaify',
      'arabicName': 'علي الحذيفي',
      'key': 'arHudhaify',
      'identifier': 'Hudhaify',
    },
    {
      'name': 'Maher Al Muaiqly',
      'arabicName': 'ماهر المعيقلي',
      'key': 'arMaherMuaiqly',
      'identifier': 'Maher Al Muaiqly',
    },
    {
      'name': 'Muhammad Ayyoub',
      'arabicName': 'محمد أيوب',
      'key': 'arMuhammadAyyoub',
      'identifier': 'Muhammad Ayyoub',
    },
    {
      'name': 'Muhammad Jibreel',
      'arabicName': 'محمد جبريل',
      'key': 'arMuhammadJibreel',
      'identifier': 'Muhammad Jibreel',
    },
    {
      'name': 'Mohamed Siddiq al-Minshawi',
      'arabicName': 'محمد صديق المنشاوي',
      'key': 'arMinshawi',
      'identifier': 'Minshawi',
    },
    {
      'name': 'Abu Bakr Ash-Shaatree',
      'arabicName': 'أبو بكر الشاطري',
      'key': 'arShaatree',
      'identifier': 'Abu Bakr Ash-Shaatree',
    },
  ];
  
  // Tajweed Rules
  static const List<Map<String, dynamic>> tajweedRules = [
    {
      'id': 1,
      'title': 'Noon Sakinah & Tanween',
      'arabicTitle': 'أحكام النون الساكنة والتنوين',
      'category': 'Basic Rules',
      'duration': 480, // seconds
    },
    {
      'id': 2,
      'title': 'Meem Sakinah',
      'arabicTitle': 'أحكام الميم الساكنة',
      'category': 'Basic Rules',
      'duration': 360,
    },
    {
      'id': 3,
      'title': 'Qalqalah',
      'arabicTitle': 'القلقلة',
      'category': 'Basic Rules',
      'duration': 300,
    },
    {
      'id': 4,
      'title': 'Madd (Elongation)',
      'arabicTitle': 'المد',
      'category': 'Intermediate',
      'duration': 600,
    },
    {
      'id': 5,
      'title': 'Idgham (Assimilation)',
      'arabicTitle': 'الإدغام',
      'category': 'Intermediate',
      'duration': 420,
    },
    {
      'id': 6,
      'title': 'Makharij al-Huruf (Articulation Points)',
      'arabicTitle': 'مخارج الحروف',
      'category': 'Advanced',
      'duration': 900,
    },
  ];
  
  // Playback Speeds
  static const List<double> playbackSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  
  // Daily Goal Options (minutes)
  static const List<int> dailyGoalOptions = [5, 10, 15, 20, 30, 45, 60];
  
  // Donation Tiers (USD) - Consumable In-App Purchases
  static const List<Map<String, dynamic>> donationTiers = [
    {
      'id': '11',
      'name': 'Small Support',
      'emoji': '☕',
      'price': '\$0.99',
      'description': 'Buy us a coffee',
    },
    {
      'id': '12',
      'name': 'Kind Supporter',
      'emoji': '🌟',
      'price': '\$1.99',
      'description': 'Help us continue',
    },
    {
      'id': '13',
      'name': 'Generous Helper',
      'emoji': '💝',
      'price': '\$2.99',
      'description': 'Support development',
    },
    {
      'id': '15',
      'name': 'Amazing Donor',
      'emoji': '🎁',
      'price': '\$4.99',
      'description': 'Meaningful contribution',
    },
    {
      'id': '20',
      'name': 'Blessed Patron',
      'emoji': '👑',
      'price': '\$9.99',
      'description': 'Outstanding generosity',
    },
  ];
  
  // Text Size Options
  static const Map<String, double> textSizes = {
    'Small': 20.0,
    'Medium': 24.0,
    'Large': 28.0,
    'Extra Large': 32.0,
  };
  
  // Storage Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyHadithLanguage = 'hadith_language';
  static const String keyDailyGoal = 'daily_goal';
  static const String keyCurrentStreak = 'current_streak';
  static const String keyTotalStudyTime = 'total_study_time';
  static const String keyLastStudyDate = 'last_study_date';
  static const String keySelectedReciter = 'selected_reciter';
  static const String keySelectedTranslation = 'selected_translation';
  static const String keyPlaybackSpeed = 'playback_speed';
  static const String keyThemeMode = 'theme_mode';
  static const String keyGlassStyle = 'glass_style'; // 'clear' or 'tinted'
  static const String keyThemeColor = 'theme_color'; // Theme color ID
  static const String keyArabicTextSize = 'arabic_text_size'; // Text size for Arabic
  static const String keyBaseFontSize = 'base_font_size'; // Base font size for entire app (16-30px)
  static const String keyTranslationFontSize = 'translation_font_size'; // Translation/English text size (12-24px)
  static const String keyQuranDisplayMode = 'quran_display_mode';
}
