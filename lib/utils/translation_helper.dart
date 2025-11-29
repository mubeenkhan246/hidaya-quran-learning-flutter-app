import 'package:quran/quran.dart' as quran;

/// Helper class to get translations using quran package
class TranslationHelper {
  /// Get verse translation based on translation key
  static String getTranslation(
    int surahNumber,
    int verseNumber,
    String translationKey,
  ) {
    try {
      // Map translation keys to quran package Translation enum
      switch (translationKey) {
        case 'enSaheeh':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.enSaheeh,
          );
        case 'enClearQuran':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.enClearQuran,
          );
        case 'urdu':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.urdu,
          );
        case 'indonesian':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.indonesian,
          );
        case 'frHamidullah':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.frHamidullah,
          );
        case 'trSaheeh':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.trSaheeh,
          );
        case 'mlAbdulHameed':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.mlAbdulHameed,
          );
        case 'faHusseinDari':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.faHusseinDari,
          );
        case 'portuguese':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.portuguese,
          );
        case 'itPiccardo':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.itPiccardo,
          );
        case 'nlSiregar':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.nlSiregar,
          );
        case 'ruKuliev':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.ruKuliev,
          );
        case 'bengali':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.bengali,
          );
        case 'chinese':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.chinese,
          );
        case 'swedish':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.swedish,
          );
        case 'spanish':
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.spanish,
          );
        default:
          // Default to Saheeh International
          return quran.getVerseTranslation(
            surahNumber,
            verseNumber,
            translation: quran.Translation.enSaheeh,
          );
      }
    } catch (e) {
      // Fallback if translation fails
      return 'Translation not available';
    }
  }

  /// Get audio URL for a reciter and verse
  static String getVerseAudioUrl(
    int surahNumber,
    int verseNumber,
    String reciterKey,
  ) {
    // Map reciter keys to quran package Reciter enum
    final reciter = _getReciterEnum(reciterKey);
    
    // Use quran package method to get verse audio URL
    return quran.getAudioURLByVerse(surahNumber, verseNumber, reciter: reciter);
  }

  /// Get full Surah audio URL for a reciter
  static String getFullSurahAudioUrl(int surahNumber, String reciterKey) {
    // Using correct folder names from mp3quran.net server
    
    String reciterFolder;
    String serverNumber = 'server8'; // Default server
    
    // switch (reciterKey) {
    //   case 'arAlafasy':
    //     reciterFolder = 'afs'; // Mishary Alafasy
    //     serverNumber = 'server8';
    //     break;
    //   case 'arHusary':
    //     reciterFolder = 'Husary_128kbps'; // Mahmoud Al Husary
    //     serverNumber = 'server12';
    //     break;
    //   case 'arAhmedAjamy':
    //     reciterFolder = 'Ahmed_ibn_Ali_al-Ajamy_128kbps'; // Ahmed Al Ajamy
    //     serverNumber = 'server10';
    //     break;
    //   case 'arHudhaify':
    //     reciterFolder = 'Hudhaify_128kbps'; // Ali Al Hudhaify
    //     serverNumber = 'server12';
    //     break;
    //   case 'arMaherMuaiqly':
    //     reciterFolder = 'Maher_AlMuaiqly_128kbps'; // Maher Al Muaiqly
    //     serverNumber = 'server13';
    //     break;
    //   case 'arMuhammadAyyoub':
    //     reciterFolder = 'Muhammad_Ayyoub_128kbps'; // Muhammad Ayyoub
    //     serverNumber = 'server10';
    //     break;
    //   case 'arMuhammadJibreel':
    //     reciterFolder = 'Muhammad_Jibreel_128kbps'; // Muhammad Jibreel
    //     serverNumber = 'server6';
    //     break;
    //   case 'arMinshawi':
    //     reciterFolder = 'Minshawy_Mujawwad_128kbps'; // Mohamed Siddiq Al-Minshawi
    //     serverNumber = 'server10';
    //     break;
    //   case 'arShaatree':
    //     reciterFolder = 'Abu_Bakr_Ash-Shaatree_128kbps'; // Abu Bakr Al Shatri
    //     serverNumber = 'server11';
    //     break;
    //   default:
    //     reciterFolder = 'afs'; // Default to Alafasy
    //     serverNumber = 'server8';
    // }
    
    // Format Surah number as 3 digits (001, 002, etc.)
    final surahFormatted = surahNumber.toString().padLeft(3, '0');
    
    // Construct URL with correct server and folder
        return 'https://server8.mp3quran.net/afs/$surahFormatted.mp3';

    // return 'https://$serverNumber.mp3quran.net/$reciterFolder/$surahFormatted.mp3';
  }
  
  /// Helper method to convert reciter key to Reciter enum
  static quran.Reciter _getReciterEnum(String reciterKey) {
    switch (reciterKey) {
      case 'arAlafasy':
        return quran.Reciter.arAlafasy;
      case 'arHusary':
        return quran.Reciter.arHusary;
      case 'arAhmedAjamy':
        return quran.Reciter.arAhmedAjamy;
      case 'arHudhaify':
        return quran.Reciter.arHudhaify;
      case 'arMaherMuaiqly':
        return quran.Reciter.arMaherMuaiqly;
      case 'arMuhammadAyyoub':
        return quran.Reciter.arMuhammadAyyoub;
      case 'arMuhammadJibreel':
        return quran.Reciter.arMuhammadJibreel;
      case 'arMinshawi':
        return quran.Reciter.arMinshawi;
      case 'arShaatree':
        return quran.Reciter.arShaatree;
      default:
        return quran.Reciter.arAlafasy; // Default
    }
  }
  
  /// Get reciter name from key
  static String getReciterName(String reciterKey) {
    switch (reciterKey) {
      case 'arAlafasy':
        return 'Mishary Alafasy';
      case 'arHusary':
        return 'Mahmoud Al Husary';
      case 'arAhmedAjamy':
        return 'Ahmed Al Ajamy';
      case 'arHudhaify':
        return 'Ali Al Hudhaify';
      case 'arMaherMuaiqly':
        return 'Maher Al Muaiqly';
      case 'arMuhammadAyyoub':
        return 'Muhammad Ayyoub';
      case 'arMuhammadJibreel':
        return 'Muhammad Jibreel';
      case 'arMinshawi':
        return 'Mohamed Siddiq Al-Minshawi';
      case 'arShaatree':
        return 'Abu Bakr Al Shatri';
      default:
        return 'Mishary Alafasy';
    }
  }
  
  /// Get list of all reciters
  static List<Map<String, String>> getReciters() {
    return [
      {'key': 'arAlafasy', 'name': 'Mishary Alafasy'},
      {'key': 'arHusary', 'name': 'Mahmoud Al Husary'},
      {'key': 'arAhmedAjamy', 'name': 'Ahmed Al Ajamy'},
      {'key': 'arHudhaify', 'name': 'Ali Al Hudhaify'},
      {'key': 'arMaherMuaiqly', 'name': 'Maher Al Muaiqly'},
      {'key': 'arMuhammadAyyoub', 'name': 'Muhammad Ayyoub'},
      {'key': 'arMuhammadJibreel', 'name': 'Muhammad Jibreel'},
      {'key': 'arMinshawi', 'name': 'Mohamed Siddiq Al-Minshawi'},
      {'key': 'arShaatree', 'name': 'Abu Bakr Al Shatri'},
    ];
  }
  
  /// Get list of all translation languages
  static List<Map<String, String>> getLanguages() {
    return [
      {'key': 'enSaheeh', 'name': 'English (Saheeh International)'},
      {'key': 'enClearQuran', 'name': 'English (Clear Quran)'},
      {'key': 'urdu', 'name': 'Urdu'},
      {'key': 'indonesian', 'name': 'Indonesian'},
      {'key': 'frHamidullah', 'name': 'French (Hamidullah)'},
      {'key': 'trSaheeh', 'name': 'Turkish (Saheeh)'},
      {'key': 'mlAbdulHameed', 'name': 'Malayalam (Abdul Hameed)'},
      {'key': 'faHusseinDari', 'name': 'Farsi (Hussein Dari)'},
      {'key': 'portuguese', 'name': 'Portuguese'},
      {'key': 'itPiccardo', 'name': 'Italian (Piccardo)'},
      {'key': 'nlSiregar', 'name': 'Dutch (Siregar)'},
      {'key': 'ruKuliev', 'name': 'Russian (Kuliev)'},
      {'key': 'bengali', 'name': 'Bengali'},
      {'key': 'chinese', 'name': 'Chinese'},
      {'key': 'swedish', 'name': 'Swedish'},
      {'key': 'spanish', 'name': 'Spanish'},
    ];
  }
  
  /// Check if a translation language uses RTL (Right-to-Left) text direction
  static bool isRTLLanguage(String translationKey) {
    const rtlLanguages = [
      'urdu',           // Urdu
      'faHusseinDari',  // Farsi/Persian
    ];
    return rtlLanguages.contains(translationKey);
  }
}
