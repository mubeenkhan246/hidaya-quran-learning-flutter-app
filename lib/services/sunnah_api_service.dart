import 'package:dio/dio.dart';

class SunnahApiService {
  static const String _baseUrl = 'https://api.sunnah.com/v1/';
  static const String _apiKeyHeader = 'X-API-Key';

  /// Provide your Sunnah.com API key via --dart-define=SUNNAH_API_KEY=your_key
  static const String apiKey = String.fromEnvironment('SUNNAH_API_KEY');

  final Dio _dio;

  SunnahApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _baseUrl,
                headers: {
                  _apiKeyHeader: apiKey,
                },
              ),
            );

  Future<List<SunnahBook>> getBooks(String collectionId,
      {int limit = 50, int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/collections/$collectionId/books',
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => SunnahBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SunnahHadith>> getHadiths(
    String collectionId,
    String bookNumber, {
    int limit = 50,
    int page = 1,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/collections/$collectionId/books/$bookNumber/hadiths',
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );

    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => SunnahHadith.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SunnahHadith?> getHadithByNumber({
    required String collectionId,
    required String hadithNumber,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/collections/$collectionId/hadiths/$hadithNumber',
      );
      final data = response.data;
      if (data == null) return null;
      return SunnahHadith.fromJson(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) {
        return null;
      }
      rethrow;
    }
  }
}

class SunnahBook {
  final String bookNumber;
  final String? englishName;
  final String? arabicName;
  final int hadithStartNumber;
  final int hadithEndNumber;
  final int numberOfHadith;

  SunnahBook({
    required this.bookNumber,
    required this.englishName,
    required this.arabicName,
    required this.hadithStartNumber,
    required this.hadithEndNumber,
    required this.numberOfHadith,
  });

  factory SunnahBook.fromJson(Map<String, dynamic> json) {
    final bookList = json['book'] as List<dynamic>? ?? [];
    String? englishName;
    String? arabicName;

    for (final item in bookList) {
      final map = item as Map<String, dynamic>;
      final lang = map['lang']?.toString();
      final name = map['name']?.toString();
      if (lang == 'en') {
        englishName ??= name;
      } else if (lang == 'ar') {
        arabicName ??= name;
      }
    }

    return SunnahBook(
      bookNumber: json['bookNumber']?.toString() ?? '',
      englishName: englishName,
      arabicName: arabicName,
      hadithStartNumber: json['hadithStartNumber'] as int? ?? 0,
      hadithEndNumber: json['hadithEndNumber'] as int? ?? 0,
      numberOfHadith: json['numberOfHadith'] as int? ?? 0,
    );
  }
}

class SunnahHadithText {
  final String lang;
  final String body;
  final String? chapterTitle;

  SunnahHadithText({
    required this.lang,
    required this.body,
    required this.chapterTitle,
  });

  factory SunnahHadithText.fromJson(Map<String, dynamic> json) {
    return SunnahHadithText(
      lang: json['lang']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      chapterTitle: json['chapterTitle']?.toString(),
    );
  }
}

class SunnahHadith {
  final String collection;
  final String bookNumber;
  final String hadithNumber;
  final List<SunnahHadithText> texts;

  SunnahHadith({
    required this.collection,
    required this.bookNumber,
    required this.hadithNumber,
    required this.texts,
  });

  factory SunnahHadith.fromJson(Map<String, dynamic> json) {
    final hadithList = json['hadith'] as List<dynamic>? ?? [];
    final texts = hadithList
        .map((e) => SunnahHadithText.fromJson(e as Map<String, dynamic>))
        .toList();

    return SunnahHadith(
      collection: json['collection']?.toString() ?? '',
      bookNumber: json['bookNumber']?.toString() ?? '',
      hadithNumber: json['hadithNumber']?.toString() ?? '',
      texts: texts,
    );
  }

  /// Returns the hadith body for the given language code, with sensible
  /// fallbacks: preferred -> English -> Arabic -> first available.
  String? bodyForLanguage(String langCode) {
    final target = langCode.toLowerCase();

    // 1. Exact preferred language (e.g. en, ar, ur)
    for (final t in texts) {
      if (t.lang.toLowerCase() == target) {
        return t.body;
      }
    }

    // 2. English
    for (final t in texts) {
      if (t.lang.toLowerCase() == 'en') {
        return t.body;
      }
    }

    // 3. Arabic
    for (final t in texts) {
      if (t.lang.toLowerCase() == 'ar') {
        return t.body;
      }
    }

    // 4. Anything available
    if (texts.isNotEmpty) {
      return texts.first.body;
    }
    return null;
  }
}
