import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hadith/hadith.dart';

import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../services/sunnah_api_service.dart';
import 'hadith_chapter_detail_screen.dart';

class HadithChaptersScreen extends StatelessWidget {
  final Collection collection;
  final String collectionName;
  final Color collectionColor;

  const HadithChaptersScreen({
    super.key,
    required this.collection,
    required this.collectionName,
    required this.collectionColor,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textDark;
    final sunnahApi = SunnahApiService();
    final collectionId = _mapCollectionToApiId(collection);

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: GlassAppBar(
          title: collectionName,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FutureBuilder<List<SunnahBook>>(
              future: sunnahApi.getBooks(collectionId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(appProvider.accentColor),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  final error = snapshot.error;
                  // Debug logging to console
                  // ignore: avoid_print
                  print('getBooks error: $error');
                  // ignore: avoid_print
                  print('getBooks stackTrace: ${snapshot.stackTrace}');

                  return Center(
                    child: Text(
                      'Failed to load chapters:\n${error ?? 'Unknown error'}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                final books = snapshot.data;
                if (books == null || books.isEmpty) {
                  return Center(
                    child: Text(
                      'No chapters found.',
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Chapters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: List.generate(books.length, (index) {
                          final book = books[index];
                          final parsedBookNumber = int.tryParse(book.bookNumber);
                          final bookNumber = parsedBookNumber ?? index + 1;
                          final title =
                              book.englishName ?? book.arabicName ?? 'Book ${book.bookNumber}';

                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HadithChapterDetailScreen(
                                    collection: collection,
                                    bookNumber: bookNumber,
                                    bookTitle: title,
                                    collectionName: collectionName,
                                    collectionColor: collectionColor,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: collectionColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.article_rounded,
                                    color: collectionColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Book $bookNumber',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
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
