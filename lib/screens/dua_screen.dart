import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:i_app/utils/responsive_helper.dart';
import 'package:muslim_data_flutter/muslim_data_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class DuaScreen extends StatefulWidget {
  final bool showBackButton;
  const DuaScreen({super.key, this.showBackButton = false});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  bool _isExpanded = false;
  final MuslimRepository _muslimRepository = MuslimRepository();
  bool _isLoadingAzkar = true;
  List<String> _categories = [];
  Map<String, List<Map<String, dynamic>>> _duasByCategory = {};
  
  @override
  void initState() {
    super.initState();
    // Start tracking study session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().startStudySession();
    });
    _loadAzkarData();
  }
  
  @override
  void dispose() {
    // End study session and save time
    context.read<AppProvider>().endStudySession();
    super.dispose();
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: context.read<AppProvider>().accentColor),
            const SizedBox(width: 12),
             Text('Copied to clipboard', style: TextStyle(color:
             context.read<AppProvider>().isDarkMode 
            ?  Colors.white : AppTheme.secondaryDeep,
            
            ),),
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

  void _shareText(String text) {
    // Share.share(text, subject: 'Essential Dhikr');
        SharePlus.instance.share(ShareParams(text: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلاَ إِلَهَ إِلاَّ اللَّهُ وَاللَّهُ أَكْبَرُ وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ'));

  }

  Future<void> _loadAzkarData() async {
    try {
      final categories = await _muslimRepository.getAzkarCategories(
        language: Language.en,
      );

      final Map<String, List<Map<String, dynamic>>> tempDuasByCategory = {};
      final List<String> tempCategories = [];

      for (final category in categories) {
        tempCategories.add(category.name);

        final chapters = await _muslimRepository.getAzkarChapters(
          language: Language.en,
          categoryId: category.id,
        );

        final List<Map<String, dynamic>> categoryDuas = [];

        for (final chapter in chapters) {
          final items = await _muslimRepository.getAzkarItems(
            language: Language.en,
            chapterId: chapter.id,
          );

          for (final item in items) {
            categoryDuas.add({
              'id': item.id,
              'category': category.name,
              'title': chapter.name,
              'arabicTitle': chapter.name,
              'arabic': item.item,
              'transliteration': '',
              'translation': item.translation,
              'benefit': '',
              'repetitions': 1,
              'reference': item.reference,
            });
          }
        }

        tempDuasByCategory[category.name] = categoryDuas;
      }

      if (!mounted) return;

      setState(() {
        _categories = tempCategories;
        _duasByCategory = tempDuasByCategory;
        _isLoadingAzkar = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingAzkar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load azkar data'),
        ),
      );
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('morning')) return Icons.wb_sunny_rounded;
    if (lower.contains('evening')) return Icons.nights_stay_rounded;
    if (lower.contains('sleep')) return Icons.bedtime_rounded;
    if (lower.contains('travel')) return Icons.flight_takeoff_rounded;
    if (lower.contains('prayer')) return Icons.menu_book_rounded;
    if (lower.contains('food')) return Icons.food_bank_sharp;
    if (lower.contains('home')) return FlutterIslamicIcons.solidFamily;
    if (lower.contains('praising')) return FlutterIslamicIcons.solidPrayingPerson;
    if (lower.contains('hajj')) return FlutterIslamicIcons.solidHadji;
    if (lower.contains('nature')) return Icons.photo;
    if (lower.contains('sickness')) return Icons.sick_outlined;
    if (lower.contains('joy')) return Icons.emoji_events;
    return Icons.stars_rounded;
  }


  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required AppProvider appProvider,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: appProvider.accentColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: appProvider.accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: appProvider.accentColor,
        ),
      ),
    );
  }

  Widget _buildDhikrSection() {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final isTinted = appProvider.glassStyle == AppTheme.glassStyleTinted;
    const arabicText = 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلاَ إِلَهَ إِلاَّ اللَّهُ وَاللَّهُ أَكْبَرُ وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ';
    const transliteration = 'Subhanallah walhamdulillah wala ilaha illallah wallahu akbar wala hawla wala quwwata illa billah';
    const translation = 'Glory be to Allah, Praise be to Allah, There is no God but Allah, Allah is Great, There is no Support and No Power except in Allah.';
    const hadith = 'Narrated Abdullah ibn AbuAwfa: A man came to the Prophet (ﷺ) and said: I cannot memorise anything from the Qur\'an: so teach me something which is sufficient for me. He said: Say Glory be to Allah, and praise be to Allah, and there is no god but Allah, and Allah is most great, and there is no might and no strength but in Allah. He said: Messenger of Allah, this is for Allah, but what is for me? He said: O Allah have mercy on me, and sustain me, and keep me well, and guide me. When he stood up, he made a sign with his hand (indicating that he had earned a lot). The Messenger of Allah (ﷺ) said: He filed up his hand with virtues. - Sunan Abi Dawud 832';
    final responsive = context.responsive;
    
    final fullText = '$arabicText\n\n$transliteration\n\n$translation\n\n$hadith';
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: GlassCard(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     colors: [
        //       isTinted ? 
        //       appProvider.accentColor.withOpacity(0.10)
        //       : appProvider.accentColor.withOpacity(0.0),
              
        //       isTinted ? 
        //       appProvider.accentColor.withOpacity(0.05)
        //       : appProvider.accentColor.withOpacity(0.0),
        //     ],
        //   ),
        //   borderRadius: BorderRadius.circular(24),
        //   border: Border.all(
        //     color: appProvider.accentColor.withOpacity(0.3),
        //     width: 1.5,
        //   ),
        //   boxShadow: [
        //     BoxShadow(
        //       color: isTinted ? 
        //       appProvider.accentColor.withOpacity(0.10)
        //       : appProvider.accentColor.withOpacity(0.0),
        //       blurRadius: 20,
        //       offset: const Offset(0, 8),
        //     ),
        //   ],
        // ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.smallSpacing * 1.5,
                      vertical: responsive.smallSpacing * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: appProvider.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 16,
                          color: appProvider.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Essential Dhikr',
                          style: TextStyle(
                            color: appProvider.accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Icons at top right
                  Row(
                    children: [
                      _buildGlassIconButton(
                        icon: Icons.copy_rounded,
                        onPressed: () => _copyToClipboard('سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلاَ إِلَهَ إِلاَّ اللَّهُ وَاللَّهُ أَكْبَرُ وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ'),
                        appProvider: appProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildGlassIconButton(
                        icon: Icons.share_rounded,
                        onPressed: () => _shareText('سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلاَ إِلَهَ إِلاَّ اللَّهُ وَاللَّهُ أَكْبَرُ وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ'),
                        appProvider: appProvider,
                      ),
                    ],
                  ),
                ],
              ),
              // Row(
              //   children: [
              //     Container(
              //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //       decoration: BoxDecoration(
              //         color: appProvider.accentColor.withOpacity(0.2),
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       child: Row(
              //         children: [
              //           Icon(
              //             Icons.auto_awesome_rounded,
              //             size: 16,
              //             color: appProvider.accentColor,
              //           ),
              //           const SizedBox(width: 6),
              //           Text(
              //             '',
              //             style: TextStyle(
              //               color: appProvider.accentColor,
              //               fontWeight: FontWeight.w700,
              //               fontSize: 12,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 20),
              
              // Arabic Text - Always Visible
              Text(
                arabicText,
                style: AppTheme.arabicTextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  height: 2.3,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              
              // Expand/Collapse Button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                 width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: appProvider.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: appProvider.accentColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        // color: appProvider.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isExpanded ? 'Show Less' : 'Show More',
                        style: TextStyle(
                          // color: appProvider.accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                       
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Collapsible Content
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                
                // Decorative divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              appProvider.accentColor.withOpacity(0.4),
                              appProvider.accentColor.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Transliteration
                Text(
                  transliteration,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: isDark 
                        ? AppTheme.textLight.withOpacity(0.85)
                        : AppTheme.textDark.withOpacity(0.75),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Translation
                Text(
                  translation,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                
                // Hadith Reference
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isTinted
                        ? (isDark ? appProvider.accentColor.withOpacity(0.15) : appProvider.accentColor.withOpacity(0.08))
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isTinted
                          ? appProvider.accentColor.withOpacity(0.25)
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.book_rounded,
                            size: 18,
                            color: appProvider.accentColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hadith Reference',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: appProvider.accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hadith,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.6,
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.textLight.withOpacity(0.8)
                              : AppTheme.textDark.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Action buttons
              // Row(
              //   children: [
              //     Expanded(
              //       child: ElevatedButton.icon(
              //         onPressed: () => _copyToClipboard(fullText),
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: isTinted
              //               ? appProvider.accentColor.withOpacity(0.15)
              //               : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
              //           foregroundColor: appProvider.accentColor,
              //           elevation: 0,
              //           padding: const EdgeInsets.symmetric(vertical: 14),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(14),
              //             side: BorderSide(
              //               color: isTinted
              //                   ? appProvider.accentColor.withOpacity(0.3)
              //                   : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
              //               width: 1,
              //             ),
              //           ),
              //         ),
              //         icon: const Icon(Icons.copy_rounded, size: 20),
              //         label: const Text(
              //           'Copy',
              //           style: TextStyle(
              //             fontWeight: FontWeight.w600,
              //             fontSize: 15,
              //           ),
              //         ),
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     Expanded(
              //       child: ElevatedButton.icon(
              //         onPressed: () => _shareText(fullText),
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: appProvider.accentColor,
              //           foregroundColor: Colors.white,
              //           elevation: 0,
              //           padding: const EdgeInsets.symmetric(vertical: 14),
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(14),
              //           ),
              //         ),
              //         icon: const Icon(Icons.share_rounded, size: 20),
              //         label: const Text(
              //           'Share',
              //           style: TextStyle(
              //             fontWeight: FontWeight.w600,
              //             fontSize: 15,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final isTinted = appProvider.glassStyle == AppTheme.glassStyleTinted;
    final responsive = context.responsive;
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground(context.watch<AppProvider>().themeMode),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (widget.showBackButton)
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            'Duas & Azkar',
                            style: Theme.of(context).textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (widget.showBackButton) const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daily Remembrance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: appProvider.accentColor,
                          ),
                    ),
                  ],
                ),
              ),
            
              // Scrollable content with Dhikr + Categories
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Featured Dhikr Section
                      _buildDhikrSection(),

                      const SizedBox(height: 24),

                      // Categories Header
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 24),
                      //   child: Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Text(
                      //       'Dua Categories',
                      //       style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ),
                      // ),
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
                                           FlutterIslamicIcons.solidPrayer,
                                           color: appProvider.accentColor,
                                           size: 20,
                                         ),
                                       ),
                                   const SizedBox(width: 12),
                                   Column(
                                     crossAxisAlignment: CrossAxisAlignment.start,
                                     children: [
                                       Text(
                                         'Dua Categories',
                                         style: TextStyle(
                                           fontSize: 18,
                                           fontWeight: FontWeight.bold,
                                           color: isDark ? AppTheme.textLight : AppTheme.textDark,
                                         ),
                                       ),
                                       Row(
                                         children: [
                                           Container(
                                             width: 320,
                                             child: Text(
                                               'Find authentic supplications for every moment of your day – morning, evening, travel, sleep, and more.',
                                               style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.textLight.withOpacity(0.6)
                              : AppTheme.textDark.withOpacity(0.6),
                                               ),
                                             ),
                                           ),
                                           // Text(
                                           //   ' • ${appProvider.selectedLanguage}',
                                           //   style: TextStyle(
                                           //     fontSize: 11,
                                           //     fontWeight: FontWeight.w600,
                                           //     color: appProvider.accentColor.withOpacity(0.8),
                                           //   ),
                                           // ),
                                         ],
                                       ),
                                     ],
                                   ),
                                   // Verses count
                                   // Text(
                                   //   '25 verses',
                                   //   style: TextStyle(
                                   //     fontSize: 12,
                                   //     fontWeight: FontWeight.w600,
                                   //     color: appProvider.accentColor,
                                   //   ),
                                   // ),
                                     ],
                                   ),
                       ),
          

                      const SizedBox(height: 16),

                      // Categories List
                      _isLoadingAzkar
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                final duas = _duasByCategory[category] ?? [];

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DuaCategoryScreen(
                                          category: category,
                                          duas: duas,
                                        ),
                                      ),
                                    );
                                  },
                                  child: GlassCard(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    // decoration: BoxDecoration(
                                    //   gradient: isTinted
                                    //       ? LinearGradient(
                                    //           begin: Alignment.topLeft,
                                    //           end: Alignment.bottomRight,
                                    //           colors: [
                                    //             appProvider.accentColor.withOpacity(0.12),
                                    //             appProvider.accentColor.withOpacity(0.05),
                                    //           ],
                                    //         )
                                    //       : null,
                                    //   color: !isTinted
                                    //       ? (isDark
                                    //           ? Colors.white.withOpacity(0.00)
                                    //           : Colors.black.withOpacity(0.00))
                                    //       : null,
                                    //   borderRadius: BorderRadius.circular(20),
                                    //   border: Border.all(
                                    //     color: isTinted
                                    //         ? appProvider.accentColor.withOpacity(0.25)
                                    //         : (isDark
                                    //             ? Colors.white.withOpacity(0.12)
                                    //             : appProvider.accentColor.withOpacity(0.24)),
                                    //     width: 1.5,
                                    //   ),
                                    //   boxShadow: isTinted
                                    //       ? [
                                    //           BoxShadow(
                                    //             color: appProvider.accentColor.withOpacity(0.10),
                                    //             blurRadius: 12,
                                    //             offset: const Offset(0, 4),
                                    //           ),
                                    //         ]
                                    //       : [
                                    //           BoxShadow(
                                    //             color: isDark
                                    //                 ? appProvider.accentColor.withOpacity(0.0)
                                    //                 : appProvider.accentColor.withOpacity(0.00),
                                    //             blurRadius: 8,
                                    //             offset: const Offset(0, 2),
                                    //           ),
                                    //         ],
                                    // ),
                                    child: Row(
                                      children: [
                                        // Icon with gradient background
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                appProvider.accentColor
                                                    .withOpacity(isTinted ? 0.2 : 0.15),
                                                appProvider.accentColor
                                                    .withOpacity(isTinted ? 0.4 : 0.25),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: isTinted
                                                ? [
                                                    BoxShadow(
                                                      color: appProvider.accentColor
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              _getCategoryIcon(category),
                                              size: 32,
                                              color: appProvider.accentColor
                                              // isDark
                                              //     ? AppTheme.textLight
                                              //     : AppTheme.textDark,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                    
                                        // Title and count
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                category,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  // fontWeight: FontWeight.bold,
                                                  // color: appProvider.accentColor,
                                                ),
                                                // style: Theme.of(context)
                                                //     .textTheme
                                                //     .titleLarge
                                                //     ?.copyWith(
                                                //       fontWeight: FontWeight.bold,
                                                //       color: isDark
                                                //           ? AppTheme.textLight
                                                //           : AppTheme.textDark,
                                                //     ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.menu_book_rounded,
                                                    size: 14,
                                                    color: appProvider.accentColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${duas.length} Duas',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              appProvider.accentColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                    
                                        // Arrow with background
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: appProvider.accentColor
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: appProvider.accentColor,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DuaCategoryScreen extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> duas;

  const DuaCategoryScreen({
    super.key,
    required this.category,
    required this.duas,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    return Container(
      decoration: AppTheme.gradientBackground(context.watch<AppProvider>().themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(category),
          centerTitle: true,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: duas.length,
          itemBuilder: (context, index) {
            final dua = duas[index];
            
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DuaDetailScreen(dua: dua),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: appProvider.accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dua['title'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isDark
                                    ? AppTheme.textLight
                                    : AppTheme.textDark,
                              ),
                            ),
                            Text(
                              dua['arabicTitle'],
                              style: AppTheme.arabicTextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? AppTheme.textLight.withOpacity(0.8)
                                    : AppTheme.textDark.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Arabic Text (preview)
                  Text(
                    dua['arabic'],
                    style: AppTheme.arabicTextStyle(
                      fontSize: 18,
                      color: isDark
                          ? AppTheme.textLight
                          : AppTheme.textDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Benefit
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: appProvider.accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          dua['benefit'],
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppTheme.textLight.withOpacity(0.7)
                                    : AppTheme.textDark.withOpacity(0.6),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DuaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> dua;

  const DuaDetailScreen({
    super.key,
    required this.dua,
  });

  @override
  State<DuaDetailScreen> createState() => _DuaDetailScreenState();
}

class _DuaDetailScreenState extends State<DuaDetailScreen> {
  int currentRepetition = 0;

  void incrementRepetition() {
    if (currentRepetition < widget.dua['repetitions']) {
      setState(() {
        currentRepetition++;
      });
      
      // Haptic feedback
      HapticFeedback.lightImpact();
      
      // Reset after completion
      if (currentRepetition == widget.dua['repetitions']) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              currentRepetition = 0;
            });
          }
        });
      }
    }
  }

  void resetRepetition() {
    setState(() {
      currentRepetition = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<AppProvider>().isDarkMode;
    final appProvider = context.watch<AppProvider>();
    return Container(
      decoration: AppTheme.gradientBackground(context.watch<AppProvider>().themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.dua['title']),
          centerTitle: true,
          actions: [
            // Copy button
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: () {
                final text = '${widget.dua['arabic']}\n\n${widget.dua['translation']}';
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dua copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            // Share button
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {
                final text = '${widget.dua['title']}\n\n${widget.dua['arabic']}\n\n${widget.dua['translation']}';
                // Share.share(text);
                        SharePlus.instance.share(ShareParams(text: text));

              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Arabic Title
              GlassCard(
                child: Center(
                  child: Text(
                    widget.dua['arabicTitle'],
                    style: AppTheme.arabicTextStyle(
                      fontSize: appProvider.arabicTextSize * 0.9,
                      fontWeight: FontWeight.bold,
                      color: appProvider.accentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Arabic Text
              GlassCard(
                child: SelectableText(
                  widget.dua['arabic'],
                  style: AppTheme.arabicTextStyle(
                    fontSize: appProvider.arabicTextSize,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    height: 2.0,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Transliteration
              // GlassCard(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Transliteration',
              //         style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //               color: appProvider.accentColor,
              //             ),
              //       ),
              //       const SizedBox(height: 8),
              //       SelectableText(
              //         widget.dua['transliteration'],
              //         style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              //               fontStyle: FontStyle.italic,
              //               color: isDark
              //                   ? AppTheme.textLight.withOpacity(0.85)
              //                   : AppTheme.textDark.withOpacity(0.8),
              //             ),
              //       ),
              //     ],
              //   ),
              // ),
              
              // const SizedBox(height: 20),
              
              // Translation
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Translation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: appProvider.accentColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      widget.dua['translation'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: appProvider.translationFontSize,
                        height: 1.6,
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textDark,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // // Benefit
              // GlassCard(
              //   child: Row(
              //     children: [
              //       Icon(
              //         Icons.star_rounded,
              //         color: appProvider.accentColor,
              //       ),
              //       const SizedBox(width: 12),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'Benefit',
              //               style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //                     color: appProvider.accentColor,
              //                   ),
              //             ),
              //             const SizedBox(height: 4),
              //             Text(
              //               widget.dua['benefit'],
              //               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              //                 color: isDark
              //                     ? AppTheme.textLight.withOpacity(0.9)
              //                     : AppTheme.textDark.withOpacity(0.85),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              
              // const SizedBox(height: 20),
              
              // Reference
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reference',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: appProvider.accentColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dua['reference'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textLight.withOpacity(0.7)
                            : AppTheme.textDark.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Counter
              GlassCard(
                child: Column(
                  children: [
                    Text(
                      'Repetitions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: appProvider.accentColor,
                          ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Counter display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$currentRepetition',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: appProvider.accentColor,
                                fontSize: 48,
                              ),
                        ),
                        Text(
                          ' / ${widget.dua['repetitions']}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: isDark 
                                    ? AppTheme.textLight.withOpacity(0.5)
                                    : AppTheme.textDark.withOpacity(0.5),
                              ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Counter button
                    GestureDetector(
                      onTap: incrementRepetition,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentRepetition == widget.dua['repetitions']
                              ? Colors.green.withOpacity(0.3)
                              : appProvider.accentColor.withOpacity(0.2),
                          border: Border.all(
                            color: currentRepetition == widget.dua['repetitions']
                                ? Colors.green
                                : appProvider.accentColor,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            currentRepetition == widget.dua['repetitions']
                                ? Icons.check_rounded
                                : Icons.touch_app_rounded,
                            size: 48,
                            color: currentRepetition == widget.dua['repetitions']
                                ? Colors.green
                                : appProvider.accentColor,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Reset button
                    if (currentRepetition > 0)
                      TextButton.icon(
                        onPressed: resetRepetition,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reset'),
                        style: TextButton.styleFrom(
                          foregroundColor: appProvider.accentColor,
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
