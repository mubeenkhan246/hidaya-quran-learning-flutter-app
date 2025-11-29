import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../providers/app_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/glass_card.dart';

class NooraniQaidaScreen extends StatefulWidget {
  const NooraniQaidaScreen({super.key});

  @override
  State<NooraniQaidaScreen> createState() => _NooraniQaidaScreenState();
}

class _NooraniQaidaScreenState extends State<NooraniQaidaScreen> {
  int _selectedLetterIndex = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  // Arabic Letters (Huruf al-Hijaiyah)
  final List<Map<String, String>> arabicLetters = [
    {'letter': 'ا', 'name': 'Alif', 'pronunciation': 'aa', 'example': 'أسد (Asad - Lion)'},
    {'letter': 'ب', 'name': 'Ba', 'pronunciation': 'ba', 'example': 'بقرة (Baqara - Cow)'},
    {'letter': 'ت', 'name': 'Ta', 'pronunciation': 'ta', 'example': 'تفاح (Tuffah - Apple)'},
    {'letter': 'ث', 'name': 'Tha', 'pronunciation': 'tha', 'example': 'ثعلب (Thalab - Fox)'},
    {'letter': 'ج', 'name': 'Jeem', 'pronunciation': 'ja', 'example': 'جمل (Jamal - Camel)'},
    {'letter': 'ح', 'name': 'Ha', 'pronunciation': 'ha', 'example': 'حصان (Hisan - Horse)'},
    {'letter': 'خ', 'name': 'Kha', 'pronunciation': 'kha', 'example': 'خروف (Kharuf - Sheep)'},
    {'letter': 'د', 'name': 'Dal', 'pronunciation': 'da', 'example': 'دب (Dubb - Bear)'},
    {'letter': 'ذ', 'name': 'Dhal', 'pronunciation': 'dha', 'example': 'ذئب (Dhiib - Wolf)'},
    {'letter': 'ر', 'name': 'Ra', 'pronunciation': 'ra', 'example': 'رمان (Rumman - Pomegranate)'},
    {'letter': 'ز', 'name': 'Zay', 'pronunciation': 'za', 'example': 'زهرة (Zahra - Flower)'},
    {'letter': 'س', 'name': 'Seen', 'pronunciation': 'sa', 'example': 'سمك (Samak - Fish)'},
    {'letter': 'ش', 'name': 'Sheen', 'pronunciation': 'sha', 'example': 'شجرة (Shajara - Tree)'},
    {'letter': 'ص', 'name': 'Sad', 'pronunciation': 'sa', 'example': 'صقر (Saqr - Falcon)'},
    {'letter': 'ض', 'name': 'Dad', 'pronunciation': 'da', 'example': 'ضفدع (Difda - Frog)'},
    {'letter': 'ط', 'name': 'Ta', 'pronunciation': 'ta', 'example': 'طائر (Tair - Bird)'},
    {'letter': 'ظ', 'name': 'Dha', 'pronunciation': 'dha', 'example': 'ظبي (Dhabi - Deer)'},
    {'letter': 'ع', 'name': 'Ain', 'pronunciation': 'a', 'example': 'عصفور (Asfur - Sparrow)'},
    {'letter': 'غ', 'name': 'Ghain', 'pronunciation': 'gha', 'example': 'غراب (Ghurab - Crow)'},
    {'letter': 'ف', 'name': 'Fa', 'pronunciation': 'fa', 'example': 'فيل (Fil - Elephant)'},
    {'letter': 'ق', 'name': 'Qaf', 'pronunciation': 'qa', 'example': 'قطة (Qitta - Cat)'},
    {'letter': 'ك', 'name': 'Kaf', 'pronunciation': 'ka', 'example': 'كلب (Kalb - Dog)'},
    {'letter': 'ل', 'name': 'Lam', 'pronunciation': 'la', 'example': 'ليمون (Laymun - Lemon)'},
    {'letter': 'م', 'name': 'Meem', 'pronunciation': 'ma', 'example': 'ماء (Maa - Water)'},
    {'letter': 'ن', 'name': 'Noon', 'pronunciation': 'na', 'example': 'نحلة (Nahla - Bee)'},
    {'letter': 'ه', 'name': 'Ha', 'pronunciation': 'ha', 'example': 'هدهد (Hudhud - Hoopoe)'},
    {'letter': 'و', 'name': 'Waw', 'pronunciation': 'wa', 'example': 'وردة (Warda - Rose)'},
    {'letter': 'ي', 'name': 'Ya', 'pronunciation': 'ya', 'example': 'يد (Yad - Hand)'},
  ];

