import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';

/// Liquid Glass Card Widget - iOS 26 Style
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final VoidCallback? onTap;
  final bool showBorder;
  
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.onTap,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final glassStyle = appProvider.glassStyle;
    final isDark = appProvider.isDarkMode;
    final accentColor = appProvider.accentColor;
    
    final defaultPadding = padding ?? const EdgeInsets.all(16);
    
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: height,
          width: width,
          padding: defaultPadding,
          decoration: AppTheme.glassDecoration(
            glassStyle: glassStyle,
            isDark: isDark,
            accentColor: accentColor,
            borderRadius: borderRadius,
            showBorder: showBorder,
          ),
          child: child,
        ),
      ),
    );
    
    if (onTap != null) {
      content = GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    
    if (margin != null) {
      content = Padding(
        padding: margin!,
        child: content,
      );
    }
    
    return content;
  }
}

/// Animated Glass Card with Scale Effect
class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  
  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.onTap != null) {
          Future.delayed(const Duration(milliseconds: 150), widget.onTap);
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GlassCard(
          borderRadius: widget.borderRadius,
          padding: widget.padding,
          margin: widget.margin,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Glass App Bar
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  
  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final glassStyle = appProvider.glassStyle;
    final isDark = appProvider.isDarkMode;
    final accentColor = appProvider.accentColor;
    
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          title: Text(title),
          backgroundColor: glassStyle == AppTheme.glassStyleClear
              ? AppTheme.glassClear
              : accentColor.withOpacity(isDark ? 0.15 : 0.12),
          elevation: 0,
          leading: showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => Navigator.pop(context),
                )
              : leading,
          actions: actions,
        ),
      ),
    );
  }
}

/// Glass Bottom Navigation Bar
class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  
  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final glassStyle = appProvider.glassStyle;
    final isDark = appProvider.isDarkMode;
    final accentColor = appProvider.accentColor;
    
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: glassStyle == AppTheme.glassStyleClear
                ? AppTheme.glassClear
                : accentColor.withOpacity(isDark ? 0.15 : 0.12),
            border: Border(
              top: BorderSide(
                color: glassStyle == AppTheme.glassStyleClear
                    ? (isDark ? AppTheme.glassStrokeDark : AppTheme.textDark.withOpacity(0.1))
                    : accentColor.withOpacity(isDark ? 0.3 : 0.25),
                width: 1.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left:9.0, right:9.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                items.length,
                (index) => _NavItem(
                  item: items[index],
                  isSelected: currentIndex == index,
                  accentColor: accentColor,
                  isDark: isDark,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;
  
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppTheme.textLight : AppTheme.textDark;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(isDark ? 0.25 : 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: accentColor.withOpacity(0.3),
              blurRadius: 2,
              spreadRadius: 0,
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? accentColor : textColor.withOpacity(0.5),
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? accentColor : textColor.withOpacity(0.5),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  
  const BottomNavItem({
    required this.icon,
    required this.label,
  });
}
