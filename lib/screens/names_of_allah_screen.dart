import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class NamesOfAllahScreen extends StatefulWidget {
  final bool showBackButton;
  const NamesOfAllahScreen({super.key, this.showBackButton = false});

  @override
  State<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen> {
  final List<Map<String, String>> names = [
    {'name': 'الرَّحْمَنُ', 'transliteration': 'Ar-Rahman', 'meaning': 'The Most Compassionate'},
    {'name': 'الرَّحِيمُ', 'transliteration': 'Ar-Rahim', 'meaning': 'The Most Merciful'},
    {'name': 'الْمَلِكُ', 'transliteration': 'Al-Malik', 'meaning': 'The King'},
    {'name': 'الْقُدُّوسُ', 'transliteration': 'Al-Quddus', 'meaning': 'The Most Holy'},
    {'name': 'السَّلاَمُ', 'transliteration': 'As-Salam', 'meaning': 'The Source of Peace'},
    {'name': 'الْمُؤْمِنُ', 'transliteration': 'Al-Mumin', 'meaning': 'The Guardian of Faith'},
    {'name': 'الْمُهَيْمِنُ', 'transliteration': 'Al-Muhaymin', 'meaning': 'The Protector'},
    {'name': 'الْعَزِيزُ', 'transliteration': 'Al-Aziz', 'meaning': 'The Mighty'},
    {'name': 'الْجَبَّارُ', 'transliteration': 'Al-Jabbar', 'meaning': 'The Compeller'},
    {'name': 'الْمُتَكَبِّرُ', 'transliteration': 'Al-Mutakabbir', 'meaning': 'The Supreme'},
    {'name': 'الْخَالِقُ', 'transliteration': 'Al-Khaliq', 'meaning': 'The Creator'},
    {'name': 'الْبَارِئُ', 'transliteration': 'Al-Bari', 'meaning': 'The Originator'},
    {'name': 'الْمُصَوِّرُ', 'transliteration': 'Al-Musawwir', 'meaning': 'The Fashioner'},
    {'name': 'الْغَفَّارُ', 'transliteration': 'Al-Ghaffar', 'meaning': 'The Constantly Forgiving'},
    {'name': 'الْقَهَّارُ', 'transliteration': 'Al-Qahhar', 'meaning': 'The All-Prevailing One'},
    {'name': 'الْوَهَّابُ', 'transliteration': 'Al-Wahhab', 'meaning': 'The Supreme Bestower'},
    {'name': 'الرَّزَّاقُ', 'transliteration': 'Ar-Razzaq', 'meaning': 'The Provider'},
    {'name': 'الْفَتَّاحُ', 'transliteration': 'Al-Fattah', 'meaning': 'The Opener'},
    {'name': 'اَلْعَلِيْمُ', 'transliteration': 'Al-Alim', 'meaning': 'The All-Knowing'},
    {'name': 'الْقَابِضُ', 'transliteration': 'Al-Qabid', 'meaning': 'The Withholder'},
    {'name': 'الْبَاسِطُ', 'transliteration': 'Al-Basit', 'meaning': 'The Extender'},
    {'name': 'الْخَافِضُ', 'transliteration': 'Al-Khafid', 'meaning': 'The Reducer'},
    {'name': 'الرَّافِعُ', 'transliteration': 'Ar-Rafi', 'meaning': 'The Exalter'},
    {'name': 'الْمُعِزُّ', 'transliteration': 'Al-Muizz', 'meaning': 'The Giver of Honor'},
    {'name': 'المُذِلُّ', 'transliteration': 'Al-Mudhill', 'meaning': 'The Giver of Dishonor'},
    {'name': 'السَّمِيعُ', 'transliteration': 'As-Sami', 'meaning': 'The All-Hearing'},
    {'name': 'الْبَصِيرُ', 'transliteration': 'Al-Basir', 'meaning': 'The All-Seeing'},
    {'name': 'الْحَكَمُ', 'transliteration': 'Al-Hakam', 'meaning': 'The Judge'},
    {'name': 'الْعَدْلُ', 'transliteration': 'Al-Adl', 'meaning': 'The Just'},
    {'name': 'اللَّطِيفُ', 'transliteration': 'Al-Latif', 'meaning': 'The Subtle One'},
    {'name': 'الْخَبِيرُ', 'transliteration': 'Al-Khabir', 'meaning': 'The All-Aware'},
    {'name': 'الْحَلِيمُ', 'transliteration': 'Al-Halim', 'meaning': 'The Forbearing'},
    {'name': 'الْعَظِيمُ', 'transliteration': 'Al-Azim', 'meaning': 'The Magnificent'},
    {'name': 'الْغَفُورُ', 'transliteration': 'Al-Ghafur', 'meaning': 'The Great Forgiver'},
    {'name': 'الشَّكُورُ', 'transliteration': 'Ash-Shakur', 'meaning': 'The Most Appreciative'},
    {'name': 'الْعَلِيُّ', 'transliteration': 'Al-Aliyy', 'meaning': 'The Most High'},
    {'name': 'الْكَبِيرُ', 'transliteration': 'Al-Kabir', 'meaning': 'The Most Great'},
    {'name': 'الْحَفِيظُ', 'transliteration': 'Al-Hafiz', 'meaning': 'The Preserver'},
    {'name': 'المُقيِت', 'transliteration': 'Al-Muqit', 'meaning': 'The Sustainer'},
    {'name': 'الْحسِيبُ', 'transliteration': 'Al-Hasib', 'meaning': 'The Reckoner'},
    {'name': 'الْجَلِيلُ', 'transliteration': 'Al-Jalil', 'meaning': 'The Majestic'},
    {'name': 'الْكَرِيمُ', 'transliteration': 'Al-Karim', 'meaning': 'The Most Generous'},
    {'name': 'الرَّقِيبُ', 'transliteration': 'Ar-Raqib', 'meaning': 'The Watchful'},
    {'name': 'الْمُجِيبُ', 'transliteration': 'Al-Mujib', 'meaning': 'The Responsive'},
    {'name': 'الْوَاسِعُ', 'transliteration': 'Al-Wasi', 'meaning': 'The All-Encompassing'},
    {'name': 'الْحَكِيمُ', 'transliteration': 'Al-Hakim', 'meaning': 'The All-Wise'},
    {'name': 'الْوَدُودُ', 'transliteration': 'Al-Wadud', 'meaning': 'The Most Loving'},
    {'name': 'الْمَجِيدُ', 'transliteration': 'Al-Majid', 'meaning': 'The Glorious'},
    {'name': 'الْبَاعِثُ', 'transliteration': 'Al-Baith', 'meaning': 'The Resurrector'},
    {'name': 'الشَّهِيدُ', 'transliteration': 'Ash-Shahid', 'meaning': 'The Witness'},
    {'name': 'الْحَقُّ', 'transliteration': 'Al-Haqq', 'meaning': 'The Truth'},
    {'name': 'الْوَكِيلُ', 'transliteration': 'Al-Wakil', 'meaning': 'The Trustee'},
    {'name': 'الْقَوِيُّ', 'transliteration': 'Al-Qawiyy', 'meaning': 'The Most Strong'},
    {'name': 'الْمَتِينُ', 'transliteration': 'Al-Matin', 'meaning': 'The Firm One'},
    {'name': 'الْوَلِيُّ', 'transliteration': 'Al-Waliyy', 'meaning': 'The Protecting Friend'},
    {'name': 'الْحَمِيدُ', 'transliteration': 'Al-Hamid', 'meaning': 'The Praiseworthy'},
    {'name': 'الْمُحْصِي', 'transliteration': 'Al-Muhsi', 'meaning': 'The Accounter'},
    {'name': 'الْمُبْدِئُ', 'transliteration': 'Al-Mubdi', 'meaning': 'The Originator'},
    {'name': 'الْمُعِيدُ', 'transliteration': 'Al-Muid', 'meaning': 'The Restorer'},
    {'name': 'الْمُحْيِي', 'transliteration': 'Al-Muhyi', 'meaning': 'The Giver of Life'},
    {'name': 'اَلْمُمِيتُ', 'transliteration': 'Al-Mumit', 'meaning': 'The Bringer of Death'},
    {'name': 'الْحَيُّ', 'transliteration': 'Al-Hayy', 'meaning': 'The Ever-Living'},
    {'name': 'الْقَيُّومُ', 'transliteration': 'Al-Qayyum', 'meaning': 'The Self-Subsisting'},
    {'name': 'الْوَاجِدُ', 'transliteration': 'Al-Wajid', 'meaning': 'The Perceiver'},
    {'name': 'الْمَاجِدُ', 'transliteration': 'Al-Majid', 'meaning': 'The Illustrious'},
    {'name': 'الْواحِدُ', 'transliteration': 'Al-Wahid', 'meaning': 'The One'},
    {'name': 'اَلاَحَدُ', 'transliteration': 'Al-Ahad', 'meaning': 'The Unique'},
    {'name': 'الصَّمَدُ', 'transliteration': 'As-Samad', 'meaning': 'The Eternal Refuge'},
    {'name': 'الْقَادِرُ', 'transliteration': 'Al-Qadir', 'meaning': 'The Capable'},
    {'name': 'الْمُقْتَدِرُ', 'transliteration': 'Al-Muqtadir', 'meaning': 'The Omnipotent'},
    {'name': 'الْمُقَدِّمُ', 'transliteration': 'Al-Muqaddim', 'meaning': 'The Expediter'},
    {'name': 'الْمُؤَخِّرُ', 'transliteration': 'Al-Muakhkhir', 'meaning': 'The Delayer'},
    {'name': 'الأوَّلُ', 'transliteration': 'Al-Awwal', 'meaning': 'The First'},
    {'name': 'الآخِرُ', 'transliteration': 'Al-Akhir', 'meaning': 'The Last'},
    {'name': 'الظَّاهِرُ', 'transliteration': 'Az-Zahir', 'meaning': 'The Manifest'},
    {'name': 'الْبَاطِنُ', 'transliteration': 'Al-Batin', 'meaning': 'The Hidden'},
    {'name': 'الْوَالِي', 'transliteration': 'Al-Wali', 'meaning': 'The Governor'},
    {'name': 'الْمُتَعَالِي', 'transliteration': 'Al-Mutaali', 'meaning': 'The Most Exalted'},
    {'name': 'الْبَرُّ', 'transliteration': 'Al-Barr', 'meaning': 'The Source of Goodness'},
    {'name': 'التَّوَابُ', 'transliteration': 'At-Tawwab', 'meaning': 'The Ever-Pardoning'},
    {'name': 'الْمُنْتَقِمُ', 'transliteration': 'Al-Muntaqim', 'meaning': 'The Avenger'},
    {'name': 'العَفُوُّ', 'transliteration': 'Al-Afuww', 'meaning': 'The Pardoner'},
    {'name': 'الرَّؤُوفُ', 'transliteration': 'Ar-Rauf', 'meaning': 'The Most Kind'},
    {'name': 'مَالِكُ الْمُلْكِ', 'transliteration': 'Malik-ul-Mulk', 'meaning': 'Master of the Kingdom'},
    {'name': 'ذُوالْجَلاَلِ وَالإكْرَامِ', 'transliteration': 'Dhul-Jalali wal-Ikram', 'meaning': 'Lord of Majesty and Generosity'},
    {'name': 'الْمُقْسِطُ', 'transliteration': 'Al-Muqsit', 'meaning': 'The Equitable'},
    {'name': 'الْجَامِعُ', 'transliteration': 'Al-Jami', 'meaning': 'The Gatherer'},
    {'name': 'ٱلْغَنيُّ', 'transliteration': 'Al-Ghani', 'meaning': 'The Self-Sufficient'},
    {'name': 'ٱلْمُغْنِيُ', 'transliteration': 'Al-Mughni', 'meaning': 'The Enricher'},
    {'name': 'اَلْمَانِعُ', 'transliteration': 'Al-Mani', 'meaning': 'The Preventer'},
    {'name': 'الضَّارَ', 'transliteration': 'Ad-Darr', 'meaning': 'The Distresser'},
    {'name': 'النَّافِعُ', 'transliteration': 'An-Nafi', 'meaning': 'The Benefactor'},
    {'name': 'النُّورُ', 'transliteration': 'An-Nur', 'meaning': 'The Light'},
    {'name': 'الْهَادِي', 'transliteration': 'Al-Hadi', 'meaning': 'The Guide'},
    {'name': 'الْبَدِيعُ', 'transliteration': 'Al-Badi', 'meaning': 'The Incomparable'},
    {'name': 'اَلْبَاقِي', 'transliteration': 'Al-Baqi', 'meaning': 'The Everlasting'},
    {'name': 'الْوَارِثُ', 'transliteration': 'Al-Warith', 'meaning': 'The Inheritor'},
    {'name': 'الرَّشِيدُ', 'transliteration': 'Ar-Rashid', 'meaning': 'The Guide to the Right Path'},
    {'name': 'الصَّبُورُ', 'transliteration': 'As-Sabur', 'meaning': 'The Most Patient'},
  ];

  String _searchQuery = '';

  List<Map<String, String>> get filteredNames {
    if (_searchQuery.isEmpty) return names;
    return names.where((name) {
      return name['name']!.contains(_searchQuery) ||
          name['transliteration']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          name['meaning']!.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
              _buildHeader(appProvider, isDark),
              _buildSearchBar(appProvider, isDark),
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    '${filteredNames.length} names found',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.textLight.withOpacity(0.6)
                          : AppTheme.textDark.withOpacity(0.6),
                    ),
                  ),
                ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredNames.length,
                  itemBuilder: (context, index) {
                    final name = filteredNames[index];
                    final actualIndex = names.indexOf(name);
                    return _buildNameCard(
                      context,
                      actualIndex + 1,
                      name['name']!,
                      name['transliteration']!,
                      name['meaning']!,
                      appProvider,
                      isDark,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppProvider appProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
          // Counter Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appProvider.accentColor.withOpacity(0.2),
                  appProvider.accentColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: appProvider.accentColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${names.length}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: appProvider.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppProvider appProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: TextStyle(
            color: isDark ? AppTheme.textLight : AppTheme.textDark,
          ),
          decoration: InputDecoration(
            hintText: 'Search by name or meaning...',
            hintStyle: TextStyle(
              color: isDark
                  ? AppTheme.textLight.withOpacity(0.5)
                  : AppTheme.textDark.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: appProvider.accentColor,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  Widget _buildNameCard(
    BuildContext context,
    int number,
    String arabicName,
    String transliteration,
    String meaning,
    AppProvider appProvider,
    bool isDark,
  ) {
    return GlassCard(
      onTap: () => _showNameDetail(context, number, arabicName, transliteration, meaning, appProvider, isDark),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Number Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appProvider.accentColor.withOpacity(0.2),
                    appProvider.accentColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: appProvider.accentColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appProvider.accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Arabic Name
            Text(
              arabicName,
              style: AppTheme.arabicTextStyle(
                fontSize: 28,
                color: appProvider.accentColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Transliteration
            Text(
              transliteration,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Meaning
            Text(
              meaning,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppTheme.textLight.withOpacity(0.6)
                    : AppTheme.textDark.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showNameDetail(
    BuildContext context,
    int number,
    String arabicName,
    String transliteration,
    String meaning,
    AppProvider appProvider,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [const Color(0xFFf0f4f8), const Color(0xFFe8eef5)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          top: 32,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appProvider.accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Number badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appProvider.accentColor.withOpacity(0.3),
                    appProvider.accentColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: appProvider.accentColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: appProvider.accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Arabic Name (large)
            Text(
              arabicName,
              style: AppTheme.arabicTextStyle(
                fontSize: 48,
                color: appProvider.accentColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Transliteration
            Text(
              transliteration,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Divider
            Container(
              width: 60,
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    appProvider.accentColor.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Meaning
            Text(
              meaning,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppTheme.textLight.withOpacity(0.8)
                    : AppTheme.textDark.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: appProvider.accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
