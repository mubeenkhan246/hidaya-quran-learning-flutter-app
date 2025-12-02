import 'package:flutter/material.dart';
import 'package:i_app/screens/events.dart';
import 'package:i_app/screens/names_of_allah.dart';
import 'package:i_app/screens/nearest_masjid_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../utils/responsive_helper.dart';
import '../screens/names_of_allah_screen.dart';
import '../screens/dua_screen.dart';
import '../screens/tasbih_screen.dart';
import '../screens/qibla_screen.dart';
import '../screens/manzil_screen.dart';
import '../screens/donation_screen.dart';
import '../screens/zakat_calculator_screen.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  void _handleNavigation(BuildContext context, String route, String title, AppProvider appProvider) {
    switch (route) {
      case '/quran':
        // Navigate to Manzil screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManzilScreen(showBackButton: true)),
        );
        break;
      case '/qibla':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QiblaScreen(showBackButton: true)),
        );
        break;
      case '/names':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EsmaulHusnaApp()),
        );
        break;
      case '/dua':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DuaScreen(showBackButton: true)),
        );
        break;
      case '/tasbih':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TasbihScreen(showBackButton: true)),
        );
        break;
        case '/events':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IslamicEventsApp()),
        );
        break;
      case '/donation':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DonationScreen()),
        );
        break;
      case '/zakat':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ZakatCalculatorScreen(showBackButton: true)),
        );
        break;
      case '/nearest_masjid':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NearestMasjidScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title - Coming Soon!'),
            backgroundColor: appProvider.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
    }
  }

  // Cache quick actions list to avoid recreating on every build
  static const quickActions = [
    // {
    //   'title': 'Read/Listen Quran',
    //   'icon': FlutterIslamicIcons.solidQuran,
    //   'color': Color(0xFF10B981),
    //   'route': '/quran',
    // },
    // {
    //   'title': 'Dua & Azkar',
    //   'icon': FlutterIslamicIcons.solidPrayer,
    //   'color': Color(0xFFF59E0B),
    //   'route': '/dua',
    // },
    {
      'title': 'Names of Allah',
      'icon': FlutterIslamicIcons.allah,
      'color': Color(0xFFFF6B6B),
      'route': '/names',
    },
    {
      'title': 'Qibla Direction',
      'icon': FlutterIslamicIcons.kaaba,
      'color': Color(0xFF0EA5E9),
      'route': '/qibla',
    },
    {
      'title': 'Tasbih Counter',
      'icon': FlutterIslamicIcons.solidTasbih,
      'color': Color(0xFF8B5CF6),
      'route': '/tasbih',
    },
    {
      'title': 'Events',
      'icon': FlutterIslamicIcons.calendar,
      'color': Color.fromARGB(255, 104, 162, 161),
      'route': '/events',
    },
    {
      'title': 'Zakat Calculator',
      'icon': FlutterIslamicIcons.solidZakat,
      'color': Color(0xFF14B8A6),
      'route': '/zakat',
    },
    {
      'title': 'Nearest Masjid',
      'icon': FlutterIslamicIcons.solidMosque,
      'color': Color(0xFF22C55E),
      'route': '/nearest_masjid',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDark = appProvider.isDarkMode;

        return Padding(
          padding: responsive.screenPadding,
          child: GlassCard(
            child: Padding(
              padding: responsive.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on_rounded,
                        color: appProvider.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.spacing),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: responsive.quickActionsColumns,
                      childAspectRatio: responsive.isTabletOrLarger ? 1.0 : 1.0,
                      crossAxisSpacing: responsive.smallSpacing,
                      mainAxisSpacing: responsive.smallSpacing,
                    ),
                    itemCount: quickActions.length,
                    itemBuilder: (context, index) {
                      final action = quickActions[index];
                      return _buildActionCard(
                        context,
                        action['title'] as String,
                        action['icon'] as IconData,
                        action['color'] as Color,
                        action['route'] as String,
                        appProvider,
                        isDark,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
    AppProvider appProvider,
    bool isDark,
  ) {
    return InkWell(
      onTap: () {
        _handleNavigation(context, route, title, appProvider);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark
                  ? color.withOpacity(0.15)
                  : color.withOpacity(0.12),
              isDark
                  ? color.withOpacity(0.08)
                  : color.withOpacity(0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              // decoration: BoxDecoration(
              //   color: color.withOpacity(0.2),
              //   borderRadius: BorderRadius.circular(12),
              // ),
              child: Icon(
                icon,
                color: color,
                size: 34,
              ),
            ),
            // const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textLight.withOpacity(0.9)
                    : AppTheme.textDark.withOpacity(0.9),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
