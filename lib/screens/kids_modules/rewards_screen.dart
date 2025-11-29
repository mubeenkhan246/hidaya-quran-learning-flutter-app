import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/glass_card.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample data - In a real app, this would come from the user's progress
  final int totalStars = 125;
  final int totalGems = 48;
  final int currentLevel = 5;
  final int currentStreak = 7;

  final List<Map<String, dynamic>> badges = [
    {
      'name': 'First Steps',
      'description': 'Completed first lesson',
      'icon': Icons.directions_walk_rounded,
      'color': Colors.blue,
      'earned': true,
    },
    {
      'name': 'Arabic Master',
      'description': 'Learned all 28 letters',
      'icon': Icons.abc_rounded,
      'color': Colors.purple,
      'earned': true,
    },
    {
      'name': 'Quick Learner',
      'description': 'Completed 10 lessons',
      'icon': Icons.flash_on_rounded,
      'color': Colors.amber,
      'earned': true,
    },
    {
      'name': 'Hifz Hero',
      'description': 'Memorized 10 Surahs',
      'icon': Icons.psychology_rounded,
      'color': Colors.green,
      'earned': false,
    },
    {
      'name': 'Game Champion',
      'description': 'Won 20 games',
      'icon': Icons.emoji_events_rounded,
      'color': Colors.orange,
      'earned': false,
    },
    {
      'name': 'Consistent Student',
      'description': '30-day learning streak',
      'icon': Icons.local_fire_department_rounded,
      'color': Colors.red,
      'earned': false,
    },
    {
      'name': 'Writing Pro',
      'description': 'Practiced writing 50 times',
      'icon': Icons.draw_rounded,
      'color': Colors.teal,
      'earned': false,
    },
    {
      'name': 'Story Listener',
      'description': 'Listened to all stories',
      'icon': Icons.auto_stories_rounded,
      'color': Colors.indigo,
      'earned': false,
    },
  ];

  final List<Map<String, dynamic>> achievements = [
    {
      'title': 'Perfect Week',
      'description': 'Completed lessons every day for a week',
      'progress': 0.7,
      'current': 7,
      'target': 10,
    },
    {
      'title': 'Surah Expert',
      'description': 'Memorize 20 Surahs from Juz Amma',
      'progress': 0.5,
      'current': 10,
      'target': 20,
    },
    {
      'title': 'Quiz Master',
      'description': 'Score 100% on 10 quizzes',
      'progress': 0.3,
      'current': 3,
      'target': 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          title: const Text('Rewards & Achievements'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: appProvider.accentColor,
            labelColor: appProvider.accentColor,
            unselectedLabelColor: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.5),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Badges'),
              Tab(text: 'Goals'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(appProvider, isDark),
              _buildBadgesTab(appProvider, isDark),
              _buildGoalsTab(appProvider, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(AppProvider appProvider, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Stars',
                  totalStars.toString(),
                  Icons.star_rounded,
                  Colors.amber,
                  appProvider,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Gems',
                  totalGems.toString(),
                  Icons.diamond_rounded,
                  Colors.cyan,
                  appProvider,
                  isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Level',
                  currentLevel.toString(),
                  Icons.emoji_events_rounded,
                  Colors.purple,
                  appProvider,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Day Streak',
                  '$currentStreak 🔥',
                  Icons.local_fire_department_rounded,
                  Colors.orange,
                  appProvider,
                  isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Level Progress
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level $currentLevel Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '65%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: appProvider.accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 12,
                    backgroundColor: appProvider.accentColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(appProvider.accentColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '35 stars to Level ${currentLevel + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Badges
          Text(
            'Recent Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textLight : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          
          ...badges.where((b) => b['earned'] as bool).take(3).map((badge) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            badge['color'] as Color,
                            (badge['color'] as Color).withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badge['icon'] as IconData,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            badge['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            badge['description'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBadgesTab(AppProvider appProvider, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isEarned = badge['earned'] as bool;
        
        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: isEarned
                      ? LinearGradient(
                          colors: [
                            badge['color'] as Color,
                            (badge['color'] as Color).withOpacity(0.7),
                          ],
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                  shape: BoxShape.circle,
                  boxShadow: isEarned ? [
                    BoxShadow(
                      color: (badge['color'] as Color).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Icon(
                  badge['icon'] as IconData,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                badge['name'] as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isEarned
                      ? (isDark ? AppTheme.textLight : AppTheme.textDark)
                      : (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                badge['description'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isEarned) ...[
                const SizedBox(height: 8),
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
              ] else ...[
                const SizedBox(height: 8),
                const Icon(Icons.lock_rounded, color: Colors.grey, size: 20),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalsTab(AppProvider appProvider, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Active Goals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textLight : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        
        ...achievements.map((achievement) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          achievement['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.textLight : AppTheme.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: appProvider.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${achievement['current']}/${achievement['target']}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: appProvider.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement['description'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: achievement['progress'] as double,
                      minHeight: 8,
                      backgroundColor: appProvider.accentColor.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(appProvider.accentColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((achievement['progress'] as double) * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: appProvider.accentColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        
        const SizedBox(height: 24),
        
        // Rewards Shop (Future Feature)
        GlassCard(
          child: Column(
            children: [
              Icon(
                Icons.shopping_bag_rounded,
                size: 60,
                color: appProvider.accentColor.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Rewards Shop',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coming Soon!',
                style: TextStyle(
                  fontSize: 14,
                  color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Spend your stars and gems on avatars, themes, and more!',
                style: TextStyle(
                  fontSize: 12,
                  color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    AppProvider appProvider,
    bool isDark,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textLight : AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
