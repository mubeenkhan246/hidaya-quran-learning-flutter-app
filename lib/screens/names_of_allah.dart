import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:esmaulhusna_muslimbg/esmaulhusna.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
// Note: You must add 'esmaulhusna_muslimbg: ^1.0.3' and 'shared_preferences: ^2.0.0' (or higher) 
// to your pubspec.yaml file

// Define the structure for an Esmaul Husna name
class AllahName {
  final String arabic;
  final String name;
  final String translation;

  AllahName({required this.arabic, required this.name, required this.translation});

  // Helper method for search filtering
  bool contains(String query) {
    final lowerCaseQuery = query.toLowerCase();
    return arabic.toLowerCase().contains(lowerCaseQuery) ||
           name.toLowerCase().contains(lowerCaseQuery) ||
           translation.toLowerCase().contains(lowerCaseQuery);
  }
}

// This widget is used as the target for navigation from QuickActionsWidget.
// It now simply returns the in-app styled screen instead of a standalone MaterialApp.
class EsmaulHusnaApp extends StatelessWidget {
  const EsmaulHusnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentLanguage = 'en'; // Default language is English

  // Map of supported languages for the UI
  final Map<String, String> _languages = {
    'en': 'English',
    'tr': 'Turkish',
    'bg': 'Bulgarian',
    // Added 'ar' (Arabic) as a common language, even if the package supports only translation
    'ar': 'Arabic (Names Only)',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLanguagePreference(); // Load preference on initialization
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Persistence Logic Integration ---
  
  // Load language from shared preferences
  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        // Use 'en' as default if nothing is saved
        _currentLanguage = prefs.getString('language') ?? 'en'; 
      });
    } catch (e) {
      debugPrint('Error loading language preference: $e');
    }
  }

  // Save language to shared preferences
  Future<void> _saveLanguagePreference(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
  }

  // Method to show a language selection dialog
  void _showLanguageSelection() {
    final appProvider = context.read<AppProvider>();
    final isDark = appProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          content: GlassCard(
            borderRadius: 22,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: appProvider.accentColor,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select Language',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _languages.entries.map((entry) {
                          final isSelected = _currentLanguage == entry.key;
                          return RadioListTile<String>(
                            title: Text(
                              entry.value,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            value: entry.key,
                            groupValue: _currentLanguage,
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _currentLanguage = value;
                                });
                                _saveLanguagePreference(value); // Save preference
                                Navigator.of(context).pop();
                              }
                            },
                            activeColor: appProvider.accentColor,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
              // Header with title and language chip
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أسماء الله الحسنى',
                            style: AppTheme.arabicTextStyle(
                              fontSize: 24,
                              color: appProvider.accentColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '99 Names of Allah',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppTheme.textLight.withOpacity(0.6)
                                  : AppTheme.textDark.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ActionChip(
                    //   avatar: Icon(
                    //     Icons.language,
                    //     color: appProvider.accentColor,
                    //     size: 18,
                    //   ),
                    //   label: Text(
                    //     _languages[_currentLanguage] ?? 'Lang',
                    //     style: const TextStyle(fontWeight: FontWeight.bold),
                    //   ),
                    //   onPressed: _showLanguageSelection,
                    //   backgroundColor: isDark
                    //       ? Colors.black.withOpacity(0.2)
                    //       : Colors.white.withOpacity(0.9),
                    //   elevation: 0,
                    // ),
                  ],
                ),
              ),

              // Tab bar styled like other screens
              Padding(
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
                    unselectedLabelColor: isDark
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
                      Tab(text: 'All Names'),
                      Tab(text: 'Random Name'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    NamesListTab(
                      key: ValueKey(_currentLanguage),
                      languageCode: _currentLanguage,
                    ),
                    RandomNameTab(
                      key: ValueKey(_currentLanguage),
                      languageCode: _currentLanguage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NAMES LIST TAB (Now Stateful for Search)
// -----------------------------------------------------------------------------
class NamesListTab extends StatefulWidget {
  final String languageCode;
  const NamesListTab({required this.languageCode, super.key});

  @override
  State<NamesListTab> createState() => _NamesListTabState();
}

class _NamesListTabState extends State<NamesListTab> {
  Future<List<AllahName>>? _namesFuture;
  List<AllahName> _allNames = [];
  List<AllahName> _filteredNames = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNames(widget.languageCode);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(NamesListTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload names only if the language code has changed
    if (oldWidget.languageCode != widget.languageCode) {
      _loadNames(widget.languageCode);
    }
    // Re-filter the list when language changes (in case the search bar is active)
    _filterList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Function to load and parse the names
  void _loadNames(String langCode) {
    setState(() {
      _namesFuture = _fetchNames(langCode);
    });
  }

  Future<List<AllahName>> _fetchNames(String langCode) async {
    try {
      final List<Map<String, String>> namesData = await EsmaulHusna.getNames(langCode);
      final namesList = namesData.map((data) {
        // Handle cases where 'translation' might be missing or empty (e.g., if meaning is detailed)
        final translation = data['translation'] ?? data['meaning'] ?? 'No description available.';
        return AllahName(
          arabic: data['arabic'] ?? 'N/A', // Provide fallback
          name: data['name'] ?? 'N/A',
          translation: translation,
        );
      }).toList();

      // Update the state with all names and trigger initial filtering
      _allNames = namesList;
      _filterList(); // Initial filter to show all names

      return namesList;
    } catch (e) {
      // Catch specific errors like invalid language code, or network/data issues
      debugPrint('Error fetching names for $langCode: $e');
      // Throw a user-friendly error message
      return Future.error('Failed to load names for $langCode. Please check the language code or your internet connection. Error: $e');
    }
  }

  void _onSearchChanged() {
    _filterList();
  }

  void _filterList() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _filteredNames = _allNames;
      });
    } else {
      setState(() {
        _filteredNames = _allNames.where((name) => name.contains(query)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar (GlassCard, app-themed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: GlassCard(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Names (Arabic, Name, or Meaning)',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppTheme.textLight.withOpacity(0.6)
                          : AppTheme.textDark.withOpacity(0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: appProvider.accentColor,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus(); // Dismiss keyboard
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ),
            ),
            FutureBuilder<List<AllahName>>(
              future: _namesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF008080)));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  );
                }
                // The data is loaded, now display the filtered list
                if (!snapshot.hasData || _filteredNames.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'No names found for this language.'
                          : 'No results found for "${_searchController.text}".',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  );
                }
            
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 8.0),
                  itemCount: _filteredNames.length,
                  itemBuilder: (context, index) {
                    final name = _filteredNames[index];
                    // Pass the original index (position in the full list)
                    final originalIndex = _allNames.indexOf(name);
                    return NameCard(name: name, index: originalIndex);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for a modern, attractive card display
class NameCard extends StatelessWidget {
  final AllahName name;
  final int index;
  const NameCard({required this.name, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final accentColor = appProvider.accentColor;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textDark;

    return GlassCard(
      borderRadius: 20,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Index Circle (accent-colored)
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // Arabic Name (Larger and Right-aligned)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    name.arabic,
                    style: AppTheme.arabicTextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            height: 20,
            thickness: 0.8,
            color: isDark
                ? AppTheme.textLight.withOpacity(0.1)
                : AppTheme.textDark.withOpacity(0.08),
          ),
          const SizedBox(height: 4),

          // Name (Transliteration/Name)
          Text(
            name.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),

          // Meaning/Description
          Text(
            name.translation,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: textColor.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// RANDOM NAME TAB
// -----------------------------------------------------------------------------
class RandomNameTab extends StatefulWidget {
  final String languageCode;
  const RandomNameTab({required this.languageCode, super.key});

  @override
  State<RandomNameTab> createState() => _RandomNameTabState();
}

class _RandomNameTabState extends State<RandomNameTab> {
  AllahName? _randomName;
  bool _isLoading = false;

  // Map of languages for display purposes inside this component (copy from MainScreen)
  final Map<String, String> _languages = const {
    'en': 'English',
    'tr': 'Turkish',
    'bg': 'Bulgarian',
    'ar': 'Arabic (Names Only)',
  };

  @override
  void didUpdateWidget(RandomNameTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear the current random name if the language changes
    if (oldWidget.languageCode != widget.languageCode) {
      setState(() {
        _randomName = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRandomName() async {
    setState(() {
      _isLoading = true;
      _randomName = null;
    });

    try {
      final Map<String, String> data = await EsmaulHusna.getRandomName(widget.languageCode);
      final translation = data['translation'] ?? data['meaning'] ?? 'No description available.';

      setState(() {
        _randomName = AllahName(
          arabic: data['arabic'] ?? 'N/A',
          name: data['name'] ?? 'N/A',
          translation: translation,
        );
      });
    } catch (e) {
      debugPrint('Error fetching random name: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load random name: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final accentColor = appProvider.accentColor;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textDark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Random Name Display Card
            if (_randomName != null)
              GlassCard(
                borderRadius: 25,
                margin: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    // Arabic Name
                    Text(
                      _randomName!.arabic,
                      style: AppTheme.arabicTextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Name (Latin)
                    Text(
                      _randomName!.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(
                      height: 30,
                      thickness: 1.2,
                      color: isDark
                          ? AppTheme.textLight.withOpacity(0.12)
                          : AppTheme.textDark.withOpacity(0.1),
                    ),
                    const SizedBox(height: 8),
                    // Meaning
                    Text(
                      _randomName!.translation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor.withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
            else if (!_isLoading)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 60,
                      color: accentColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap the button to discover a Name of Allah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: textColor.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),

            // Generate Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchRandomName,
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                _isLoading ? 'Loading...' : 'Reveal Random Name',
                style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 10,
                shadowColor: accentColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            // Display Current Language
            Text(
              'Currently displaying translations in: ${_languages[widget.languageCode] ?? 'Unknown'}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}