import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import 'surah_detail_screen.dart';
import 'full_surah_player_screen.dart';

class ManzilScreen extends StatefulWidget {
  final bool showBackButton;
  const ManzilScreen({super.key, this.showBackButton = false});

  @override
  State<ManzilScreen> createState() => _ManzilScreenState();
}

class _ManzilScreenState extends State<ManzilScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<int> get _filteredSurahs {
    if (_searchQuery.isEmpty) {
      return List.generate(114, (i) => i + 1);
    }
    return List.generate(114, (i) => i + 1).where((surahNumber) {
      final surahName = quran.getSurahName(surahNumber).toLowerCase();
      final surahArabicName = quran.getSurahNameArabic(surahNumber);
      final query = _searchQuery.toLowerCase();
      return surahName.contains(query) || 
             surahArabicName.contains(_searchQuery) ||
             surahNumber.toString().contains(query);
    }).toList();
  }

  // Juz divisions (30 parts)
  static final List<Map<String, dynamic>> juzList = [
    {'number': 1, 'name': 'Juz 1', 'arabicName': 'الجزء ١', 'startSurah': 1, 'startVerse': 1, 'endSurah': 2, 'endVerse': 141},
    {'number': 2, 'name': 'Juz 2', 'arabicName': 'الجزء ٢', 'startSurah': 2, 'startVerse': 142, 'endSurah': 2, 'endVerse': 252},
    {'number': 3, 'name': 'Juz 3', 'arabicName': 'الجزء ٣', 'startSurah': 2, 'startVerse': 253, 'endSurah': 3, 'endVerse': 92},
    {'number': 4, 'name': 'Juz 4', 'arabicName': 'الجزء ٤', 'startSurah': 3, 'startVerse': 93, 'endSurah': 4, 'endVerse': 23},
    {'number': 5, 'name': 'Juz 5', 'arabicName': 'الجزء ٥', 'startSurah': 4, 'startVerse': 24, 'endSurah': 4, 'endVerse': 147},
    {'number': 6, 'name': 'Juz 6', 'arabicName': 'الجزء ٦', 'startSurah': 4, 'startVerse': 148, 'endSurah': 5, 'endVerse': 81},
    {'number': 7, 'name': 'Juz 7', 'arabicName': 'الجزء ٧', 'startSurah': 5, 'startVerse': 82, 'endSurah': 6, 'endVerse': 110},
    {'number': 8, 'name': 'Juz 8', 'arabicName': 'الجزء ٨', 'startSurah': 6, 'startVerse': 111, 'endSurah': 7, 'endVerse': 87},
    {'number': 9, 'name': 'Juz 9', 'arabicName': 'الجزء ٩', 'startSurah': 7, 'startVerse': 88, 'endSurah': 8, 'endVerse': 40},
    {'number': 10, 'name': 'Juz 10', 'arabicName': 'الجزء ١٠', 'startSurah': 8, 'startVerse': 41, 'endSurah': 9, 'endVerse': 92},
    {'number': 11, 'name': 'Juz 11', 'arabicName': 'الجزء ١١', 'startSurah': 9, 'startVerse': 93, 'endSurah': 11, 'endVerse': 5},
    {'number': 12, 'name': 'Juz 12', 'arabicName': 'الجزء ١٢', 'startSurah': 11, 'startVerse': 6, 'endSurah': 12, 'endVerse': 52},
    {'number': 13, 'name': 'Juz 13', 'arabicName': 'الجزء ١٣', 'startSurah': 12, 'startVerse': 53, 'endSurah': 14, 'endVerse': 52},
    {'number': 14, 'name': 'Juz 14', 'arabicName': 'الجزء ١٤', 'startSurah': 15, 'startVerse': 1, 'endSurah': 16, 'endVerse': 128},
    {'number': 15, 'name': 'Juz 15', 'arabicName': 'الجزء ١٥', 'startSurah': 17, 'startVerse': 1, 'endSurah': 18, 'endVerse': 74},
    {'number': 16, 'name': 'Juz 16', 'arabicName': 'الجزء ١٦', 'startSurah': 18, 'startVerse': 75, 'endSurah': 20, 'endVerse': 135},
    {'number': 17, 'name': 'Juz 17', 'arabicName': 'الجزء ١٧', 'startSurah': 21, 'startVerse': 1, 'endSurah': 22, 'endVerse': 78},
    {'number': 18, 'name': 'Juz 18', 'arabicName': 'الجزء ١٨', 'startSurah': 23, 'startVerse': 1, 'endSurah': 25, 'endVerse': 20},
    {'number': 19, 'name': 'Juz 19', 'arabicName': 'الجزء ١٩', 'startSurah': 25, 'startVerse': 21, 'endSurah': 27, 'endVerse': 55},
    {'number': 20, 'name': 'Juz 20', 'arabicName': 'الجزء ٢٠', 'startSurah': 27, 'startVerse': 56, 'endSurah': 29, 'endVerse': 45},
    {'number': 21, 'name': 'Juz 21', 'arabicName': 'الجزء ٢١', 'startSurah': 29, 'startVerse': 46, 'endSurah': 33, 'endVerse': 30},
    {'number': 22, 'name': 'Juz 22', 'arabicName': 'الجزء ٢٢', 'startSurah': 33, 'startVerse': 31, 'endSurah': 36, 'endVerse': 27},
    {'number': 23, 'name': 'Juz 23', 'arabicName': 'الجزء ٢٣', 'startSurah': 36, 'startVerse': 28, 'endSurah': 39, 'endVerse': 31},
    {'number': 24, 'name': 'Juz 24', 'arabicName': 'الجزء ٢٤', 'startSurah': 39, 'startVerse': 32, 'endSurah': 41, 'endVerse': 46},
    {'number': 25, 'name': 'Juz 25', 'arabicName': 'الجزء ٢٥', 'startSurah': 41, 'startVerse': 47, 'endSurah': 45, 'endVerse': 37},
    {'number': 26, 'name': 'Juz 26', 'arabicName': 'الجزء ٢٦', 'startSurah': 46, 'startVerse': 1, 'endSurah': 51, 'endVerse': 30},
    {'number': 27, 'name': 'Juz 27', 'arabicName': 'الجزء ٢٧', 'startSurah': 51, 'startVerse': 31, 'endSurah': 57, 'endVerse': 29},
    {'number': 28, 'name': 'Juz 28', 'arabicName': 'الجزء ٢٨', 'startSurah': 58, 'startVerse': 1, 'endSurah': 66, 'endVerse': 12},
    {'number': 29, 'name': 'Juz 29', 'arabicName': 'الجزء ٢٩', 'startSurah': 67, 'startVerse': 1, 'endSurah': 77, 'endVerse': 50},
    {'number': 30, 'name': 'Juz 30', 'arabicName': 'الجزء ٣٠', 'startSurah': 78, 'startVerse': 1, 'endSurah': 114, 'endVerse': 6},
  ];

  // Manzil divisions (7 parts for weekly recitation)
  static final List<Map<String, dynamic>> manzils = [
    {
      'number': 1,
      'name': 'First Manzil',
      'arabicName': 'المنزل الأول',
      'day': 'Monday',
      'surahs': [1, 2, 3, 4], // Al-Fatiha to An-Nisa
      'description': 'Surahs 1-4',
    },
    {
      'number': 2,
      'name': 'Second Manzil',
      'arabicName': 'المنزل الثاني',
      'day': 'Tuesday',
      'surahs': [5, 6, 7, 8, 9], // Al-Ma'idah to At-Tawbah
      'description': 'Surahs 5-9',
    },
    {
      'number': 3,
      'name': 'Third Manzil',
      'arabicName': 'المنزل الثالث',
      'day': 'Wednesday',
      'surahs': [10, 11, 12, 13, 14, 15, 16], // Yunus to An-Nahl
      'description': 'Surahs 10-16',
    },
    {
      'number': 4,
      'name': 'Fourth Manzil',
      'arabicName': 'المنزل الرابع',
      'day': 'Thursday',
      'surahs': [17, 18, 19, 20, 21, 22, 23, 24, 25], // Al-Isra to Al-Furqan
      'description': 'Surahs 17-25',
    },
    {
      'number': 5,
      'name': 'Fifth Manzil',
      'arabicName': 'المنزل الخامس',
      'day': 'Friday',
      'surahs': [26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36], // Ash-Shu'ara to Ya-Sin
      'description': 'Surahs 26-36',
    },
    {
      'number': 6,
      'name': 'Sixth Manzil',
      'arabicName': 'المنزل السادس',
      'day': 'Saturday',
      'surahs': [37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49], // As-Saffat to Al-Hujurat
      'description': 'Surahs 37-49',
    },
    {
      'number': 7,
      'name': 'Seventh Manzil',
      'arabicName': 'المنزل السابع',
      'day': 'Sunday',
      'surahs': List.generate(65, (i) => 50 + i), // Qaf to An-Nas (50-114)
      'description': 'Surahs 50-114',
    },
  ];

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
              _buildHeader(context, appProvider),
              _buildTabBar(context, appProvider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuranList(context, appProvider, isDark),
                    _buildJuzList(context, appProvider, isDark),
                    _buildManzilList(context, appProvider, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider appProvider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (widget.showBackButton) ...[            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_rounded,
                color: appProvider.isDarkMode ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 8),
          ],
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
              border: Border.all(
                color: appProvider.accentColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.menu_book_rounded,
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
                  'Holy Quran',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Read by Surah, Juz or Manzil',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: appProvider.isDarkMode 
                        ? AppTheme.textLight.withOpacity(0.7)
                        : AppTheme.textDark.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, AppProvider appProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: appProvider.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: appProvider.accentColor,
            borderRadius: BorderRadius.circular(12),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: appProvider.isDarkMode
              ? AppTheme.textLight.withOpacity(0.6)
              : AppTheme.textDark.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'Quran'),
            Tab(text: 'Juz (30)'),
            Tab(text: 'Manzil (7)'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuranList(BuildContext context, AppProvider appProvider, bool isDark) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: GlassCard(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: TextStyle(
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Search Surah...',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppTheme.textLight.withOpacity(0.5)
                      : AppTheme.textDark.withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: appProvider.accentColor,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        // Surah List
        Expanded(
          child: _filteredSurahs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: appProvider.accentColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No surahs found',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? AppTheme.textLight.withOpacity(0.6)
                              : AppTheme.textDark.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: _filteredSurahs.length,
                  itemBuilder: (context, index) {
                    final surahNumber = _filteredSurahs[index];
                    return _buildSurahCard(context, surahNumber, appProvider, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSurahCard(BuildContext context, int surahNumber, AppProvider appProvider, bool isDark) {
    final surahName = quran.getSurahName(surahNumber);
    final surahArabicName = quran.getSurahNameArabic(surahNumber);
    final verseCount = quran.getVerseCount(surahNumber);
    final revelationType = quran.getPlaceOfRevelation(surahNumber);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailScreen(
                  surahNumber: surahNumber,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Surah Number Badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        appProvider.accentColor,
                        appProvider.accentColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '$surahNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surahName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: revelationType,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: ' • $verseCount Verses',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                const SizedBox(width: 12),
                Text(
                  surahArabicName,
                  style: AppTheme.arabicTextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: appProvider.accentColor,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(width: 12),
                // Play Button
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: appProvider.accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.play_arrow_rounded,
                      color: appProvider.accentColor,
                      size: 24,
                    ),
                    onPressed: () {
                      // Open full surah player
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullSurahPlayerScreen(
                            surahNumber: surahNumber,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJuzList(BuildContext context, AppProvider appProvider, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: juzList.length,
      itemBuilder: (context, index) {
        return _buildJuzCard(context, juzList[index], appProvider, isDark);
      },
    );
  }

  Widget _buildManzilList(BuildContext context, AppProvider appProvider, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: manzils.length,
      itemBuilder: (context, index) {
        return _buildManzilCard(context, manzils[index], appProvider, isDark);
      },
    );
  }

  Widget _buildJuzCard(BuildContext context, Map<String, dynamic> juz, AppProvider appProvider, bool isDark) {
    final startSurah = quran.getSurahName(juz['startSurah']);
    final endSurah = quran.getSurahName(juz['endSurah']);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: InkWell(
          onTap: () => _showJuzDetail(context, juz, appProvider),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Juz Number Badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        appProvider.accentColor,
                        appProvider.accentColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${juz['number']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            juz['name'],
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            juz['arabicName'],
                            style: AppTheme.arabicTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: appProvider.accentColor,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$startSurah (${juz['startSurah']}:${juz['startVerse']}) → $endSurah (${juz['endSurah']}:${juz['endVerse']})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark 
                              ? AppTheme.textLight.withOpacity(0.6)
                              : AppTheme.textDark.withOpacity(0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
      ),
    );
  }

  Widget _buildManzilCard(BuildContext context, Map<String, dynamic> manzil, AppProvider appProvider, bool isDark) {
    final surahs = manzil['surahs'] as List<int>;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: InkWell(
          onTap: () => _showManzilDetail(context, manzil, appProvider),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Manzil Number Badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            appProvider.accentColor,
                            appProvider.accentColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${manzil['number']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            manzil['name'],
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            manzil['arabicName'],
                            style: AppTheme.arabicTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: appProvider.accentColor,
                            ),
                            textDirection: TextDirection.rtl,
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
                const SizedBox(height: 16),
                Divider(
                  color: isDark 
                      ? Colors.white.withOpacity(0.1) 
                      : Colors.black.withOpacity(0.1),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.today_rounded,
                      size: 18,
                      color: appProvider.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      manzil['day'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: appProvider.accentColor,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: isDark 
                          ? AppTheme.textLight.withOpacity(0.6)
                          : AppTheme.textDark.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${surahs.length} Surahs',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark 
                            ? AppTheme.textLight.withOpacity(0.6)
                            : AppTheme.textDark.withOpacity(0.6),
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

  void _showManzilDetail(BuildContext context, Map<String, dynamic> manzil, AppProvider appProvider) {
    final surahs = manzil['surahs'] as List<int>;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: appProvider.isDarkMode
                ? [
                    AppTheme.primaryDark,
                    AppTheme.secondaryDeep,
                  ]
                : [
                    const Color(0xFFFAFAFA),
                    const Color(0xFFF0F0F3),
                  ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appProvider.accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    manzil['name'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    manzil['arabicName'],
                    style: AppTheme.arabicTextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: appProvider.accentColor,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: appProvider.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: appProvider.accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.today_rounded,
                          size: 16,
                          color: appProvider.accentColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recommended for ${manzil['day']}',
                          style: TextStyle(
                            color: appProvider.accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Surahs list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surahNumber = surahs[index];
                  final surahName = quran.getSurahName(surahNumber);
                  final surahNameArabic = quran.getSurahNameArabic(surahNumber);
                  final verseCount = quran.getVerseCount(surahNumber);
                  final revelationType = quran.getPlaceOfRevelation(surahNumber);
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailScreen(
                            surahNumber: surahNumber,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            appProvider.accentColor.withOpacity(0.05),
                            appProvider.accentColor.withOpacity(0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: appProvider.accentColor.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Surah number
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: appProvider.accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '$surahNumber',
                                style: TextStyle(
                                  color: appProvider.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                                  surahName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$revelationType • $verseCount verses',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: appProvider.isDarkMode
                                        ? AppTheme.textLight.withOpacity(0.6)
                                        : AppTheme.textDark.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            surahNameArabic,
                            style: AppTheme.arabicTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: appProvider.accentColor,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJuzDetail(BuildContext context, Map<String, dynamic> juz, AppProvider appProvider) {
    // Get all surahs in this juz
    final startSurah = juz['startSurah'] as int;
    final endSurah = juz['endSurah'] as int;
    final surahs = List.generate(endSurah - startSurah + 1, (i) => startSurah + i);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: appProvider.isDarkMode
                ? [
                    AppTheme.primaryDark,
                    AppTheme.secondaryDeep,
                  ]
                : [
                    const Color(0xFFFAFAFA),
                    const Color(0xFFF0F0F3),
                  ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appProvider.accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        juz['name'],
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        juz['arabicName'],
                        style: AppTheme.arabicTextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: appProvider.accentColor,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: appProvider.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: appProvider.accentColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${quran.getSurahName(startSurah)} ($startSurah:${juz['startVerse']}) → ${quran.getSurahName(endSurah)} ($endSurah:${juz['endVerse']})',
                      style: TextStyle(
                        color: appProvider.accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Surahs list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surahNumber = surahs[index];
                  final surahName = quran.getSurahName(surahNumber);
                  final surahNameArabic = quran.getSurahNameArabic(surahNumber);
                  final verseCount = quran.getVerseCount(surahNumber);
                  final revelationType = quran.getPlaceOfRevelation(surahNumber);
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      
                      // Determine if this is the first surah in the Juz to start from correct verse
                      int? initialVerse;
                      if (surahNumber == startSurah) {
                        // First surah in Juz - start from the Juz's starting verse
                        initialVerse = juz['startVerse'];
                      }
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailScreen(
                            surahNumber: surahNumber,
                            initialVerse: initialVerse,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            appProvider.accentColor.withOpacity(0.05),
                            appProvider.accentColor.withOpacity(0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: appProvider.accentColor.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Surah number
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: appProvider.accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '$surahNumber',
                                style: TextStyle(
                                  color: appProvider.accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                                  surahName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$revelationType • $verseCount verses',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: appProvider.isDarkMode
                                        ? AppTheme.textLight.withOpacity(0.6)
                                        : AppTheme.textDark.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            surahNameArabic,
                            style: AppTheme.arabicTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: appProvider.accentColor,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
