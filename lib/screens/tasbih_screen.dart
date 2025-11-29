import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class TasbihScreen extends StatefulWidget {
  final bool showBackButton;
  const TasbihScreen({super.key, this.showBackButton = false});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with SingleTickerProviderStateMixin {
  int _count = 0;
  int _targetCount = 33;
  int _selectedDhikrIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  List<int> _dailyDhikrs = []; // Selected daily dhikrs by index
  
  final List<Map<String, dynamic>> _dhikrs = [
    {
      'arabic': 'سُبْحَانَ اللّٰهِ',
      'transliteration': 'SubhanAllah',
      'translation': 'Glory be to Allah',
      'count': 33,
      'meaning': 'Glorifying Allah',
    },
    {
      'arabic': 'الْحَمْدُ لِلّٰهِ',
      'transliteration': 'Alhamdulillah',
      'translation': 'All praise is due to Allah',
      'count': 33,
      'meaning': 'Praising Allah',
    },
    {
      'arabic': 'اللّٰهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
      'translation': 'Allah is the Greatest',
      'count': 34,
      'meaning': 'Magnifying Allah',
    },
    {
      'arabic': 'لَا إِلَٰهَ إِلَّا اللّٰهُ',
      'transliteration': 'La ilaha illallah',
      'translation': 'There is no god but Allah',
      'count': 100,
      'meaning': 'Affirming Tawheed',
    },
    {
      'arabic': 'أَسْتَغْفِرُ اللّٰهَ',
      'transliteration': 'Astaghfirullah',
      'translation': 'I seek forgiveness from Allah',
      'count': 100,
      'meaning': 'Seeking Forgiveness',
    },
    {
      'arabic': 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ',
      'transliteration': 'SubhanAllahi wa bihamdihi',
      'translation': 'Glory be to Allah and praise Him',
      'count': 100,
      'meaning': 'Complete Glorification',
    },
    {
      'arabic': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ',
      'transliteration': 'La hawla wa la quwwata illa billah',
      'translation': 'There is no power except with Allah',
      'count': 100,
      'meaning': 'Acknowledging Allah\'s Power',
    },
    {
      'arabic': 'صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ',
      'transliteration': 'Sallallahu alayhi wasallam',
      'translation': 'May Allah\'s peace and blessings be upon him',
      'count': 100,
      'meaning': 'Sending Salawat',
    },
  ];

  @override
  void initState() {
    super.initState();
    _targetCount = _dhikrs[_selectedDhikrIndex]['count'] as int;
    
    // Load saved state
    _loadState();
    
    // Start tracking study session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().startStudySession();
    });
    
    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    // Save current state before closing
    _saveState();
    // End study session and save time
    context.read<AppProvider>().endStudySession();
    _pulseController.dispose();
    super.dispose();
  }
  
  // Load saved state from SharedPreferences
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _count = prefs.getInt('tasbih_count') ?? 0;
      _selectedDhikrIndex = prefs.getInt('tasbih_selected_index') ?? 0;
      _targetCount = prefs.getInt('tasbih_target') ?? _dhikrs[_selectedDhikrIndex]['count'] as int;
      final dailyList = prefs.getStringList('tasbih_daily_dhikrs') ?? [];
      _dailyDhikrs = dailyList.map((e) => int.parse(e)).toList();
    });
  }
  
  // Save current state to SharedPreferences
  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tasbih_count', _count);
    await prefs.setInt('tasbih_selected_index', _selectedDhikrIndex);
    await prefs.setInt('tasbih_target', _targetCount);
    await prefs.setStringList('tasbih_daily_dhikrs', _dailyDhikrs.map((e) => e.toString()).toList());
  }
  
  // Toggle daily dhikr selection
  void _toggleDailyDhikr(int index) {
    setState(() {
      if (_dailyDhikrs.contains(index)) {
        _dailyDhikrs.remove(index);
      } else {
        _dailyDhikrs.add(index);
      }
    });
    _saveState();
  }

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
      // Provide haptic feedback when reaching target milestone
      if (_count == _targetCount) {
        HapticFeedback.heavyImpact();
      }
    });
    
    // Add 1 to daily dhikr total count on every tap
    _addTapToTotal();
    
    // Save state after each increment
    _saveState();
    
    _pulseController.forward().then((_) => _pulseController.reverse());
  }
  
  Future<void> _addTapToTotal() async {
    final appProvider = context.read<AppProvider>();
    final dhikrName = _dhikrs[_selectedDhikrIndex]['transliteration'] as String;
    
    if (appProvider.userProgress != null) {
      // Add 1 to the total tap count for this dhikr
      appProvider.userProgress!.addDhikrCompletion(dhikrName, 1);
      await appProvider.updateProgress(appProvider.userProgress!);
    }
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _count = 0;
    });
    // Save state after reset
    _saveState();
  }

  void _selectDhikr(int index) {
    setState(() {
      _selectedDhikrIndex = index;
      _targetCount = _dhikrs[index]['count'] as int;
      _count = 0;
    });
    // Save state after dhikr change
    _saveState();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final isTinted = appProvider.glassStyle == AppTheme.glassStyleTinted;
    final selectedDhikr = _dhikrs[_selectedDhikrIndex];
    final progress = _count / _targetCount;

    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground(appProvider.themeMode),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
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
                        child: Column(
                          children: [
                            Text(
                              'Tasbih Counter',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              ),
                            ),
                            Text(
                              'Digital Prayer Beads',
                              style: TextStyle(
                                fontSize: 14,
                                color: appProvider.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _count > 0 ? _reset : null,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: _count > 0 ? appProvider.accentColor : Colors.grey,
                        ),
                        tooltip: 'Reset',
                      ),
                    ],
                  ),
                ),
              // Current Dhikr Display
              Padding(
                padding: const EdgeInsets.all(24),
                child: GlassCard(
                        child: Column(
                          children: [
                            // Arabic Text
                            Text(
                              selectedDhikr['arabic'] as String,
                              style: AppTheme.arabicTextStyle(
                                fontSize: 40,
                                color: appProvider.accentColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            
                            // Transliteration
                            Text(
                              selectedDhikr['transliteration'] as String,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppTheme.textLight
                                        : AppTheme.textDark,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            
                            // Translation
                            Text(
                              selectedDhikr['translation'] as String,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark
                                        ? AppTheme.textLight.withOpacity(0.7)
                                        : AppTheme.textDark.withOpacity(0.7),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Meaning Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: appProvider.accentColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: appProvider.accentColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.label_rounded,
                                        size: 14,
                                        color: appProvider.accentColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        selectedDhikr['meaning'] as String,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: appProvider.accentColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Completion Count
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        appProvider.accentColor.withOpacity(0.2),
                                        appProvider.accentColor.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: appProvider.accentColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        size: 14,
                                        color: appProvider.accentColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${appProvider.userProgress?.getDhikrCompletions(selectedDhikr['transliteration'] as String) ?? 0}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: appProvider.accentColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Counter Circle - Enhanced Design
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: InkWell(
                        onTap: _increment,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Stack(
                                // alignment: Alignment.center,
                                children: [
                                  // Outer Glow Ring
                                  Container(
                                    width: 260,
                                    height: 260,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          appProvider.accentColor.withOpacity(0.1),
                                          appProvider.accentColor.withOpacity(0.3),
                                          appProvider.accentColor.withOpacity(0.5),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                                Text(
                                              _count.toString(),
                                              style: TextStyle(
                                                fontSize: 72,
                                                fontWeight: FontWeight.w900,
                                                color: appProvider.accentColor,
                                                height: 1,
                                                // letterSpacing: -2,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            
                                            // Target Label
                                            // Container(
                                            //   padding: const EdgeInsets.symmetric(
                                            //     horizontal: 12,
                                            //     vertical: 4,
                                            //   ),
                                            //   decoration: BoxDecoration(
                                            //     color: Colors.white.withOpacity(0.15),
                                            //     borderRadius: BorderRadius.circular(12),
                                            //   ),
                                            //   child: Text(
                                            //     'of $_targetCount',
                                            //     style: TextStyle(
                                            //       fontSize: 14,
                                            //       fontWeight: FontWeight.w600,
                                            //       color: Colors.white,
                                            //     ),
                                            //   ),
                                            // ),
                                            const SizedBox(height: 20),
                                            
                                            // Tap Indicator
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.touch_app_rounded,
                                                  size: 16,
                                                  color: appProvider.accentColor,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'TAP',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: appProvider.accentColor,
                                                    letterSpacing: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ],),
                                  ),
                                  
                                  // Progress Ring Background
                                  SizedBox(
                                    width: 260,
                                    height: 260,
                                    child: CircularProgressIndicator(
                                      value: 1.0,
                                      strokeWidth: 12,
                                      backgroundColor: Colors.transparent,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                                      ),
                                    ),
                                  ),
                                  
                                  // Progress Ring Gradient
                                  // SizedBox(
                                  //   width: 260,
                                  //   height: 260,
                                  //   child: TweenAnimationBuilder<double>(
                                  //     duration: const Duration(milliseconds: 300),
                                  //     curve: Curves.easeOut,
                                  //     tween: Tween<double>(begin: 0, end: progress),
                                  //     builder: (context, value, child) {
                                  //       return CustomPaint(
                                  //         painter: GradientProgressPainter(
                                  //           progress: value,
                                  //           startColor: appProvider.accentColor,
                                  //           endColor: appProvider.accentColor.withOpacity(0.9),
                                  //           strokeWidth: 12,
                                  //         ),
                                  //       );
                                  //     },
                                  //   ),
                                  // ),
                                  
                                  // Main Button
                                  // Container(
                                  //   width: 260,
                                  //   height: 260,
                                  //   decoration: BoxDecoration(
                                  //     shape: BoxShape.circle,
                                  //     gradient: LinearGradient(
                                  //       begin: Alignment.topLeft,
                                  //       end: Alignment.bottomRight,
                                  //       colors: isTinted
                                  //           ? [
                                  //               appProvider.accentColor.withOpacity(0.3),
                                  //               appProvider.accentColor.withOpacity(0.2),
                                  //               appProvider.accentColor.withOpacity(0.1),
                                  //             ]
                                  //           : [
                                  //               (isDark ? Colors.white : Colors.black).withOpacity(0),
                                  //               (isDark ? Colors.white : Colors.black).withOpacity(0),
                                  //               (isDark ? Colors.white : Colors.black).withOpacity(0),
                                  //             ],
                                  //     ),
                                  //     boxShadow: [
                                  //       BoxShadow(
                                  //         color: appProvider.accentColor.withOpacity(0.4),
                                  //         blurRadius: 50,
                                  //         spreadRadius: 0,
                                  //       ),
                                  //       BoxShadow(
                                  //         color: (isDark ? Colors.black.withOpacity(0) : Colors.black).withOpacity(0),
                                  //         blurRadius: 30,
                                  //         offset: const Offset(0, 15),
                                  //       ),
                                  //     ],
                                  //   ),
                                  //   child: Container(
                                  //     margin: const EdgeInsets.all(4),
                                  //     decoration: BoxDecoration(
                                  //       shape: BoxShape.circle,
                                  //       gradient: LinearGradient(
                                  //         begin: Alignment.topLeft,
                                  //         end: Alignment.bottomRight,
                                  //         colors: isTinted
                                  //             ? [
                                  //                 appProvider.accentColor.withOpacity(0.15),
                                  //                 appProvider.accentColor.withOpacity(0.05),
                                  //               ]
                                  //             : [
                                  //                 (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                                  //                 (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                                  //               ],
                                  //       ),
                                  //       border: Border.all(
                                  //         color: appProvider.accentColor.withOpacity(0.3),
                                  //         width: 2,
                                  //       ),
                                  //     ),
                                  //     child: Center(
                                  //       child: Column(
                                  //         mainAxisAlignment: MainAxisAlignment.center,
                                  //         children: [
                                  //           // Count Number
                                  //           Text(
                                  //             _count.toString(),
                                  //             style: TextStyle(
                                  //               fontSize: 72,
                                  //               fontWeight: FontWeight.w900,
                                  //               color: appProvider.accentColor,
                                  //               height: 1,
                                  //               // letterSpacing: -2,
                                  //             ),
                                  //           ),
                                  //           const SizedBox(height: 8),
                                            
                                  //           // Target Label
                                  //           // Container(
                                  //           //   padding: const EdgeInsets.symmetric(
                                  //           //     horizontal: 12,
                                  //           //     vertical: 4,
                                  //           //   ),
                                  //           //   decoration: BoxDecoration(
                                  //           //     color: Colors.white.withOpacity(0.15),
                                  //           //     borderRadius: BorderRadius.circular(12),
                                  //           //   ),
                                  //           //   child: Text(
                                  //           //     'of $_targetCount',
                                  //           //     style: TextStyle(
                                  //           //       fontSize: 14,
                                  //           //       fontWeight: FontWeight.w600,
                                  //           //       color: Colors.white,
                                  //           //     ),
                                  //           //   ),
                                  //           // ),
                                  //           const SizedBox(height: 20),
                                            
                                  //           // Tap Indicator
                                  //           Row(
                                  //             mainAxisSize: MainAxisSize.min,
                                  //             children: [
                                  //               Icon(
                                  //                 Icons.touch_app_rounded,
                                  //                 size: 16,
                                  //                 color: Colors.white,
                                  //               ),
                                  //               const SizedBox(width: 6),
                                  //               Text(
                                  //                 'TAP',
                                  //                 style: TextStyle(
                                  //                   fontSize: 12,
                                  //                   fontWeight: FontWeight.bold,
                                  //                   color: Colors.white,
                                  //                   letterSpacing: 2,
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Daily Dhikrs Section
                    if (_dailyDhikrs.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.event_repeat_rounded,
                                  color: appProvider.accentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Daily Dhikrs',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: appProvider.accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 130,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: _dailyDhikrs.length,
                              itemBuilder: (context, idx) {
                                final dhikrIndex = _dailyDhikrs[idx];
                                final dhikr = _dhikrs[dhikrIndex];
                                final completions = appProvider.userProgress?.getDhikrCompletions(dhikr['transliteration'] as String) ?? 0;
                                
                                return GestureDetector(
                                  onTap: () => _selectDhikr(dhikrIndex),
                                  child: Container(
                                    width: 140,
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          appProvider.accentColor.withOpacity(0.2),
                                          appProvider.accentColor.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: appProvider.accentColor.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          dhikr['arabic'] as String,
                                          style: AppTheme.arabicTextStyle(
                                            fontSize: 18,
                                            color: appProvider.accentColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dhikr['transliteration'] as String,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: appProvider.accentColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: appProvider.accentColor,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '$completions',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    
                    // Dhikr Selection
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Dhikr',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          
                          // Dhikr Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
                              childAspectRatio: 2/2.8,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _dhikrs.length,
                            itemBuilder: (context, index) {
                              final dhikr = _dhikrs[index];
                              final isSelected = index == _selectedDhikrIndex;
                              
                              final completions = appProvider.userProgress?.getDhikrCompletions(dhikr['transliteration'] as String) ?? 0;
                              final isDaily = _dailyDhikrs.contains(index);
                              
                              return GlassCard(
                                margin: EdgeInsets.zero,
                                onTap: () => _selectDhikr(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: isSelected
                                        ? appProvider.accentColor.withOpacity(0.1)
                                        : Colors.transparent,
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Top Row - Star
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _toggleDailyDhikr(index),
                                            child: Icon(
                                              isDaily ? Icons.star_rounded : Icons.star_border_rounded,
                                              color: isDaily ? Colors.amber : Colors.grey,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      // Center - Dhikr Info
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              dhikr['arabic'] as String,
                                              style: AppTheme.arabicTextStyle(
                                                fontSize: 24,
                                                color: isSelected
                                                    ? appProvider.accentColor
                                                    : (isDark ? AppTheme.textLight : AppTheme.textDark),
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              dhikr['transliteration'] as String,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? AppTheme.textLight.withOpacity(0.8)
                                                        : AppTheme.textDark.withOpacity(0.8),
                                                  ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Bottom - Completion Count
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  colors: [
                                                    appProvider.accentColor,
                                                    appProvider.accentColor.withOpacity(0.7),
                                                  ],
                                                )
                                              : null,
                                          color: isSelected
                                              ? null
                                              : (isDark ? Colors.white : Colors.black).withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isSelected ? Icons.check_rounded : Icons.history_rounded,
                                              size: 14,
                                              color: isSelected
                                                  ? Colors.white
                                                  : appProvider.accentColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$completions',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isSelected
                                                    ? Colors.white
                                                    : appProvider.accentColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Tips Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_rounded,
                                  color: appProvider.accentColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Tasbih Tips',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: appProvider.accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTip(context, appProvider, '• After Salah, recite 33x SubhanAllah, 33x Alhamdulillah, 34x Allahu Akbar'),
                            const SizedBox(height: 8),
                            _buildTip(context, appProvider, '• Morning & Evening: Recite each dhikr 100 times for maximum barakah'),
                            const SizedBox(height: 8),
                            _buildTip(context, appProvider, '• Keep your tongue moist with the remembrance of Allah throughout the day'),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, AppProvider appProvider, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: appProvider.isDarkMode
                ? AppTheme.textLight.withOpacity(0.8)
                : AppTheme.textDark.withOpacity(0.8),
            height: 1.5,
          ),
    );
  }
}

// Custom Painter for Gradient Progress Ring
class GradientProgressPainter extends CustomPainter {
  final double progress;
  final Color startColor;
  final Color endColor;
  final double strokeWidth;

  GradientProgressPainter({
    required this.progress,
    required this.startColor,
    required this.endColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    
    final gradient = SweepGradient(
      startAngle: -3.14 / 2,
      endAngle: -3.14 / 2 + (2 * 3.14 * progress),
      colors: [startColor, endColor],
      tileMode: TileMode.clamp,
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawArc(
      rect,
      -3.14 / 2,
      2 * 3.14 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(GradientProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