  // Vowels (Harakat)
  final List<Map<String, String>> vowels = [
    {'name': 'Fatha', 'symbol': 'َ', 'sound': 'a', 'example': 'بَ (ba)'},
    {'name': 'Kasra', 'symbol': 'ِ', 'sound': 'i', 'example': 'بِ (bi)'},
    {'name': 'Damma', 'symbol': 'ُ', 'sound': 'u', 'example': 'بُ (bu)'},
    {'name': 'Sukun', 'symbol': 'ْ', 'sound': 'silent', 'example': 'بْ (b)'},
    {'name': 'Tanween Fath', 'symbol': 'ً', 'sound': 'an', 'example': 'بً (ban)'},
    {'name': 'Tanween Kasr', 'symbol': 'ٍ', 'sound': 'in', 'example': 'بٍ (bin)'},
    {'name': 'Tanween Damm', 'symbol': 'ٌ', 'sound': 'un', 'example': 'بٌ (bun)'},
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Noorani Qaida'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Tab Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        'Arabic Letters',
                        _selectedLetterIndex == 0,
                        () => setState(() => _selectedLetterIndex = 0),
                        appProvider,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTabButton(
                        'Vowels',
                        _selectedLetterIndex == 1,
                        () => setState(() => _selectedLetterIndex = 1),
                        appProvider,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: _selectedLetterIndex == 0
                    ? _buildLettersGrid(appProvider, isDark)
                    : _buildVowelsGrid(appProvider, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap, AppProvider appProvider) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    appProvider.accentColor,
                    appProvider.accentColor.withOpacity(0.8),
                  ],
                )
              : null,
          color: !isSelected ? appProvider.accentColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appProvider.accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : appProvider.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLettersGrid(AppProvider appProvider, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: arabicLetters.length,
      itemBuilder: (context, index) {
        final letter = arabicLetters[index];
        return _buildLetterCard(letter, appProvider, isDark);
      },
    );
  }

  Widget _buildVowelsGrid(AppProvider appProvider, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vowels.length,
      itemBuilder: (context, index) {
        final vowel = vowels[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildVowelCard(vowel, appProvider, isDark),
        );
      },
    );
  }

  Widget _buildLetterCard(Map<String, String> letter, AppProvider appProvider, bool isDark) {
    return GestureDetector(
      onTap: () {
        _showLetterDetail(letter, appProvider, isDark);
      },
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Arabic Letter
            Text(
              letter['letter']!,
              style: AppTheme.arabicTextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: appProvider.accentColor,
              ),
            ),
            const SizedBox(height: 8),
            // Letter Name
            Text(
              letter['name']!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            // Pronunciation
            Text(
              letter['pronunciation']!,
              style: TextStyle(
                fontSize: 12,
                color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVowelCard(Map<String, String> vowel, AppProvider appProvider, bool isDark) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appProvider.accentColor,
                  appProvider.accentColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'ب${vowel['symbol']}',
                style: AppTheme.arabicTextStyle(
                  fontSize: 32,
                  color: Colors.white,
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
                  vowel['name']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sound: ${vowel['sound']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: appProvider.accentColor,
                  ),
                ),
                Text(
                  vowel['example']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.volume_up_rounded,
              color: appProvider.accentColor,
            ),
            onPressed: () {
              // Play sound
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Playing: ${vowel['name']}'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLetterDetail(Map<String, String> letter, AppProvider appProvider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.primaryDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Large Arabic Letter
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appProvider.accentColor,
                    appProvider.accentColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: appProvider.accentColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  letter['letter']!,
                  style: AppTheme.arabicTextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              letter['name']!,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Pronunciation: ${letter['pronunciation']}',
              style: TextStyle(
                fontSize: 18,
                color: appProvider.accentColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Example
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      'Example',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      letter['example']!,
                      style: TextStyle(
                        fontSize: 20,
                        color: appProvider.accentColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Playing ${letter['name']}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('Play Sound'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appProvider.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Practice mode coming soon!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.draw_rounded),
                      label: const Text('Practice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
