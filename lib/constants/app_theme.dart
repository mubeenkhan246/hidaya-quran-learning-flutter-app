import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// iOS 26 Liquid Glass Theme
class AppTheme {
  // Theme Modes
  static const String themeDark = 'dark';
  static const String themeLight = 'light';
  
  // Glass Style Types
  static const String glassStyleClear = 'clear';
  static const String glassStyleTinted = 'tinted';
  
  // Color Palette - Modern & Vibrant
  static const Color primaryGold = Color(0xFFFFB800);
  static const Color primaryDark = Color(0xFF0A0E1A);
  static const Color secondaryDeep = Color(0xFF1A1F3A);
  static const Color accentPurple = Color(0xFF6366F1);
  static const Color textLight = Color(0xFFFAFAFA);
  static const Color textDark = Color(0xFF0F1419);
  static const Color textSecondaryLight = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF4A5568);
  
  // Theme Colors - 20 stunning options with perfect saturation
  static const List<Map<String, dynamic>> themeColors = [
    {'name': 'Golden', 'color': Color(0xFFFFB800), 'id': 'gold'},
    {'name': 'Emerald', 'color': Color(0xFF10B981), 'id': 'emerald'},
    {'name': 'Ocean', 'color': Color(0xFF0EA5E9), 'id': 'sapphire'},
    {'name': 'Coral', 'color': Color(0xFFFF6B6B), 'id': 'ruby'},
    {'name': 'Purple', 'color': Color(0xFF9333EA), 'id': 'amethyst'},
    {'name': 'Teal', 'color': Color(0xFF14B8A6), 'id': 'teal'},
    {'name': 'Rose', 'color': Color(0xFFFF5C8D), 'id': 'rose'},
    {'name': 'Amber', 'color': Color(0xFFF59E0B), 'id': 'amber'},
    {'name': 'Indigo', 'color': Color(0xFF6366F1), 'id': 'indigo'},
    {'name': 'Sky', 'color': Color(0xFF38BDF8), 'id': 'cyan'},
    {'name': 'Pink', 'color': Color(0xFFEC4899), 'id': 'pink'},
    {'name': 'Lime', 'color': Color(0xFF84CC16), 'id': 'lime'},
    // NEW COLORS
    {'name': 'Mint', 'color': Color(0xFF00D9B8), 'id': 'mint'},
    {'name': 'Lavender', 'color': Color(0xFFA78BFA), 'id': 'lavender'},
    {'name': 'Sunset', 'color': Color(0xFFFB923C), 'id': 'sunset'},
    {'name': 'Crimson', 'color': Color(0xFFDC2626), 'id': 'crimson'},
    {'name': 'Violet', 'color': Color(0xFF8B5CF6), 'id': 'violet'},
    {'name': 'Aqua', 'color': Color(0xFF06B6D4), 'id': 'aqua'},
    {'name': 'Peach', 'color': Color(0xFFFB7185), 'id': 'peach'},
    {'name': 'Forest', 'color': Color(0xFF059669), 'id': 'forest'},
  ];
  
  // Get accent color by ID
  static Color getAccentColor(String colorId) {
    final colorMap = themeColors.firstWhere(
      (c) => c['id'] == colorId,
      orElse: () => themeColors[0],
    );
    return colorMap['color'] as Color;
  }
  
  // Glass Colors - Enhanced for better depth
  static const Color glassClear = Color(0x18FFFFFF);
  static const Color glassTinted = Color(0x25FFB800); // Fallback - prefer dynamic accent color
  static const Color glassStroke = Color(0x40FFFFFF);
  static const Color glassStrokeDark = Color(0x60FFFFFF);
  
  // Dynamic glass tinting using accent color (use in glassDecoration)
  // Dark mode: accentColor.withOpacity(0.15)
  // Light mode: accentColor.withOpacity(0.12)
  
  // Dark Mode Gradients - Deep, rich, modern
  static final List<Color> backgroundGradientDark = [
    const Color(0xFF0A0E1A),
    const Color(0xFF1A1F3A),
    const Color(0xFF0F1623),
  ];
  
  // Light Mode Gradients - Soft, warm, elegant
  static final List<Color> backgroundGradientLight = [
    const Color(0xFFFAFAFA),
    const Color(0xFFF0F0F3),
    const Color(0xFFFFFFFF),
  ];
  
  static final List<Color> cardGradient = [
    const Color(0x25FFFFFF),
    const Color(0x12FFFFFF),
  ];
  
  // Get theme based on mode with font size scaling
  static ThemeData getTheme(String themeMode, String glassStyle, {double baseFontSize = 16.0}) {
    return themeMode == themeDark 
        ? darkTheme(glassStyle, baseFontSize: baseFontSize) 
        : lightTheme(glassStyle, baseFontSize: baseFontSize);
  }
  
  // Theme Data - Dark
  static ThemeData darkTheme(String glassStyle, {double baseFontSize = 16.0}) {
    final fontScale = baseFontSize / 16.0; // Calculate scale factor
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryGold,
      scaffoldBackgroundColor: primaryDark,
      canvasColor: primaryDark,
      
      // Text Theme - Scaled by baseFontSize
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32 * fontScale,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28 * fontScale,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24 * fontScale,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18 * fontScale,
          fontWeight: FontWeight.w500,
          color: textLight,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16 * fontScale,
          fontWeight: FontWeight.w500,
          color: textLight,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16 * fontScale,
          color: textLight,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14 * fontScale,
          color: textLight.withOpacity(0.9),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12 * fontScale,
          color: textLight.withOpacity(0.7),
        ),
      ),
      
      // Arabic Text Theme (for Quran)
      // Note: Will be applied separately where needed
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: glassStyle == glassStyleClear ? glassClear : glassTinted,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: glassStroke,
            width: 1,
          ),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: primaryDark,
          elevation: 0,
          shadowColor: primaryGold.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: textLight,
        size: 24,
      ),
      
      dividerTheme: DividerThemeData(
        color: textLight.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGold;
          }
          return textLight.withOpacity(0.5);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGold.withOpacity(0.5);
          }
          return textLight.withOpacity(0.1);
        }),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassClear,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: glassStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: glassStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryGold, width: 2),
        ),
      ),
      
      colorScheme: ColorScheme.dark(
        primary: primaryGold,
        secondary: secondaryDeep,
        surface: primaryDark,
        error: Colors.red[400]!,
      ).copyWith(surface: primaryDark),
    );
  }
  
  // Theme Data - Light
  static ThemeData lightTheme(String glassStyle, {double baseFontSize = 16.0}) {
    final fontScale = baseFontSize / 16.0; // Calculate scale factor
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryGold,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      canvasColor: const Color(0xFFFAFAFA),
      
      // Text Theme - Scaled by baseFontSize
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32 * fontScale,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28 * fontScale,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 24 * fontScale,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20 * fontScale,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18 * fontScale,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16 * fontScale,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16 * fontScale,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14 * fontScale,
          color: textDark.withOpacity(0.9),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12 * fontScale,
          color: textDark.withOpacity(0.7),
        ),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textDark),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      
      cardTheme: CardThemeData(
        color: glassStyle == glassStyleClear 
            ? const Color(0x50FFFFFF) 
            : const Color(0x40FFB800),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: textDark.withOpacity(0.08),
            width: 1.5,
          ),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryGold.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: textDark,
        size: 24,
      ),
      
      dividerTheme: DividerThemeData(
        color: textDark.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGold;
          }
          return textDark.withOpacity(0.3);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryGold.withOpacity(0.5);
          }
          return textDark.withOpacity(0.1);
        }),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x30FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textDark.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textDark.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryGold, width: 2),
        ),
      ),
      
      colorScheme: ColorScheme.light(
        primary: primaryGold,
        secondary: secondaryDeep,
        surface: const Color(0xFFFAFAFA),
        error: const Color(0xFFDC2626),
        brightness: Brightness.light,
      ),
    );
  }
  
  // Arabic Text Style
  static TextStyle arabicTextStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double height = 2.0,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textLight,
      height: height,
    );
  }
  
  // Glass Container Decoration with Dynamic Accent Color
  static BoxDecoration glassDecoration({
    required String glassStyle,
    required bool isDark,
    Color? accentColor,
    double borderRadius = 24,
    bool showBorder = true,
  }) {
    final accent = accentColor ?? primaryGold;
    
    return BoxDecoration(
      color: isDark
          ? (glassStyle == glassStyleClear 
              ? glassClear 
              : accent.withOpacity(0.15))
          : (glassStyle == glassStyleClear 
              ? const Color(0x50FFFFFF) 
              : accent.withOpacity(0.12)),
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder
          ? Border.all(
              color: isDark 
                  ? (glassStyle == glassStyleClear 
                      ? glassStroke 
                      : accent.withOpacity(0.3))
                  : (glassStyle == glassStyleClear
                      ? textDark.withOpacity(0.08)
                      : accent.withOpacity(0.25)),
              width: isDark ? 1 : 1.5,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: glassStyle == glassStyleTinted
              ? accent.withOpacity(isDark ? 0.15 : 0.08)
              : Colors.black.withOpacity(isDark ? 0.15 : 0.06),
          blurRadius: isDark ? 20 : 15,
          offset: Offset(0, isDark ? 10 : 8),
        ),
      ],
    );
  }
  
  // Gradient Background Decoration
  static BoxDecoration gradientBackground(String themeMode) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: themeMode == themeDark 
            ? backgroundGradientDark 
            : backgroundGradientLight,
      ),
    );
  }
}
