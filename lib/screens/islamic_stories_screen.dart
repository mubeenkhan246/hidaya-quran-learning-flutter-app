import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../constants/story_data.dart';
import '../models/islamic_story.dart';
import '../widgets/glass_card.dart';

class IslamicStoriesScreen extends StatefulWidget {
  const IslamicStoriesScreen({super.key});

  @override
  State<IslamicStoriesScreen> createState() => _IslamicStoriesScreenState();
}

class _IslamicStoriesScreenState extends State<IslamicStoriesScreen> {
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLanguage = 'english'; // 'english' or 'urdu'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IslamicStory> get _filteredStories {
    if (_searchQuery.isNotEmpty) {
      return StoryData.searchStories(_searchQuery);
    }
    if (_selectedCategory != null) {
      return StoryData.getStoriesByCategory(_selectedCategory!);
    }
    return StoryData.stories;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, appProvider),
            _buildSearchBar(context, appProvider, isDark),
            _buildCategoryChips(context, appProvider, isDark),
            Expanded(
              child: _filteredStories.isEmpty
                  ? _buildEmptyState(context, appProvider, isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: _filteredStories.length,
                      itemBuilder: (context, index) {
                        return _buildStoryCard(
                          context,
                          _filteredStories[index],
                          appProvider,
                          isDark,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider appProvider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  appProvider.accentColor.withOpacity(0.2),
                  appProvider.accentColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: appProvider.accentColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: appProvider.accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Islamic Stories',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Learn from the past',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: appProvider.isDarkMode
                        ? AppTheme.textLight.withOpacity(0.7)
                        : AppTheme.textDark.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Language Toggle
          // Container(
          //   padding: const EdgeInsets.all(4),
          //   decoration: BoxDecoration(
          //     color: appProvider.accentColor.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       _buildLanguageButton('EN', 'english', appProvider),
          //       const SizedBox(width: 4),
          //       _buildLanguageButton('UR', 'urdu', appProvider),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String label, String lang, AppProvider appProvider) {
    final isSelected = _selectedLanguage == lang;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = lang;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? appProvider.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : appProvider.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppProvider appProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search stories...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: appProvider.accentColor,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: appProvider.accentColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, AppProvider appProvider, bool isDark) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: StoryData.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(
              context,
              'All',
              '📚',
              null,
              appProvider,
              isDark,
            );
          }
          final category = StoryData.categories[index - 1];
          return _buildCategoryChip(
            context,
            category.name,
            category.icon,
            category.id,
            appProvider,
            isDark,
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    String icon,
    String? categoryId,
    AppProvider appProvider,
    bool isDark,
  ) {
    final isSelected = _selectedCategory == categoryId;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = categoryId;
            _searchQuery = '';
            _searchController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      appProvider.accentColor,
                      appProvider.accentColor.withOpacity(0.8),
                    ],
                  )
                : null,
            color: !isSelected
                ? (isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03))
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? appProvider.accentColor
                  : (isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1)),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppTheme.textLight : AppTheme.textDark),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(
    BuildContext context,
    IslamicStory story,
    AppProvider appProvider,
    bool isDark,
  ) {
    final categoryData = StoryData.categories.firstWhere(
      (cat) => cat.id == story.category,
      orElse: () => StoryData.categories.first,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        child: InkWell(
          onTap: () => _showStoryDetail(context, story, appProvider),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appProvider.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        categoryData.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.getTitle(_selectedLanguage),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            story.titleArabic,
                            style: AppTheme.arabicTextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: appProvider.accentColor,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  story.getStory(_selectedLanguage).length > 150
                      ? '${story.getStory(_selectedLanguage).substring(0, 150)}...'
                      : story.getStory(_selectedLanguage),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.textLight.withOpacity(0.8)
                        : AppTheme.textDark.withOpacity(0.8),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: appProvider.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: appProvider.accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 14,
                        color: appProvider.accentColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          story.reference,
                          style: TextStyle(
                            color: appProvider.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppProvider appProvider, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: appProvider.accentColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No stories found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark
                  ? AppTheme.textLight.withOpacity(0.6)
                  : AppTheme.textDark.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.textLight.withOpacity(0.4)
                  : AppTheme.textDark.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _showStoryDetail(BuildContext context, IslamicStory story, AppProvider appProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _StoryDetailSheet(
        story: story,
        appProvider: appProvider,
        selectedLanguage: _selectedLanguage,
      ),
    );
  }
}

class _StoryDetailSheet extends StatelessWidget {
  final IslamicStory story;
  final AppProvider appProvider;
  final String selectedLanguage;

  const _StoryDetailSheet({
    required this.story,
    required this.appProvider,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = appProvider.isDarkMode;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppTheme.primaryDark, AppTheme.secondaryDeep]
              : [const Color(0xFFFAFAFA), const Color(0xFFF0F0F3)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: appProvider.accentColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  story.getTitle(selectedLanguage),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  story.titleArabic,
                  style: AppTheme.arabicTextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: appProvider.accentColor,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      context,
                      Icons.copy_rounded,
                      'Copy',
                      () {
                        Clipboard.setData(ClipboardData(
                          text: '${story.getTitle(selectedLanguage)}\n\n${story.getStory(selectedLanguage)}\n\nReference: ${story.reference}',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('✓ Story copied to clipboard'),
                            backgroundColor: appProvider.accentColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      context,
                      Icons.share_rounded,
                      'Share',
                      () {
                        Share.share(
                          '${story.getTitle(selectedLanguage)}\n${story.titleArabic}\n\n${story.getStory(selectedLanguage)}\n\nReference: ${story.reference}',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    'The Story',
                    story.getStory(selectedLanguage),
                    Icons.auto_stories_rounded,
                  ),
                  if (story.getMoralLesson(selectedLanguage) != null) ...[
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      'Moral Lesson',
                      story.getMoralLesson(selectedLanguage)!,
                      Icons.lightbulb_rounded,
                    ),
                  ],
                  if (story.getKeyPoints(selectedLanguage) != null && story.getKeyPoints(selectedLanguage)!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildKeyPoints(context, story.getKeyPoints(selectedLanguage)!),
                  ],
                  const SizedBox(height: 24),
                  _buildReference(context, story.reference),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: appProvider.accentColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: appProvider.accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: appProvider.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.8,
            color: appProvider.isDarkMode
                ? AppTheme.textLight.withOpacity(0.9)
                : AppTheme.textDark.withOpacity(0.9),
          ),
          textDirection: selectedLanguage == 'urdu' ? TextDirection.rtl : TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildKeyPoints(BuildContext context, List<String> keyPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_rounded, color: appProvider.accentColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Key Points',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: appProvider.accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...keyPoints.map((point) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: selectedLanguage == 'urdu' ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: appProvider.accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  point,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: appProvider.isDarkMode
                        ? AppTheme.textLight.withOpacity(0.9)
                        : AppTheme.textDark.withOpacity(0.9),
                  ),
                  textDirection: selectedLanguage == 'urdu' ? TextDirection.rtl : TextDirection.ltr,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildReference(BuildContext context, String reference) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appProvider.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appProvider.accentColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bookmark_rounded,
            color: appProvider.accentColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reference',
                  style: TextStyle(
                    color: appProvider.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reference,
                  style: TextStyle(
                    color: appProvider.accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
