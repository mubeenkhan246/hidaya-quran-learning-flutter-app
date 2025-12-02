import 'package:flutter/material.dart';

class HadithItem {
  final String number;
  final String text;
  final String reference;
  final String? grade;

  const HadithItem({
    required this.number,
    required this.text,
    required this.reference,
    this.grade,
  });
}

class HadithChapter {
  final String id;
  final String title;
  final String? arabicTitle;
  final List<HadithItem> hadiths;

  const HadithChapter({
    required this.id,
    required this.title,
    this.arabicTitle,
    required this.hadiths,
  });
}

class HadithCollection {
  final String id;
  final String name;
  final String shortName;
  final String? arabicName;
  final String description;
  final Color color;
  final List<HadithChapter> chapters;

  const HadithCollection({
    required this.id,
    required this.name,
    required this.shortName,
    this.arabicName,
    required this.description,
    required this.color,
    required this.chapters,
  });
}

class HadithSearchResult {
  final HadithCollection collection;
  final HadithChapter chapter;
  final HadithItem hadith;

  const HadithSearchResult({
    required this.collection,
    required this.chapter,
    required this.hadith,
  });
}

class HadithData {
  static const List<HadithCollection> collections = [
    HadithCollection(
      id: 'bukhari',
      name: 'Sahih al-Bukhari',
      shortName: 'Bukhari',
      arabicName: 'صحيح البخاري',
      description: 'The most authentic collection of hadith compiled by Imam al-Bukhari.',
      color: Color(0xFF10B981),
      chapters: [
        HadithChapter(
          id: 'book_of_faith',
          title: 'Book of Faith',
          arabicTitle: 'كتاب الإيمان',
          hadiths: [
            HadithItem(
              number: '1',
              text: 'Actions are but by intentions, and every person will have only what they intended.',
              reference: 'Sahih al-Bukhari 1',
              grade: 'Sahih',
            ),
            HadithItem(
              number: '2',
              text: 'Faith consists of more than sixty branches, and modesty is a branch of faith.',
              reference: 'Sahih al-Bukhari 9',
              grade: 'Sahih',
            ),
          ],
        ),
        HadithChapter(
          id: 'book_of_knowledge',
          title: 'Book of Knowledge',
          arabicTitle: 'كتاب العلم',
          hadiths: [
            HadithItem(
              number: '3',
              text: 'Whoever follows a path in pursuit of knowledge, Allah will make easy for him a path to Paradise.',
              reference: 'Sahih al-Bukhari, Sahih Muslim',
              grade: 'Sahih',
            ),
            HadithItem(
              number: '4',
              text: 'Convey from me, even if it is one verse.',
              reference: 'Sahih al-Bukhari 3461',
              grade: 'Sahih',
            ),
          ],
        ),
      ],
    ),
    HadithCollection(
      id: 'muslim',
      name: 'Sahih Muslim',
      shortName: 'Muslim',
      arabicName: 'صحيح مسلم',
      description: 'One of the most authentic collections of hadith compiled by Imam Muslim.',
      color: Color(0xFF0EA5E9),
      chapters: [
        HadithChapter(
          id: 'book_of_manners',
          title: 'Book of Manners',
          arabicTitle: 'كتاب الآداب',
          hadiths: [
            HadithItem(
              number: '1',
              text: 'The strong person is not the one who can wrestle, but the strong person is the one who controls himself when angry.',
              reference: 'Sahih Muslim 2609',
              grade: 'Sahih',
            ),
            HadithItem(
              number: '2',
              text: 'Allah is more merciful to His servants than a mother is to her child.',
              reference: 'Sahih Muslim 2754',
              grade: 'Sahih',
            ),
          ],
        ),
      ],
    ),
    HadithCollection(
      id: 'abu_dawud',
      name: 'Sunan Abi Dawud',
      shortName: 'Abi Dawud',
      arabicName: 'سنن أبي داود',
      description: 'A major collection of hadith focusing on legal rulings.',
      color: Color(0xFFF59E0B),
      chapters: [
        HadithChapter(
          id: 'book_of_prayer',
          title: 'Book of Prayer',
          arabicTitle: 'كتاب الصلاة',
          hadiths: [
            HadithItem(
              number: '1',
              text: 'The closest that a servant is to his Lord is when he is in prostration, so increase your supplications in it.',
              reference: 'Sunan Abi Dawud 875',
              grade: 'Hasan',
            ),
            HadithItem(
              number: '2',
              text: 'Between a man and disbelief is the abandonment of prayer.',
              reference: 'Sunan Abi Dawud 467',
              grade: 'Sahih',
            ),
          ],
        ),
      ],
    ),
  ];

  static HadithCollection? getCollectionById(String id) {
    for (final c in collections) {
      if (c.id == id) return c;
    }
    return null;
  }

  static HadithChapter? getChapterById(String collectionId, String chapterId) {
    final collection = getCollectionById(collectionId);
    if (collection == null) return null;
    for (final chapter in collection.chapters) {
      if (chapter.id == chapterId) return chapter;
    }
    return null;
  }

  static HadithSearchResult? findHadithByNumber(String collectionId, String hadithNumber) {
    final collection = getCollectionById(collectionId);
    if (collection == null) return null;
    for (final chapter in collection.chapters) {
      for (final hadith in chapter.hadiths) {
        if (hadith.number == hadithNumber) {
          return HadithSearchResult(
            collection: collection,
            chapter: chapter,
            hadith: hadith,
          );
        }
      }
    }
    return null;
  }
}
