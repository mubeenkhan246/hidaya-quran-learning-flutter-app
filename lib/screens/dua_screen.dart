import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../constants/dua_constants.dart';
import '../widgets/glass_card.dart';

class DuaScreen extends StatefulWidget {
  final bool showBackButton;
  const DuaScreen({super.key, this.showBackButton = false});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    // Start tracking study session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().startStudySession();
    });
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

  void _shareText(String text) {
    // Share.share(text, subject: 'Essential Dhikr');
        SharePlus.instance.share(ShareParams(text: 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلاَ إِلَهَ إِلاَّ اللَّهُ وَاللَّهُ أَكْبَرُ وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ'));

  }

  Widget _buildDhikrSection() {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final isTinted = appProvider.glassStyle == AppTheme.glassStyleTinted;
    const arabicText = 'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلاَ إِلَهَ إِلاَّ اللَّهُ وَاللَّهُ أَكْبَرُ وَلاَ حَوْلَ وَلاَ قُوَّةَ إِلاَّ بِاللَّهِ';
    const transliteration = 'Subhanallah walhamdulillah wala ilaha illallah wallahu akbar wala hawla wala quwwata illa billah';
    const translation = 'Glory be to Allah, Praise be to Allah, There is no God but Allah, Allah is Great, There is no Support and No Power except in Allah.';
    const hadith = 'Narrated Abdullah ibn AbuAwfa: A man came to the Prophet (ﷺ) and said: I cannot memorise anything from the Qur\'an: so teach me something which is sufficient for me. He said: Say Glory be to Allah, and praise be to Allah, and there is no god but Allah, and Allah is most great, and there is no might and no strength but in Allah. He said: Messenger of Allah, this is for Allah, but what is for me? He said: O Allah have mercy on me, and sustain me, and keep me well, and guide me. When he stood up, he made a sign with his hand (indicating that he had earned a lot). The Messenger of Allah (ﷺ) said: He filed up his hand with virtues. - Sunan Abi Dawud 832';
    
    final fullText = '$arabicText\n\n$transliteration\n\n$translation\n\n$hadith';
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isTinted ? 
              appProvider.accentColor.withOpacity(0.10)
              : appProvider.accentColor.withOpacity(0.0),
              
              isTinted ? 
              appProvider.accentColor.withOpacity(0.05)
              : appProvider.accentColor.withOpacity(0.0),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: appProvider.accentColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isTinted ? 
              appProvider.accentColor.withOpacity(0.10)
              : appProvider.accentColor.withOpacity(0.0),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: appProvider.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
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
                ],
              ),
              const SizedBox(height: 20),
              
              // Arabic Text - Always Visible
              Text(
                arabicText,
                style: AppTheme.arabicTextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: appProvider.accentColor,
                  height: 2.3,
                ),
                textAlign: TextAlign.center,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isTinted
                        ? appProvider.accentColor.withOpacity(0.15)
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTinted
                          ? appProvider.accentColor.withOpacity(0.3)
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isExpanded ? 'Show Less' : 'Show More',
                        style: TextStyle(
                          color: appProvider.accentColor,
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(fullText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTinted
                            ? appProvider.accentColor.withOpacity(0.15)
                            : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
                        foregroundColor: appProvider.accentColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isTinted
                                ? appProvider.accentColor.withOpacity(0.3)
                                : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
                            width: 1,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 20),
                      label: const Text(
                        'Copy',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareText(fullText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appProvider.accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 20),
                      label: const Text(
                        'Share',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Dua Categories',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Categories List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: DuaConstants.getAllCategories().length,
                      itemBuilder: (context, index) {
                  final category = DuaConstants.getAllCategories()[index];
                  final duas = DuaConstants.getDuasByCategory(category);
                  
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
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: isTinted
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  appProvider.accentColor.withOpacity(0.12),
                                  appProvider.accentColor.withOpacity(0.05),
                                ],
                              )
                            : null,
                        color: !isTinted
                            ? (isDark ? Colors.white.withOpacity(0.00) : Colors.black.withOpacity(0.00))
                            : null,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isTinted
                              ? appProvider.accentColor.withOpacity(0.25)
                              : (isDark ? Colors.white.withOpacity(0.12) : appProvider.accentColor.withOpacity(0.24)),
                          width: 1.5,
                        ),
                        boxShadow: isTinted
                            ? [
                                BoxShadow(
                                  color: appProvider.accentColor.withOpacity(0.10),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: isDark 
                                      ? appProvider.accentColor.withOpacity(0.0)
                                      : appProvider.accentColor.withOpacity(0.00),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
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
                                    appProvider.accentColor.withOpacity(isTinted ? 0.2 : 0.15),
                                    appProvider.accentColor.withOpacity(isTinted ? 0.4 : 0.25),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: isTinted
                                    ? [
                                        BoxShadow(
                                          color: appProvider.accentColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  DuaConstants.getCategoryIcon(category),
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Title and count
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppTheme.textLight
                                          : AppTheme.textDark,
                                    ),
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
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: appProvider.accentColor,
                                          fontWeight: FontWeight.w600,
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
                                color: appProvider.accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.dua['title']),
          centerTitle: true,
          actions: [
            // Copy button
            IconButton(
              icon: const Icon(Icons.copy_rounded),
              onPressed: () {
                final text = '${widget.dua['arabic']}\n\n${widget.dua['transliteration']}\n\n${widget.dua['translation']}';
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
                final text = '${widget.dua['title']}\n\n${widget.dua['arabic']}\n\n${widget.dua['transliteration']}\n\n${widget.dua['translation']}';
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
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
                    fontSize: 28,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Transliteration
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transliteration',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: appProvider.accentColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      widget.dua['transliteration'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? AppTheme.textLight.withOpacity(0.85)
                                : AppTheme.textDark.withOpacity(0.8),
                          ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
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
                        color: isDark
                            ? AppTheme.textLight
                            : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Benefit
              GlassCard(
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: appProvider.accentColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Benefit',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: appProvider.accentColor,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.dua['benefit'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppTheme.textLight.withOpacity(0.9)
                                  : AppTheme.textDark.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
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
