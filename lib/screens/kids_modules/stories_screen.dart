import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/glass_card.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final List<Map<String, dynamic>> stories = [
    {
      'title': 'Prophet Nuh (Noah)',
      'subtitle': 'The Story of the Great Flood',
      'icon': Icons.water_rounded,
      'color': Colors.blue,
      'moral': 'Patience and faith in Allah',
      'content': '''Prophet Nuh (peace be upon him) was a messenger of Allah who called his people to worship Allah alone for 950 years.

Despite his tireless efforts, only a few believed in his message. Allah commanded Nuh to build a great ark.

When the flood came, only those who believed were saved in the ark. This teaches us to have patience and strong faith in Allah.''',
    },
    {
      'title': 'Prophet Ibrahim (Abraham)',
      'subtitle': 'The Friend of Allah',
      'icon': Icons.favorite_rounded,
      'color': Colors.red,
      'moral': 'Complete trust in Allah',
      'content': '''Prophet Ibrahim (peace be upon him) was known as the Friend of Allah because of his strong faith.

When he was thrown into the fire by his people, Allah made the fire cool and safe for him.

He taught us to trust Allah completely and to always speak the truth.''',
    },
    {
      'title': 'Prophet Yusuf (Joseph)',
      'subtitle': 'From Prison to Palace',
      'icon': Icons.castle_rounded,
      'color': Colors.amber,
      'moral': 'Forgiveness and kindness',
      'content': '''Prophet Yusuf (peace be upon him) was sold into slavery by his own brothers out of jealousy.

Despite many hardships, including being put in prison, he never lost faith in Allah.

Eventually, he became a powerful minister in Egypt and forgave his brothers, teaching us about forgiveness and kindness.''',
    },
    {
      'title': 'Prophet Musa (Moses)',
      'subtitle': 'The Staff and the Sea',
      'icon': Icons.waves_rounded,
      'color': Colors.teal,
      'moral': 'Courage and leadership',
      'content': '''Prophet Musa (peace be upon him) was chosen by Allah to free his people from Pharaoh.

When Pharaoh chased them to the sea, Allah commanded Musa to strike the water with his staff.

The sea parted, creating a path for the believers. This shows us the power of faith and courage.''',
    },
    {
      'title': 'Prophet Isa (Jesus)',
      'subtitle': 'The Miracle Child',
      'icon': Icons.star_rounded,
      'color': Colors.purple,
      'moral': 'Compassion and healing',
      'content': '''Prophet Isa (peace be upon him) was born miraculously to Maryam (Mary) without a father.

Allah gave him many miracles, including the ability to heal the sick and give sight to the blind.

He taught people to be compassionate, kind, and to worship Allah alone.''',
    },
    {
      'title': 'Prophet Muhammad (ﷺ)',
      'subtitle': 'The Final Messenger',
      'icon': Icons.book_rounded,
      'color': Colors.green,
      'moral': 'Perfect character and mercy',
      'content': '''Prophet Muhammad (peace be upon him) is the final messenger of Allah and an example for all humanity.

He was known as Al-Amin (the trustworthy) even before he became a prophet.

He taught us about kindness, honesty, mercy, and loving Allah. He is our best role model.''',
    },
  ];

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
          title: const Text('Prophet Stories'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal, Colors.teal.shade700],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
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
                              'Learn from the Prophets',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Inspiring tales with moral lessons',
                              style: TextStyle(
                                fontSize: 12,
                                color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Stories List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoryDetailScreen(story: story),
                            ),
                          );
                        },
                        child: GlassCard(
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      story['color'] as Color,
                                      (story['color'] as Color).withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  story['icon'] as IconData,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      story['title'] as String,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      story['subtitle'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (story['color'] as Color).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '📖 ${story['moral']}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: story['color'] as Color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: appProvider.accentColor,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Story Detail Screen
class StoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> story;

  const StoryDetailScreen({super.key, required this.story});

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
          title: Text(story['title'] as String),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Story Header
                GlassCard(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              story['color'] as Color,
                              (story['color'] as Color).withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (story['color'] as Color).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          story['icon'] as IconData,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        story['title'] as String,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        story['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: appProvider.accentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Moral Lesson
                GlassCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (story['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.lightbulb_rounded,
                          color: story['color'] as Color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Moral Lesson',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              story['moral'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: story['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Story Content
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: appProvider.accentColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'The Story',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        story['content'] as String,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.8,
                          color: isDark ? AppTheme.textLight : AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Audio narration coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_circle_filled_rounded),
                        label: const Text('Listen'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: story['color'] as Color,
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
                        },
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text('Finished'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
