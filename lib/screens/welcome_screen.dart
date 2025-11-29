import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onGetStarted() async {
    final appProvider = context.read<AppProvider>();
    
    // Set default language to English
    final defaultLanguage = AppConstants.supportedLanguages[0]; // English
    final translation = AppConstants.supportedTranslations[0]; // English translation
    
    await appProvider.setLanguage(defaultLanguage, translation['key']!);
    await appProvider.completeFirstLaunch();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    
    return Scaffold(
      body: Container(
        decoration: AppTheme.gradientBackground(context.watch<AppProvider>().themeMode),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                    
                    // App Logo/Icon
                    _buildLogo(),
                    
                    const SizedBox(height: 32),
                    
                      // Welcome Title
                      Text(
                        'Welcome to Hidayah',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'Your Companion for Learning the Quran',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    
                    const SizedBox(height: 48),
                    
                      // Features
                      _buildFeatures(isDark),
                      
                      const SizedBox(height: 48),
                    
                      // Free & Ad-Free Notice
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                             Icon(
                              Icons.favorite,
                              color: appProvider.accentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Free, Ad-Free, and Supported by Your Generosity',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Get Started Button
                      _buildGetStartedButton(),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final appProvider = context.watch<AppProvider>();
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            appProvider.accentColor,
            appProvider.accentColor.withOpacity(0.6),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: appProvider.accentColor.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.book_rounded,
        size: 60,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFeatures(bool isDark) {
    final features = [
      {'icon': Icons.headphones_rounded, 'text': 'Learn Tajweed with Audio'},
      {'icon': Icons.translate_rounded, 'text': 'Multilingual Translations'},
      {'icon': Icons.psychology_rounded, 'text': 'Smart Memorization Tools'},
    ];
    final appProvider = context.watch<AppProvider>();
    
    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appProvider.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: appProvider.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                feature['text'] as String,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  Widget _buildGetStartedButton() {
    final appProvider = context.watch<AppProvider>();
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _onGetStarted,
        style: ElevatedButton.styleFrom(
          backgroundColor: appProvider.accentColor,
          foregroundColor: AppTheme.textDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadowColor: appProvider.accentColor.withOpacity(0.5),
        ),
        child: Text(
          'Get Started',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
