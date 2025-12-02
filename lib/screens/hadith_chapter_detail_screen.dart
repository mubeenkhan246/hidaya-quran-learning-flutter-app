import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hadith/hadith.dart';

import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/sunnah_api_service.dart';

class HadithChapterDetailScreen extends StatefulWidget {
  final Collection collection;
  final int bookNumber;
  final String bookTitle;
  final String collectionName;
  final Color collectionColor;
  final int? initialHadithNumber;

  const HadithChapterDetailScreen({
    super.key,
    required this.collection,
    required this.bookNumber,
    required this.bookTitle,
    required this.collectionName,
    required this.collectionColor,
    this.initialHadithNumber,
  });

  @override
  State<HadithChapterDetailScreen> createState() => _HadithChapterDetailScreenState();
}

class _HadithChapterDetailScreenState extends State<HadithChapterDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final SunnahApiService _sunnahApiService = SunnahApiService();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        appBar: GlassAppBar(
          title: widget.collectionName,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FutureBuilder<List<SunnahHadith>>(
              future: _sunnahApiService.getHadiths(
                _mapCollectionToApiId(widget.collection),
                widget.bookNumber.toString(),
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(appProvider.accentColor),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load hadith.',
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                final hadiths = snapshot.data;
                if (hadiths == null || hadiths.isEmpty) {
                  return Center(
                    child: Text(
                      'No hadith found.',
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: hadiths.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.bookTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Book ${widget.bookNumber} • ${widget.collectionName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }

                    final hadith = hadiths[index - 1];
                    final hadithNumber = index; // 1-based within the book
                    final isHighlighted =
                        widget.initialHadithNumber != null && hadithNumber == widget.initialHadithNumber;

                    return Padding(
                      padding: EdgeInsets.only(bottom: index == hadiths.length ? 16 : 12),
                      child: GlassCard(
                        borderRadius: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: widget.collectionColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.format_quote_rounded,
                                    color: widget.collectionColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${widget.collectionName} $hadithNumber',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                final preferredLang = context.watch<AppProvider>().hadithLanguage;
                                final body = hadith.bodyForLanguage(preferredLang) ?? '';
                                return Text(
                                  body,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.6,
                                    color: textColor,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Book ${widget.bookNumber}, Hadith $hadithNumber',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: textColor.withOpacity(0.8),
                                  ),
                                ),
                                if (isHighlighted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: widget.collectionColor.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Searched',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: widget.collectionColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
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
