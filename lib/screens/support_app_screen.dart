import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';

class SupportAppScreen extends StatelessWidget {
  const SupportAppScreen({super.key});

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
              _buildHeader(context, appProvider, isDark),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildMainCard(context, appProvider, isDark),
                      const SizedBox(height: 24),
                      _buildBenefitsCard(context, appProvider, isDark),
                      const SizedBox(height: 24),
                      _buildDonationOptions(context, appProvider, isDark),
                      const SizedBox(height: 24),
                      _buildContactCard(context, appProvider, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider appProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? AppTheme.textLight : AppTheme.textDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support the App',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
                Text(
                  'Help us continue our mission',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
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

  Widget _buildMainCard(BuildContext context, AppProvider appProvider, bool isDark) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appProvider.accentColor.withOpacity(0.2),
                    appProvider.accentColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volunteer_activism_rounded,
                size: 64,
                color: appProvider.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Help Keep This App Free',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your support helps us maintain and improve this Islamic app for millions of Muslims worldwide. Every contribution, no matter how small, makes a difference.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? AppTheme.textLight.withOpacity(0.8)
                    : AppTheme.textDark.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard(BuildContext context, AppProvider appProvider, bool isDark) {
    final benefits = [
      {'icon': Icons.check_circle_rounded, 'text': 'Keep the app completely free'},
      {'icon': Icons.update_rounded, 'text': 'Regular updates and new features'},
      {'icon': Icons.bug_report_rounded, 'text': 'Bug fixes and improvements'},
      {'icon': Icons.translate_rounded, 'text': 'More language support'},
      {'icon': Icons.cloud_rounded, 'text': 'Server and hosting costs'},
      {'icon': Icons.diversity_3_rounded, 'text': 'Support our development team'},
    ];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: appProvider.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Support Enables',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(
                    benefit['icon'] as IconData,
                    color: appProvider.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      benefit['text'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppTheme.textLight.withOpacity(0.9)
                            : AppTheme.textDark.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationOptions(BuildContext context, AppProvider appProvider, bool isDark) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payments_rounded,
                  color: appProvider.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Ways to Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // One-time Donation
            _buildDonationButton(
              context,
              'One-time Donation',
              'Make a single contribution',
              Icons.payment_rounded,
              appProvider,
              isDark,
              () => _showDonationDialog(context, 'one-time', appProvider),
            ),
            const SizedBox(height: 12),
            
            // Monthly Support
            _buildDonationButton(
              context,
              'Monthly Support',
              'Become a regular supporter',
              Icons.calendar_month_rounded,
              appProvider,
              isDark,
              () => _showDonationDialog(context, 'monthly', appProvider),
            ),
            const SizedBox(height: 12),
            
            // Share the App
            _buildDonationButton(
              context,
              'Share the App',
              'Spread the word to others',
              Icons.share_rounded,
              appProvider,
              isDark,
              () => _shareApp(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    AppProvider appProvider,
    bool isDark,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appProvider.accentColor.withOpacity(0.1),
              appProvider.accentColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appProvider.accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appProvider.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: appProvider.accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.textLight.withOpacity(0.7)
                          : AppTheme.textDark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: appProvider.accentColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, AppProvider appProvider, bool isDark) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.email_rounded,
              color: appProvider.accentColor,
              size: 32,
            ),
            const SizedBox(height: 16),
            Text(
              'Have Questions?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contact us for custom donation options or partnership opportunities',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppTheme.textLight.withOpacity(0.7)
                    : AppTheme.textDark.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _contactUs(context),
              icon: const Icon(Icons.email_rounded),
              label: const Text('Contact Us'),
              style: TextButton.styleFrom(
                foregroundColor: appProvider.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDonationDialog(BuildContext context, String type, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 'one-time' ? 'One-time Donation' : 'Monthly Support'),
        content: Text(
          'Thank you for your interest in supporting us!\n\n'
          'Donation options will be available soon. '
          'Please check back later or contact us for alternative donation methods.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality will be implemented soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _contactUs(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact: support@islamicapp.com'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }
}
