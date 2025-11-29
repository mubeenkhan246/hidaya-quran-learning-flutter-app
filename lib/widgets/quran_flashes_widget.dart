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

class QuranFlashesWidget extends StatelessWidget {
  final int? maxVerses; // Limit number of verses to show (null = show all)
  
  const QuranFlashesWidget({super.key, this.maxVerses});

  // Curated beautiful verses
  static const List<Map<String, dynamic>> verses = [
    {
      'surah': 2,
      'verse': 186,
      'theme': 'Hope',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFFF6B9D),
    },
    {
      'surah': 94,
      'verse': 5,
      'theme': 'Relief',
      'icon': Icons.wb_sunny_rounded,
      'color': const Color(0xFFFFA726),
    },
    {
      'surah': 13,
      'verse': 28,
      'theme': 'Peace',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFF66BB6A),
    },
    {
      'surah': 3,
      'verse': 159,
      'theme': 'Trust',
      'icon': Icons.handshake_rounded,
      'color': const Color(0xFF42A5F5),
    },
    {
      'surah': 29,
      'verse': 69,
      'theme': 'Guidance',
      'icon': Icons.explore_rounded,
      'color': const Color(0xFF9C27B0),
    },
    {
      'surah': 2,
      'verse': 153,
      'theme': 'Patience',
      'icon': Icons.self_improvement_rounded,
      'color': const Color(0xFF26A69A),
    },
    {
      'surah': 65,
      'verse': 3,
      'theme': 'Provision',
      'icon': Icons.emoji_nature_rounded,
      'color': const Color(0xFF8D6E63),
    },
    {
      'surah': 39,
      'verse': 53,
      'theme': 'Mercy',
      'icon': Icons.favorite_border_rounded,
      'color': const Color(0xFFEC407A),
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
    
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = appProvider.isDarkMode;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: responsive.screenPadding,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appProvider.accentColor.withOpacity(0.2),
                          appProvider.accentColor.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: appProvider.accentColor,
                      size: 20,
                    ),
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quran Flashes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Inspiring verses',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.textLight.withOpacity(0.6)
                                : AppTheme.textDark.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          ' • ${appProvider.selectedLanguage}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: appProvider.accentColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Verses count
              Text(
                '25 verses',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: appProvider.accentColor,
                ),
              ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Cards with RepaintBoundary for better performance
            ...(maxVerses != null ? verses.take(maxVerses!) : verses).map((verse) => RepaintBoundary(
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
            )),
            const SizedBox(height: 8),
          ],
        );
      },
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      verseText,
                      style: AppTheme.arabicTextStyle(
                        fontSize: responsive.arabicBodySize * 0.9,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        height: 1.9,
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        themeColor.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
