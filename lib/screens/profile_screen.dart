import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import 'donation_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.gradientBackground(context.watch<AppProvider>().themeMode),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildStatsGrid(context),
                const SizedBox(height: 24),
                _buildProgressSection(context),
                const SizedBox(height: 24),
                _buildAchievements(context),
                const SizedBox(height: 24),
                _buildSettings(context),
                const SizedBox(height: 24),
                _buildDonationButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appProvider.accentColor,
                  appProvider.accentColor.withOpacity(0.7),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learner',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'On a journey to understanding',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final progress = appProvider.userProgress;
    
    final totalHours = (progress?.totalStudyTime ?? 0) ~/ 3600;
    final streak = progress?.currentStreak ?? 0;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Study Hours',
            totalHours.toString(),
            Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Day Streak',
            streak.toString(),
            Icons.local_fire_department_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final appProvider = context.watch<AppProvider>();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            color: appProvider.accentColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: appProvider.accentColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final progress = appProvider.userProgress;
    final dailyGoal = progress?.dailyGoal ?? 15;
    final isDailyGoalMet = progress?.isDailyGoalMet() ?? false;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Goal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Icon(
                isDailyGoalMet
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: isDailyGoalMet
                    ? Colors.green
                    : AppTheme.textLight.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$dailyGoal minutes per day',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: isDailyGoalMet ? 1.0 : 0.5,
              backgroundColor: AppTheme.textLight.withOpacity(0.1),
              valueColor:  AlwaysStoppedAnimation<Color>(
                appProvider.accentColor,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final achievements = appProvider.userProgress?.achievements ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Achievements',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        if (achievements.isEmpty)
          GlassCard(
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 48,
                    color: AppTheme.textLight.withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No achievements yet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep studying to unlock achievements',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          )
        else
          GlassCard(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: achievements.map((achievement) {
                return Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: appProvider.accentColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          achievement.iconName,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement.title,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSettings(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        GlassCard(
          child: Column(
            children: [
              _buildSettingItem(
                context,
                'Language',
                appProvider.selectedLanguage,
                Icons.language_rounded,
                () => _showLanguageDialog(context),
              ),
              const Divider(height: 24),
              _buildSettingItem(
                context,
                'Glass Style',
                appProvider.glassStyle == AppTheme.glassStyleClear
                    ? 'Clear'
                    : 'Tinted',
                Icons.style_rounded,
                () => _showGlassStyleDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    final appProvider = context.watch<AppProvider>();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: appProvider.accentColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.textLight,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppConstants.supportedTranslations.map((translation) {
            final language = translation['name']!;
            final key = translation['key']!;
            return ListTile(
              title: Text(language),
              onTap: () {
                appProvider.setLanguage(language, key);
                Navigator.pop(context);
              },
              trailing: appProvider.selectedLanguage == language
                  ?  Icon(Icons.check_rounded, color: appProvider.accentColor)
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showGlassStyleDialog(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        title: const Text('Glass Style'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Clear'),
              onTap: () {
                appProvider.setGlassStyle(AppTheme.glassStyleClear);
                Navigator.pop(context);
              },
              trailing: appProvider.glassStyle == AppTheme.glassStyleClear
                  ?  Icon(Icons.check_rounded, color: appProvider.accentColor)
                  : null,
            ),
            ListTile(
              title: const Text('Tinted'),
              onTap: () {
                appProvider.setGlassStyle(AppTheme.glassStyleTinted);
                Navigator.pop(context);
              },
              trailing: appProvider.glassStyle == AppTheme.glassStyleTinted
                  ?  Icon(Icons.check_rounded, color: appProvider.accentColor)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DonationScreen(),
            ),
          );
        },
        icon: const Icon(Icons.favorite_rounded),
        label: const Text('Support the App'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
