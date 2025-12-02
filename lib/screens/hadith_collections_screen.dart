import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hadith/hadith.dart';

import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/sunnah_api_service.dart';
import 'hadith_chapters_screen.dart';

class HadithCollectionsScreen extends StatefulWidget {
  const HadithCollectionsScreen({super.key});

  @override
  State<HadithCollectionsScreen> createState() => _HadithCollectionsScreenState();
}

class _HadithCollectionsScreenState extends State<HadithCollectionsScreen> {
  Collection? _selectedCollection;
  List<Collection>? _collections;
  bool _isLoadingCollections = true;
  final TextEditingController _searchController = TextEditingController();
  final SunnahApiService _sunnahApiService = SunnahApiService();

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCollections() async {
    // For now we rely on the known set of collections and fetch hadith data
    // from Sunnah.com only when needed.
    setState(() {
      _collections = Collection.values;
      if (_collections!.isNotEmpty) {
        _selectedCollection = _selectedCollection ?? _collections!.first;
      }
      _isLoadingCollections = false;
    });
  }

  Future<void> _onSearch(BuildContext context) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a hadith number to search.')),
      );
      return;
    }

    if (_selectedCollection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collections are still loading. Please try again.')),
      );
      return;
    }

    final number = int.tryParse(query);
    if (number == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid numeric hadith number.')),
      );
      return;
    }

    try {
      final collectionId = _mapCollectionToApiId(_selectedCollection!);
      final sunnahHadith = await _sunnahApiService.getHadithByNumber(
        collectionId: collectionId,
        hadithNumber: number.toString(),
      );

      if (sunnahHadith == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hadith not found in this collection.')),
        );
        return;
      }

      final preferredLang = context.read<AppProvider>().hadithLanguage;
      final body = sunnahHadith.bodyForLanguage(preferredLang);

      if (body == null || body.trim().isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No text available for this hadith.')),
        );
        return;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Hadith $number'),
            content: SingleChildScrollView(
              child: Text(
                body,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch hadith. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textDark;

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const GlassAppBar(
          
          title: 'Hadith Collections',
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search by hadith number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isLoadingCollections)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: LinearProgressIndicator(),
                        )
                      else if (_collections == null || _collections!.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No collections available.',
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        )
                      else
                        DropdownButtonFormField<Collection>(
                          value: _selectedCollection,
                          decoration: const InputDecoration(
                            labelText: 'Collection',
                          ),
                          items: _collections!
                              .map(
                                (c) => DropdownMenuItem<Collection>(
                                  value: c,
                                  child: Text(_getCollectionName(c)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedCollection = value;
                            });
                          },
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: appProvider.hadithLanguage,
                              decoration: const InputDecoration(
                                labelText: 'Hadith language',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text('English'),
                                ),
                                DropdownMenuItem(
                                  value: 'ar',
                                  child: Text('Arabic'),
                                ),
                                DropdownMenuItem(
                                  value: 'ur',
                                  child: Text('Urdu'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                appProvider.setHadithLanguage(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Hadith number',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _onSearch(context),
                            icon: const Icon(Icons.search_rounded),
                            label: const Text('Search'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Collections',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                if (_isLoadingCollections)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_collections == null || _collections!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No collections to display.',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  )
                else
                  Column(
                    children: _collections!.map((collection) {
                      final color = _getCollectionColor(collection);
                      final name = _getCollectionName(collection);
                      final arabicName = _getCollectionArabicName(collection);
                      final description = _getCollectionDescription(collection);

                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HadithChaptersScreen(
                                collection: collection,
                                collectionName: name,
                                collectionColor: color,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  if (arabicName != null)
                                    Text(
                                      arabicName,
                                      style: AppTheme.arabicTextStyle(
                                        fontSize: 16,
                                        color: textColor.withOpacity(0.9),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textColor.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCollectionName(Collection collection) {
    switch (collection) {
      case Collection.bukhari:
        return 'Sahih al-Bukhari';
      case Collection.muslim:
        return 'Sahih Muslim';
      case Collection.abudawud:
        return 'Sunan Abi Dawud';
      case Collection.tirmidhi:
        return 'Jami\' at-Tirmidhi';
      case Collection.nasai:
        return 'Sunan an-Nasa\'i';
      case Collection.ibnmajah:
        return 'Sunan Ibn Majah';
    }
  }

  String? _getCollectionArabicName(Collection collection) {
    switch (collection) {
      case Collection.bukhari:
        return 'صحيح البخاري';
      case Collection.muslim:
        return 'صحيح مسلم';
      case Collection.abudawud:
        return 'سنن أبي داود';
      case Collection.tirmidhi:
        return 'جامع الترمذي';
      case Collection.nasai:
        return 'سنن النسائي';
      case Collection.ibnmajah:
        return 'سنن ابن ماجه';
    }
  }

  String _getCollectionDescription(Collection collection) {
    switch (collection) {
      case Collection.bukhari:
        return 'The most authentic collection of hadith compiled by Imam al-Bukhari.';
      case Collection.muslim:
        return 'A highly authentic collection compiled by Imam Muslim.';
      case Collection.abudawud:
        return 'A major collection focusing on fiqh and legal rulings.';
      case Collection.tirmidhi:
        return 'A comprehensive collection that includes grading of hadith.';
      case Collection.nasai:
        return 'A collection with a focus on legal aspects of worship and dealings.';
      case Collection.ibnmajah:
        return 'A widely used collection completing the six major books (Kutub as-Sittah).';
    }
  }

  Color _getCollectionColor(Collection collection) {
    switch (collection) {
      case Collection.bukhari:
        return const Color(0xFF10B981); // Emerald
      case Collection.muslim:
        return const Color(0xFF0EA5E9); // Sky
      case Collection.abudawud:
        return const Color(0xFFF59E0B); // Amber
      case Collection.tirmidhi:
        return const Color(0xFF8B5CF6); // Violet
      case Collection.nasai:
        return const Color(0xFF6366F1); // Indigo
      case Collection.ibnmajah:
        return const Color(0xFFFF6B6B); // Coral
    }
  }

  String _mapCollectionToApiId(Collection collection) {
    switch (collection) {
      case Collection.bukhari:
        return 'bukhari';
      case Collection.muslim:
        return 'muslim';
      case Collection.abudawud:
        return 'abudawud';
      case Collection.tirmidhi:
        return 'tirmidhi';
      case Collection.nasai:
        return 'nasai';
      case Collection.ibnmajah:
        return 'ibnmajah';
    }
  }
}
