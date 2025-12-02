import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import '../widgets/glass_card.dart';
import 'quran_reading_screen.dart';
import 'dua_screen.dart';
import 'tasbih_screen.dart';
import 'manzil_screen.dart';
import 'islamic_stories_screen.dart';
import 'memorization_screen.dart';
import 'settings_screen.dart';
import 'hadith_collections_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey<QuranReadingScreenState> _quranKey = GlobalKey<QuranReadingScreenState>();
  
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      RepaintBoundary(child: QuranReadingScreen(key: _quranKey)),
      const RepaintBoundary(child: ManzilScreen()),
      // const RepaintBoundary(child: HadithCollectionsScreen()),
      const RepaintBoundary(child: DuaScreen()),
      const RepaintBoundary(child: IslamicStoriesScreen()),
      const RepaintBoundary(child: MemorizationScreen()),
      RepaintBoundary(child: SettingsScreen()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const navItems = [
      BottomNavItem(
        icon: Icons.home_rounded,
        label: 'Home',
      ),
      BottomNavItem(
        icon: FlutterIslamicIcons.solidQuran,
        label: 'Quran',
      ),
      // BottomNavItem(
      //   icon: Icons.library_books_rounded,
      //   label: 'Hadith',
      // ),
      BottomNavItem(
        icon: FlutterIslamicIcons.solidPrayer,
        label: 'Dua & Azkaar',
      ),
      // BottomNavItem(
      //   icon: Icons.circle_outlined,
      //   label: 'Tasbih',
      // ),
      BottomNavItem(
        icon: Icons.auto_stories_rounded,
        label: 'Stories',
      ),
      BottomNavItem(
        icon: Icons.psychology_rounded,
        label: 'Memorize',
      ),
      BottomNavItem(
        icon: Icons.settings_rounded,
        label: 'Settings',
      ),
    ];
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Stop Quran audio when switching away from Quran tab
          if (_currentIndex == 0 && index != 0) {
            _quranKey.currentState?.stopAudio();
          }
          setState(() {
            _currentIndex = index;
          });
        },
        items: navItems,
      ),
    );
  }
}
