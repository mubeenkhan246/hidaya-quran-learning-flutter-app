import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

/// Responsive helper for adapting UI to different screen sizes
/// Optimized for iPad 11th Gen and other tablets
class ResponsiveHelper {
  final BuildContext context;
  
  ResponsiveHelper(this.context);
  
  // Screen size getters
  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  double get diagonal => MediaQuery.of(context).size.shortestSide;
  
  // Device type detection
  bool get isPhone => diagonal < 600;
  bool get isTablet => diagonal >= 600 && diagonal < 900;
  bool get isLargeTablet => diagonal >= 900;
  bool get isTabletOrLarger => diagonal >= 600;
  
  // iPad specific (based on typical iPad dimensions)
  bool get isIPad => diagonal >= 768 && diagonal <= 1024;
  bool get isIPadPro => diagonal > 1024;
  
  // Orientation
  bool get isPortrait => height > width;
  bool get isLandscape => width > height;
  
  // Font size scale factor (baseFontSize / 16)
  // 16px = 1.0x, 20px = 1.25x, 24px = 1.5x, etc.
  double get fontSizeScale {
    try {
      final baseFontSize = context.read<AppProvider>().baseFontSize;
      return baseFontSize / 16.0;
    } catch (e) {
      return 1.0; // Fallback if provider not available
    }
  }
  
  // Translation/English font size (separate control from main UI)
  double get translationFontSize {
    try {
      return context.read<AppProvider>().translationFontSize;
    } catch (e) {
      return 16.0; // Fallback
    }
  }
  
  // Responsive values
  double responsiveValue({
    required double phone,
    double? tablet,
    double? largeTablet,
  }) {
    if (isLargeTablet && largeTablet != null) return largeTablet;
    if (isTablet && tablet != null) return tablet;
    if (isTabletOrLarger && tablet != null) return tablet;
    return phone;
  }
  
  // Grid columns based on screen size
  int get gridColumns {
    if (isLandscape && isTabletOrLarger) return 4;
    if (isTabletOrLarger) return 3;
    return 2;
  }
  
  // Quick actions columns
  int get quickActionsColumns {
    if (width > 1200) return 6;
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 3;
  }
  
  // Responsive padding
  EdgeInsets get screenPadding => EdgeInsets.symmetric(
    horizontal: responsiveValue(phone: 24, tablet: 40, largeTablet: 60),
  );
  
  EdgeInsets get cardPadding => EdgeInsets.all(
    responsiveValue(phone: 10, tablet: 20, largeTablet: 24),
  );
  
  // Responsive spacing
  double get spacing => responsiveValue(phone: 16, tablet: 20, largeTablet: 24);
  double get smallSpacing => responsiveValue(phone: 8, tablet: 12, largeTablet: 16);
  double get largeSpacing => responsiveValue(phone: 24, tablet: 32, largeTablet: 40);
  
  // Font sizes (scaled by base font size)
  double get titleFontSize => responsiveValue(phone: 24, tablet: 28, largeTablet: 32) * fontSizeScale;
  double get headingFontSize => responsiveValue(phone: 18, tablet: 22, largeTablet: 26) * fontSizeScale;
  double get bodyFontSize => responsiveValue(phone: 16, tablet: 18, largeTablet: 20) * fontSizeScale;
  double get smallFontSize => responsiveValue(phone: 14, tablet: 16, largeTablet: 18) * fontSizeScale;
  
  // Arabic text sizes (scaled by base font size)
  double get arabicTitleSize => responsiveValue(phone: 28, tablet: 34, largeTablet: 40) * fontSizeScale;
  double get arabicBodySize => responsiveValue(phone: 24, tablet: 28, largeTablet: 32) * fontSizeScale;
  
  // Icon sizes
  double get iconSize => responsiveValue(phone: 24, tablet: 28, largeTablet: 32);
  double get smallIconSize => responsiveValue(phone: 20, tablet: 24, largeTablet: 28);
  
  // Card dimensions
  double get cardBorderRadius => responsiveValue(phone: 16, tablet: 20, largeTablet: 24);
  double get smallCardBorderRadius => responsiveValue(phone: 12, tablet: 16, largeTablet: 20);
  
  // Content width constraints (for very large screens)
  double get maxContentWidth {
    if (width > 1400) return 1200;
    if (width > 1000) return 900;
    return width;
  }
  
  // Center content on large screens
  Widget constrainWidth(Widget child) {
    if (width <= 1000) return child;
    
    return Center(
      child: Container(
        width: maxContentWidth,
        child: child,
      ),
    );
  }
}

/// Extension for easy access
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper(this);
}
