import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../utils/translation_helper.dart';
import '../utils/responsive_helper.dart';

class QuranFlashesScreen extends StatelessWidget {
  final bool showBackButton;
  
  const QuranFlashesScreen({super.key, this.showBackButton = false});

  // Expanded beautiful verses collection
  static const List<Map<String, dynamic>> allVerses = [
    {
      'surah': 2,
      'verse': 186,
      'theme': 'Hope',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFFF6B9D),
    },
    {
      'surah': 94,
      'verse': 5,
      'theme': 'Relief',
      'icon': Icons.wb_sunny_rounded,
      'color': Color(0xFFFFA726),
    },
    {
      'surah': 13,
      'verse': 28,
      'theme': 'Peace',
      'icon': Icons.spa_rounded,
      'color': Color(0xFF66BB6A),
    },
    {
      'surah': 3,
      'verse': 159,
      'theme': 'Trust',
      'icon': Icons.handshake_rounded,
      'color': Color(0xFF42A5F5),
    },
    {
      'surah': 29,
      'verse': 69,
      'theme': 'Guidance',
      'icon': Icons.explore_rounded,
      'color': Color(0xFF9C27B0),
    },
    {
      'surah': 2,
      'verse': 153,
      'theme': 'Patience',
      'icon': Icons.self_improvement_rounded,
      'color': Color(0xFF26A69A),
    },
    {
      'surah': 65,
      'verse': 3,
      'theme': 'Provision',
      'icon': Icons.emoji_nature_rounded,
      'color': Color(0xFF8D6E63),
    },
    {
      'surah': 39,
      'verse': 53,
      'theme': 'Mercy',
      'icon': Icons.favorite_border_rounded,
      'color': Color(0xFFEC407A),
    },
    // Additional verses
    {
      'surah': 2,
      'verse': 255,
      'theme': 'Protection',
      'icon': Icons.shield_rounded,
      'color': Color(0xFF5C6BC0),
    },
    {
      'surah': 3,
      'verse': 173,
      'theme': 'Sufficiency',
      'icon': Icons.check_circle_rounded,
      'color': Color(0xFF7E57C2),
    },
    {
      'surah': 16,
      'verse': 127,
      'theme': 'Perseverance',
      'icon': Icons.fitness_center_rounded,
      'color': Color(0xFFEF5350),
    },
    {
      'surah': 21,
      'verse': 87,
      'theme': 'Darkness',
      'icon': Icons.light_mode_rounded,
      'color': Color(0xFFFFCA28),
    },
    {
      'surah': 25,
      'verse': 58,
      'theme': 'Living',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFFF7043),
    },
    {
      'surah': 33,
      'verse': 3,
      'theme': 'Reliance',
      'icon': Icons.volunteer_activism_rounded,
      'color': Color(0xFF26C6DA),
    },
    {
      'surah': 49,
      'verse': 13,
      'theme': 'Brotherhood',
      'icon': Icons.people_rounded,
      'color': Color(0xFF66BB6A),
    },
    {
      'surah': 55,
      'verse': 13,
      'theme': 'Blessings',
      'icon': Icons.auto_awesome_rounded,
      'color': Color(0xFFFFB74D),
    },
    {
      'surah': 64,
      'verse': 11,
      'theme': 'Destiny',
      'icon': Icons.star_rounded,
      'color': Color(0xFF7986CB),
    },
    {
      'surah': 67,
      'verse': 2,
      'theme': 'Test',
      'icon': Icons.quiz_rounded,
      'color': Color(0xFF9575CD),
    },
    {
      'surah': 93,
      'verse': 4,
      'theme': 'Better Future',
      'icon': Icons.trending_up_rounded,
      'color': Color(0xFF4DB6AC),
    },
    {
      'surah': 94,
      'verse': 6,
      'theme': 'Ease',
      'icon': Icons.sentiment_satisfied_rounded,
      'color': Color(0xFFFFA726),
    },
    {
      'surah': 103,
      'verse': 3,
      'theme': 'Righteousness',
      'icon': Icons.policy_rounded,
      'color': Color(0xFF81C784),
    },
    {
      'surah': 2,
      'verse': 216,
      'theme': 'Knowledge',
      'icon': Icons.school_rounded,
      'color': Color(0xFF64B5F6),
    },
    {
      'surah': 8,
      'verse': 46,
      'theme': 'Unity',
      'icon': Icons.groups_rounded,
      'color': Color(0xFFAB47BC),
    },
    {
      'surah': 11,
      'verse': 88,
      'theme': 'Reform',
      'icon': Icons.change_circle_rounded,
      'color': Color(0xFF4DD0E1),
    },
    {
      'surah': 14,
      'verse': 7,
      'theme': 'Gratitude',
      'icon': Icons.celebration_rounded,
      'color': Color(0xFFFFB300),
    },
  ];

  String _getTranslation(AppProvider appProvider, int surah, int verse) {
    return TranslationHelper.getTranslation(
      surah,
      verse,
      appProvider.selectedTranslation,
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: context.read<AppProvider>().accentColor),
            const SizedBox(width: 12),
            const Text('Copied to clipboard'),
          ],
        ),
        backgroundColor: context.read<AppProvider>().isDarkMode
            ? AppTheme.secondaryDeep
            : Colors.white,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: showBackButton
            ? AppBar(
              scrolledUnderElevation: 0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded, color: appProvider.accentColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Quran Flashes',
                  style: TextStyle(
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: appProvider.accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${allVerses.length} verses',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: appProvider.accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : null,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: responsive.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: showBackButton ? 16 : 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  appProvider.accentColor.withOpacity(0.2),
                                  appProvider.accentColor.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: appProvider.accentColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Inspiring Verses',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                Text(
                                  'Beautiful Quranic wisdom for every situation',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: responsive.largeSpacing),
                    ],
                  ),
                ),
              ),
              
              // Verse cards
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final verse = allVerses[index];
                    return RepaintBoundary(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: responsive.spacing),
                        child: _buildFlashCard(
                          context,
                          verse['surah'] as int,
                          verse['verse'] as int,
                          verse['theme'] as String,
                          verse['icon'] as IconData,
                          verse['color'] as Color,
                          appProvider,
                          isDark,
                          responsive,
                        ),
                      ),
                    );
                  },
                  childCount: allVerses.length,
                ),
              ),
              
              // Bottom spacing
              SliverToBoxAdapter(
                child: SizedBox(height: responsive.largeSpacing),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashCard(
    BuildContext context,
    int surahNumber,
    int verseNumber,
    String theme,
    IconData icon,
    Color themeColor,
    AppProvider appProvider,
    bool isDark,
    ResponsiveHelper responsive,
  ) {
    final verseText = quran.getVerse(surahNumber, verseNumber, verseEndSymbol: true);
    final translation = _getTranslation(appProvider, surahNumber, verseNumber);
    final surahName = quran.getSurahNameArabic(surahNumber);

    return Padding(
      padding: responsive.screenPadding,
      child: GlassCard(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeColor.withOpacity(isDark ? 0.15 : 0.12),
                themeColor.withOpacity(isDark ? 0.05 : 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with theme badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: themeColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 14, color: themeColor),
                          const SizedBox(width: 6),
                          Text(
                            theme,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: themeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Action buttons
                    IconButton(
                      onPressed: () {
                        final text = '$verseText\n\n$translation\n\nQuran $surahNumber:$verseNumber';
                        _copyToClipboard(context, text);
                      },
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: themeColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        final text = '$verseText\n\n$translation\n\nQuran $surahNumber:$verseNumber';
                        SharePlus.instance.share(ShareParams(text: text));
                      },
                      icon: Icon(
                        Icons.share_rounded,
                        size: 18,
                        color: themeColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Arabic verse (RTL)
                // Text(
                //   verseText,
                //   style: AppTheme.arabicTextStyle(
                //     fontSize: responsive.arabicBodySize * 0.9,
                //     fontWeight: FontWeight.w600,
                //     color: isDark ? AppTheme.textLight : AppTheme.textDark,
                //     height: 1.9,
                //   ),
                //   textAlign: TextAlign.right,
                //   textDirection: TextDirection.rtl,
                // ),
                // const SizedBox(height: 10),
                // // Divider
                // Container(
                //   height: 1,
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [
                //         Colors.transparent,
                //         themeColor.withOpacity(0.3),
                //         Colors.transparent,
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 10),
                // Translation (RTL or LTR based on language)
                Text(
                  translation,
                  style: TextStyle(
                    fontSize: appProvider.translationFontSize,
                    color: isDark
                        ? AppTheme.textLight.withOpacity(0.8)
                        : AppTheme.textDark.withOpacity(0.8),
                    height: 1.6,
                  ),
                  textDirection: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  textAlign: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                      ? TextAlign.right
                      : TextAlign.left,
                ),
                const SizedBox(height: 12),
                // Reference
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 14,
                      color: themeColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      surahName,
                      style: AppTheme.arabicTextStyle(
                        fontSize: 14,
                        color: themeColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• $surahNumber:$verseNumber',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
